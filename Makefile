export ARCHS = arm64 arm64e
export TARGET = iphone:clang:16.5:16.0
export THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = ChatGPTNoUpdate
ChatGPTNoUpdate_FILES = Tweak.x
ChatGPTNoUpdate_CFLAGS = -fobjc-arc
ChatGPTNoUpdate_FRAMEWORKS = UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

BUNDLE_NAME = ChatGPTNoUpdatePrefs
ChatGPTNoUpdatePrefs_FILES = ChatGPTNoUpdatePrefs.m
ChatGPTNoUpdatePrefs_INSTALL_PATH = /Library/PreferenceBundles
ChatGPTNoUpdatePrefs_FRAMEWORKS = UIKit
ChatGPTNoUpdatePrefs_PRIVATE_FRAMEWORKS = Preferences
ChatGPTNoUpdatePrefs_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
