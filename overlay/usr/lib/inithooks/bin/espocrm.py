#!/usr/bin/python
"""Set EspoCRM admin password

Option:
    --pass=     unless provided, will ask interactively

"""

import sys
import getopt
import hashlib
import crypt
import re

from dialog_wrapper import Dialog
from mysqlconf import MySQL
from executil import system

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'pass='])
    except getopt.GetoptError, e:
        usage(e)

    password = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif  opt == '--pass':
            password = val

    if not password:
        if 'd' not in locals():
            d = Dialog('TurnKey Linux - First boot configuration')

        password = d.get_password(
            "EspoCRM password",
            "Enter new password for the EspoCRM 'admin' account.")

    conf = "/var/www/espocrm/data/config.php"

    for line in open(conf):
        match = re.search("'passwordSalt' => '([^']*)',", line)
        if match != None:
            normSalt = ('$6$%s$' % match.group(1))
            hashed = crypt.crypt(hashlib.md5(password).hexdigest(), normSalt).replace(normSalt, '')

            m = MySQL()
            m.execute('UPDATE espocrm.user SET password = \"%s\" WHERE user_name = \"admin\"' % hashed)
            break


if __name__ == "__main__":
    main()

