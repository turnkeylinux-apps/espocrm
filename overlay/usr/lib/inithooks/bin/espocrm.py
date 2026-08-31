#!/usr/bin/python3
"""Set EspoCRM admin password

Option:
    --pass=     unless provided, will ask interactively
    --domain=   unless provided, will ask interactively
                DEFAULT=www.example.com
"""

import sys
import getopt
import subprocess
from libinithooks import inithooks_cache

from libinithooks.dialog_wrapper import Dialog
from mysqlconf import MySQL

def usage(s=None):
    if s:
        print("Error:", s, file=sys.stderr)
    print("Syntax: %s [options]" % sys.argv[0], file=sys.stderr)
    print(__doc__, file=sys.stderr)
    sys.exit(1)

DEFAULT_DOMAIN='www.example.com'

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass=', 'domain='])
    except getopt.GetoptError as e:
        usage(e)

    domain = ''
    password = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--pass':
            password = val
        elif opt == '--domain':
            domain = val

    if not password:
        if 'd' not in locals():
            d = Dialog('TurnKey Linux - First boot configuration')

        password = d.get_password(
            "EspoCRM password",
            "Enter new password for the EspoCRM 'admin' account.")

    if not domain:
        if 'd' not in locals():
            d = Dialog('TurnKey Linux - First boot configuration')

        domain = d.get_input(
            "EspoCRM Domain",
            "Enter the domain to serve EspoCRM.",
            DEFAULT_DOMAIN)

    if domain == "DEFAULT":
        domain = DEFAULT_DOMAIN

    inithooks_cache.write('APP_DOMAIN', domain)

    subprocess.run(
        [
            'runuser',
            '-u',
            'www-data',
            '--',
            'php',
            'command.php',
            'config:set',
            'siteUrl',
            f'https://{domain}',
        ],
        cwd='/var/www/espocrm',
        check=True,
    )

    hashed = subprocess.run(
        [
            'php',
            '-r',
            'echo password_hash(stream_get_contents(STDIN), PASSWORD_BCRYPT);',
        ],
        input=password,
        text=True,
        check=True,
        capture_output=True,
    ).stdout

    m = MySQL()
    m.execute(
        'UPDATE espocrm.user SET password=%s WHERE user_name="admin"',
        (hashed,),
    )

if __name__ == "__main__":
    main()
