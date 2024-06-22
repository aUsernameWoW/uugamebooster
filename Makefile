# 定义常量和变量
PKG_NAME:=uugamebooster
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
PKG_SOURCE_DIR:=$(PKG_BUILD_DIR)/$(PKG_NAME)-$(UU_ARCH)-bin

# 根据架构设置变量
ARCH=$(subst $(space),,$(shell uname -m))
ifeq ($(ARCH),arm)
  UU_ARCH:=arm
endif
ifeq ($(ARCH),aarch64)
  UU_ARCH:=aarch64
endif
ifeq ($(ARCH),mipsel)
  UU_ARCH:=mipsel
endif
ifeq ($(ARCH),x86_64)
  UU_ARCH:=x86_64
endif

# 获取最新版本和MD5
define GetLatestVersionAndMD5
  $(eval latest_info := $(shell curl -L -s -k -H "Accept:text/plain" "http://router.uu.163.com/api/plugin?type=openwrt-$(UU_ARCH)"))
  $(eval PKG_SOURCE_URL := $(word 1, $(subst ,, $(latest_info))))
  $(eval PKG_MD5SUM := $(word 2, $(subst ,, $(latest_info))))
  $(eval PKG_VERSION := $(word 4, $(subst /, ,$(word 1, $(subst ,, $(latest_info))))))
  $(eval PKG_RELEASE := $(PKG_VERSION))
endef

$(GetLatestVersionAndMD5)

include $(TOPDIR)/rules.mk
include $(INCLUDE_DIR)/package.mk

define Package/uugamebooster
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=Netease
  DEPENDS:=@(aarch64||arm||mipsel||x86_64) +kmod-tun
  TITLE:=NetEase UU Game Booster
  URL:=https://uu.163.com
endef

define Package/uugamebooster/description
  NetEase's UU Game Booster accelerates Triple-A gameplay and market.
endef

PKG_SOURCE:=$(PKG_NAME)-$(UU_ARCH)-$(PKG_VERSION).tar.gz

define Build/Prepare
	$(call Build/Prepare/Default)
	mkdir -p $(PKG_SOURCE_DIR)
	tar -zxvf $(DL_DIR)/$(PKG_SOURCE) -C $(PKG_SOURCE_DIR)
endef

define Build/Compile
	# 编译过程留空
endef

define Package/uugamebooster/install
	$(INSTALL_DIR) $(1)/usr/share/uugamebooster
	$(INSTALL_BIN) $(PKG_SOURCE_DIR)/uuplugin $(1)/usr/share/uugamebooster/uuplugin
	$(INSTALL_CONF) $(PKG_SOURCE_DIR)/uu.conf $(1)/usr/share/uugamebooster/uu.conf
endef

define Package/uugamebooster/conffiles
/root/.uuplugin_uuid
endef

$(eval $(call BuildPackage,uugamebooster))
