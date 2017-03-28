THEOS_DEVICE_IP = localhost
THEOS_DEVICE_PORT = 2222
ARCHS = armv7 arm64
TARGET = iphone:latest:7.0

SRC = $(wildcard src/*.m)

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = robot
robot_FILES =  $(wildcard src/*.m) src/Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 WeChat"
