#!/bin/bash
set -Eeuo pipefail
umask 077

result=${TKL_TEST_RESULT:?TKL_TEST_RESULT is required}
app_password=${TKL_TEST_APP_PASS:?TKL_TEST_APP_PASS is required}
db_password=${TKL_TEST_DB_PASS:?TKL_TEST_DB_PASS is required}
base=https://localhost
api=$base/api/v1
auth_file=/tmp/tkl-espocrm-auth.$$
home_file=/tmp/tkl-espocrm-home.$$
lead_file=/tmp/tkl-espocrm-lead.$$
release_file=/tmp/tkl-espocrm-release.$$
latest_file=/tmp/tkl-espocrm-latest.$$

cleanup() {
    rm -f -- "$auth_file" "$home_file" "$lead_file" "$release_file" \
        "$latest_file"
}
trap cleanup EXIT

resolve=(--resolve localhost:443:127.0.0.1)
curl_common=(--insecure --fail --silent --show-error "${resolve[@]}")

for unit in apache2.service mariadb.service espocrm-websocket.service \
        multi-user.target; do
    systemctl --quiet is-active "$unit" || {
        echo "$unit is not active" >&2
        exit 1
    }
done

curl "${curl_common[@]}" "$base/" >"$home_file"
grep -q 'EspoCRM' "$home_file" || {
    echo 'EspoCRM application page is missing' >&2
    exit 1
}
site_url=$(runuser -u www-data -- sh -c \
    'cd /var/www/espocrm && php command.php config:get siteUrl')
test "$site_url" = 'https://localhost' || {
    echo 'EspoCRM site URL does not match firstboot input' >&2
    exit 1
}

credentials=$(printf 'admin:%s' "$app_password" | base64 -w0)
curl "${curl_common[@]}" \
    --header "Espo-Authorization: $credentials" \
    "$api/App/user" >"$auth_file"
token=$(python3 - "$auth_file" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding='utf-8'))
assert data['user']['userName'] == 'admin'
assert data['user']['type'] == 'admin'
print(data['token'])
PY
)
token_credentials=$(printf 'admin:%s' "$token" | base64 -w0)

curl "${curl_common[@]}" \
    --header "Espo-Authorization: $token_credentials" \
    --header 'Content-Type: application/json' \
    --data '{"firstName":"TurnKey","lastName":"Acceptance","status":"New"}' \
    "$api/Lead" >"$lead_file"
lead_id=$(python3 - "$lead_file" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding='utf-8'))
assert data['firstName'] == 'TurnKey'
assert data['lastName'] == 'Acceptance'
print(data['id'])
PY
)
curl "${curl_common[@]}" \
    --header "Espo-Authorization: $token_credentials" \
    "$api/Lead/$lead_id" >"$lead_file"
python3 - "$lead_file" "$lead_id" <<'PY'
import json
import sys

data = json.load(open(sys.argv[1], encoding='utf-8'))
assert data['id'] == sys.argv[2]
assert data['name'] == 'TurnKey Acceptance'
PY
mysql --batch --skip-column-names espocrm \
    --execute "SELECT id FROM lead WHERE id = '$lead_id'" | grep -Fxq "$lead_id"

runuser -u www-data -- sh -c 'cd /var/www/espocrm && php -f cron.php'
mysqladmin --user=root --password="$db_password" ping 2>/dev/null |
    grep -q 'mysqld is alive'
dpkg-query -W adminer webmin-apache webmin-mysql webmin-postfix postfix >/dev/null

installed=$(runuser -u www-data -- sh -c \
    'cd /var/www/espocrm && php command.php version' | tail -1)
test "$installed" = '10.0.6'
curl --fail --silent --show-error \
    "https://api.github.com/repos/espocrm/espocrm/releases/tags/$installed" \
    >"$release_file"
curl --fail --silent --show-error \
    https://api.github.com/repos/espocrm/espocrm/releases/latest >"$latest_file"
read -r asset_digest latest_version < <(python3 - \
        "$release_file" "$latest_file" <<'PY'
import json
import sys

release = json.load(open(sys.argv[1], encoding='utf-8'))
latest = json.load(open(sys.argv[2], encoding='utf-8'))
asset = next(a for a in release['assets'] if a['name'] == f"EspoCRM-{release['tag_name']}.zip")
print(asset['digest'].removeprefix('sha256:'), latest['tag_name'])
PY
)
test "$asset_digest" = \
    '88bcb177dbe38b79ec3c13d491d78b727dc14fe18fc91deea1bfa72b313f7fb4'
test "$(printf '%s\n%s\n' "$installed" "$latest_version" | sort -V | head -1)" = \
    "$installed"

cat >"$result" <<EOF
package_source=Official EspoCRM GitHub release archive
installed_version=$installed
runtime_checks=normal init; Apache, MariaDB, and WebSocket active; HTTPS application; firstboot administrator authentication; lead create and read through REST API; MariaDB persistence; cron execution; root database login; Adminer, Webmin, and Postfix packages
updater_command=php command.php version; query official GitHub latest release metadata
updater_result=installed $installed; official latest stable $latest_version; installed version unchanged
updater_channel=EspoCRM official stable GitHub releases and supervised php command.php upgrade
integrity_evidence=GitHub release asset digest $asset_digest matches the build-pinned SHA-256
EOF
