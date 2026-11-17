# Smartdimmer
PRODUCT_PROPERTY_OVERRIDES += \
    persist.tegra.didim.enable = 1 \
    persist.tegra.didim.video = 5 \
    persist.tegra.didim.normal = 3

# Updater: own OTA list instead of download.lineageos.org.
# {device} is replaced by the Updater; keeps the value below 91 bytes.
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    lineage.updater.uri=https://raw.githubusercontent.com/damnms/android_releases_{device}/main/{device}.json
