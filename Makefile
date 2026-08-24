export ARCHS = arm64
export TARGET = iphone:clang:latest:16.0
export THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ChatGPTNoUpdate
ChatGPTNoUpdate_FILES = Tweak.x
ChatGPTNoUpdate_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
