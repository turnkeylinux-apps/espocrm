EspoCRM - lightweight customer relationship manager
===================================================

`EspoCRM`_ is a mobile-friendly open source CRM application that allows
you to see, enter and evaluate all your company relationships regardless
of the type. It integrates with your calendar, email and social media to
track leads, opportunities and accounts. People, companies, projects -
all in an easy and intuitive interface.

This appliance includes all the standard features in `TurnKey Core`_,
and on top of that:

- EspoCRM configurations:
   
    - Installed from upstream source code to /var/www/espocrm

      **Security note**: Updates to EspoCRM may require supervision so
      they **ARE NOT** configured to install automatically. See `EspoCRM
      documentation`_ for upgrading.

- SSL support out of the box.
- `Adminer`_ administration frontend for MySQL (listening on port
  12322 - uses SSL).
- Postfix MTA (bound to localhost) to allow sending of email (e.g.,
  password recovery).
- Webmin modules for configuring Apache2, PHP, MySQL and Postfix.

Credentials *(passwords set at first boot)*
-------------------------------------------

-  Webmin, SSH, MySQL: username **root**
-  Adminer: username **adminer**
-  EspoCRM: username **admin**


.. _EspoCRM: https://www.espocrm.com/
.. _TurnKey Core: https://www.turnkeylinux.org/core
.. _EspoCRM documentation: https://www.espocrm.com/documentation/administration/upgrading/
.. _Adminer: https://www.adminer.org

