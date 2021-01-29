#
# Copyright (c) 2021 XdevL. All rights reserved.
#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.
#
ifneq ($(PREBUILT_BOOTLOADER),)
LOCAL_PATH := $(dir $(PREBUILT_BOOTLOADER))
$(call add-radio-file,$(notdir $(PREBUILT_BOOTLOADER)))
endif

THIS_LOCAL_PATH := $(call my-dir)

# see /build/core/Makefile
FILE_NAME_TAG := eng.$(USER)
TARGET = $(call intermediates-dir-for,PACKAGING,target_files)/$(TARGET_PRODUCT)-target_files-*.zip

IMG := $(PRODUCT_OUT)/$(TARGET_PRODUCT)-img-$(FILE_NAME_TAG).zip

factory_distribution: $(IMG) target-files-package
	@cp $(TARGET) $(PRODUCT_OUT)
	$(THIS_LOCAL_PATH)/generate-factory-images.sh $(TARGET_DEVICE) $(TARGET_PRODUCT) $(FILE_NAME_TAG) \
	$(notdir $(PREBUILT_BOOTLOADER)) $(PREBUILT_BOOTLOADER_VERSION) $(PRODUCT_OUT)/
	
ota_distribution: target-files-package
	build/tools/releasetools/ota_from_target_files --block $(TARGET) $(PRODUCT_OUT)/$(TARGET_PRODUCT)-ota_update-$(FILE_NAME_TAG).zip

SIGNED_TARGET := $(PRODUCT_OUT)/signed-$(TARGET_PRODUCT)-target_files-$(FILE_NAME_TAG).zip

$(SIGNED_TARGET): target-files-package
	build/tools/releasetools/sign_target_files_apks -o -d $(THIS_LOCAL_PATH)/security $(TARGET) $(SIGNED_TARGET)

SIGNED_IMG := $(PRODUCT_OUT)/signed-$(TARGET_PRODUCT)-img-$(FILE_NAME_TAG).zip

$(SIGNED_IMG): $(SIGNED_TARGET)
	build/tools/releasetools/img_from_target_files $(SIGNED_TARGET) $(SIGNED_IMG)
	
signed_factory_distribution: $(SIGNED_IMG)
	@cp $(TARGET) $(PRODUCT_OUT)
	$(THIS_LOCAL_PATH)/generate-factory-images.sh $(TARGET_DEVICE) $(TARGET_PRODUCT) $(FILE_NAME_TAG) \
	$(notdir $(PREBUILT_BOOTLOADER)) $(PREBUILT_BOOTLOADER_VERSION) $(PRODUCT_OUT)/signed-

signed_ota_distribution: $(SIGNED_TARGET)
	build/tools/releasetools/ota_from_target_files --block $(SIGNED_TARGET) $(PRODUCT_OUT)/$(TARGET_PRODUCT)-signed-ota_update-$(FILE_NAME_TAG).zip
	
all_distributions: ota_dist factory_dist
