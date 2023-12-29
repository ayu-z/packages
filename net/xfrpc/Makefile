#
# Copyright (C) 2022 Dengfeng Liu
#
# This is free software, licensed under the GNU General Public License v3.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=xfrpc
PKG_VERSION:=2.1.606
PKG_RELEASE:=1
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)_$(PKG_VERSION)
CMAKE_BUILD_DIR:=$(PKG_BUILD_DIR)/build


include $(INCLUDE_DIR)/package.mk
# include $(INCLUDE_DIR)/cmake.mk

define Package/xfrpc
	SUBMENU:=Web Servers/Proxies
	SECTION:=net
	CATEGORY:=Network
	DEPENDS:=+zlib +libjson-c +libevent2 +libevent2-openssl
	TITLE:= C language fast reverse proxy client
	URL:=https://github.com/liudf0716/xfrpc
endef

define Package/xfrpc/description
	xfrpc is C language fast reverse proxy client
	compare with golang version frpc
	xfrpc can run in almost all openwrt device
endef

define Package/xfrpc/conffiles
	/etc/config/xfrpc
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	mkdir -p $(CMAKE_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/ 
endef

define Build/Compile
	cmake -B $(CMAKE_BUILD_DIR) \
		-DTHIRDPARTY_STATIC_BUILD=$(ARCH) \
		-DCMAKE_C_COMPILER=$(TARGET_CC) \
		-DJSON-C_INCLUDE_DIR=$(STAGING_DIR)/usr/include \
		$(PKG_BUILD_DIR) 
	$(MAKE) -C $(CMAKE_BUILD_DIR)
endef


define Package/xfrpc/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(CMAKE_BUILD_DIR)/xfrpc $(1)/usr/bin/
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) ./files/xfrpc.init $(1)/etc/init.d/xfrpc
	$(INSTALL_DIR) $(1)/etc/config
	$(CP) ./files/xfrpc.conf $(1)/etc/config/xfrpc

	# $(INSTALL_DIR) $(1)/etc/init.d
	# $(INSTALL_BIN) ./files/frp.init $(1)/etc/init.d/frp
	# $(INSTALL_DIR) $(1)/etc/config
	# $(CP) ./files/frp.conf $(1)/etc/config/frp
endef

$(eval $(call BuildPackage,xfrpc))