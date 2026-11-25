#
# Copyright (C) 2018 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

BOARD_FLASH_BLOCK_SIZE             := 4096
BOARD_BOOTIMAGE_PARTITION_SIZE     := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 16777216
# The lineage-20 recovery ramdisk is 11 MB with gzip; kernel plus ramdisk
# exceed the 16 MB SOS partition. The kernel has CONFIG_RD_XZ.
BOARD_RAMDISK_USE_XZ := true
BOARD_CACHEIMAGE_PARTITION_SIZE    := 1073741824
BOARD_USERDATAIMAGE_PARTITION_SIZE := 12799754240
BOARD_SYSTEMIMAGE_PARTITION_SIZE   := 1342177280
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE  := ext4
TARGET_USERIMAGES_USE_EXT4         := true

# Assert
TARGET_OTA_ASSERT_DEVICE := shieldtablet,loki,ardbeg,jetson-tk1

# Audio
USE_XML_AUDIO_POLICY_CONF := 1

# Bluetooth
ifeq ($(TARGET_TEGRA_BT),bcm)
BOARD_CUSTOM_BT_CONFIG  := device/nvidia/shieldtablet/comms/vnd_shieldtablet.txt
BCM_BLUETOOTH_MANTA_BUG := true
BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/nvidia/shieldtablet/comms
endif

# Bootloader versions
TARGET_BOARD_INFO_FILE := device/nvidia/shieldtablet/board-info.txt

# Fingerprint override
BUILD_FINGERPRINT := nvidia/wx_un_do/shieldtablet:7.0/NRD90M/1928188_1038.3875:user/release-keys

# Forced shims
# glgps imports SSLv3_client_method, which BoringSSL no longer has, and uses
# SensorManager without listing libsensor (it was part of libgui when the blob
# was built)
TARGET_LD_SHIM_LIBS := \
    /system/vendor/bin/glgps_nvidiaTegra2android|/system/vendor/lib/libgps_shim.so:/system/vendor/bin/glgps_nvidiaTegra2android|/system/lib/libsensor.so

# Kernel
ifneq ($(TARGET_PREBUILT_KERNEL),)
BOARD_VENDOR_KERNEL_MODULES += $(wildcard $(dir $(TARGET_PREBUILT_KERNEL))/*.ko)
else
TARGET_KERNEL_SOURCE    := kernel/nvidia/shield
TARGET_KERNEL_CONFIG    := tegra12_android_defconfig
BOARD_KERNEL_IMAGE_NAME := zImage
BOARD_KERNEL_CMDLINE    := vmalloc=450M
# Fixed user/host in /proc/version instead of the builder's login and the
# build container's random hostname
TARGET_KERNEL_ADDITIONAL_FLAGS := KBUILD_BUILD_USER=damnms KBUILD_BUILD_HOST=lineageos
# The 3.10 kernel is built with GCC 4.9 as on 18.1; lineage-20 defaults to clang.
TARGET_KERNEL_CLANG_COMPILE := false
endif

# Legacy memfd
TARGET_HAS_MEMFD_BACKPORT := true

# Mount point for the RP3 calibration partition (fstab.tn8, init.cal.rc)
BOARD_ROOT_EXTRA_FOLDERS += usercalib

# Recovery
LZMA_RAMDISK_TARGETS  := recovery
TARGET_RECOVERY_FSTAB := device/nvidia/shieldtablet/initfiles/fstab.tn8

# Releasetools
TARGET_RELEASETOOLS_EXTENSIONS := device/nvidia/shieldtablet/releasetools

# TWRP Support
ifeq ($(WITH_TWRP),true)
include device/nvidia/shieldtablet/twrp/twrp.mk
endif

include device/nvidia/t124-common/BoardConfigCommon.mk
include device/nvidia/icera/BoardConfigIcera.mk
include device/nvidia/touch/BoardConfigTouch.mk

# Wifi firmware mode (after BoardConfigTegra.mk, which sets the param to
# /data/vendor/wifi/fw_path). bcmdhd only brings the firmware up as SoftAP
# when op_mode is 2 (DHD_FLAG_HOSTAP_MODE); wifi_loader.sh does not link
# that file to the module parameter here (bcmdhd_wlan is disabled in the
# device tree), so the hotspot never sent beacons. The wifi HAL writes the
# value before every STA/AP chip mode change; STA must go back to 0, or the
# driver crashes adding the p2p device in SoftAP mode.
WIFI_DRIVER_FW_PATH_PARAM := "/sys/module/bcmdhd/parameters/op_mode"
WIFI_DRIVER_FW_PATH_STA   := "0"
WIFI_DRIVER_FW_PATH_AP    := "2"

# The Raydium touch libraries (and libx.so) reach the recovery ramdisk through
# PRODUCT_COPY_FILES, which Android 13 rejects for ELF files. Allowed until
# they become prebuilt modules.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
