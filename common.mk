
include $(EVRYTHNG_MARVELL_SDK_PATH)/config.mk

ifeq ($(NOISY),1)
AT=
else
AT=@
endif

UNTAR=tar --skip-old-files -xf
RMRF=rm -rf
MAKE=make
PATCH=patch -p1 -N -s <
CHDIR=cd
COPY=cp

WMSDK_BUNDLE=$(notdir $(WMSDK_BUNDLE_PATH))
WMSDK_BUNDLE_DIR=$(EVRYTHNG_MARVELL_SDK_PATH)/$(patsubst %.tar.gz,%,$(WMSDK_BUNDLE))
WMSDK_PATH=$(WMSDK_BUNDLE_DIR)/bin/wmsdk

SDK_PATH=$(WMSDK_PATH)
SDK_DIR=$(WMSDK_BUNDLE_DIR)/wmsdk

WMSDK_FW_GENERATOR_DIR=$(SDK_DIR)/tools/src/fw_generator
WMSDK_FW_GENERATOR_BIN=$(SDK_DIR)/tools/bin/fw_generator

ifeq ($(BOARD),mw300)
BOARD_FW_PARTITION=mcufw
BOARD_FILE=$(SDK_PATH)/boards/mw300_rd.c
endif

ifeq ($(BOARD),mc200_8801)
BOARD_FW_PARTITION=mc200fw
endif

export WMSDK_BUNDLE_DIR BOARD SDK_PATH SDK_DIR

ifeq ($(BOARD),mw300)
export BOARD_FILE
endif

.PHONY: wmsdk wmsdk_clean wmsdk_unpack lib lib_clean wmsdk_fw_generator

libevrythng: wmsdk wmsdk_fw_generator
	$(AT)$(MAKE) -C $(EVRYTHNG_MARVELL_SDK_PATH)/lib SDK_PATH=$(WMSDK_PATH) BOARD=$(BOARD)

libevrythng_clean:
	$(AT)$(MAKE) -C $(EVRYTHNG_MARVELL_SDK_PATH)/lib clean SDK_PATH=$(WMSDK_PATH)


wmsdk: wmsdk_unpack 
	$(AT)if [ ! -e $(WMSDK_BUNDLE_DIR)/wmsdk/.config ]; then $(MAKE) -C $(WMSDK_BUNDLE_DIR) $(BOARD)_defconfig; fi;
	$(AT)$(MAKE) -C $(WMSDK_BUNDLE_DIR) BOARD=$(BOARD) sdk

wmsdk_fw_generator: wmsdk
	$(AT)$(MAKE) -C $(WMSDK_FW_GENERATOR_DIR)
	$(AT)$(COPY) $(WMSDK_FW_GENERATOR_DIR)/fw_generator $(WMSDK_FW_GENERATOR_BIN)

wmsdk_clean:
	$(AT)$(RMRF) $(WMSDK_BUNDLE_DIR)

wmsdk_unpack:
	$(AT)$(UNTAR) $(WMSDK_BUNDLE_PATH) -C $(EVRYTHNG_MARVELL_SDK_PATH)
	-$(AT)$(CHDIR) $(EVRYTHNG_MARVELL_SDK_PATH) && $(PATCH) remove_old_evt_lib.patch
	$(AT)$(CHDIR) $(SDK_DIR) && $(RMRF) .config
