PHP_EXTRA_PINS=libpcre2-8-0 libgd3
PHP_VERSION=8.1

COMMON_CONF = apache-credit

CREDIT_ANCHORTEXT = EspoCRM Appliance

include $(FAB_PATH)/common/mk/turnkey/lamp.mk
include $(FAB_PATH)/common/mk/turnkey.mk
