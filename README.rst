EspoCRM - web based, open source CRM
===========================================

`EspoCRM`_ is an open source CRM application that allows you to see, enter and evaluate all your company relationships regardless of the type. People, companies, projects or opportunities — all in an easy and intuitive interface.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- EspoCRM configurations:
   
    - Installed from upstream source code to /var/www/espocrm

- SSL support out of the box.
- `PHPMyAdmin`_ administration frontend for MySQL (listening on port
  12322 - uses SSL).
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring Apache2, PHP, MySQL and Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL, phpMyAdmin: username **root**
-  EspoCRM: username **admin**


.. _EspoCRM: http://www.espocrm.com/
.. _TurnKey Core: http://www.turnkeylinux.org/core
.. _PHPMyAdmin: http://www.phpmyadmin.net

