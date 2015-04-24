#!/usr/bin/python
"""Set EspoCRM url

Option:
    --domain=   unless provided, will ask interactively
                DEFAULT=127.0.0.1

"""

import sys
import getopt
import hashlib

from dialog_wrapper import Dialog
from mysqlconf import MySQL
from executil import system

def usage(s=None):
    if s:
        print >> sys.stderr, "Error:", s
    print >> sys.stderr, "Syntax: %s [options]" % sys.argv[0]
    print >> sys.stderr, __doc__
    sys.exit(1)

DEFAULT_DOMAIN="127.0.0.1"

def main():
    try:
        opts, args = getopt.gnu_getopt(sys.argv[1:], "h",
                                       ['help', 'domain='])
    except getopt.GetoptError, e:
        usage(e)

    domain = ""
    for opt, val in opts:
        if opt in ('-h', '--help'):
            usage()
        elif opt == '--domain':
            domain = val


    if not domain:
        if 'd' not in locals():
            d = Dialog('TurnKey Linux - First boot configuration')

        domain = d.get_input(
            "EspoCRM URL",
            "Example: www.mydomain.com or mydomain.com",
            DEFAULT_DOMAIN)

    if domain == "DEFAULT":
        domain = DEFAULT_DOMAIN



    conf = "/var/www/espocrm/data/config.php"
    system("sed -i \"s|siteUrl.*|siteUrl' => 'http://%s',|\" %s" % (domain, conf))


if __name__ == "__main__":
    main()

