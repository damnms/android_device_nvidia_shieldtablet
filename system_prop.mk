# Smartdimmer
PRODUCT_PROPERTY_OVERRIDES += \
    persist.tegra.didim.enable = 1 \
    persist.tegra.didim.video = 5 \
    persist.tegra.didim.normal = 3

# Composer: the nvidia HWC1 glcomposer binds its GL context to one thread
# (EGL_BAD_ACCESS and "Intermediate composition failed" otherwise)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.hwc.rpc_threads=1

# Composer: the nvidia HWC1 never closes the framebuffer target fence, let
# the hwc2on1adapter close it after set() (one fd leak per GPU frame and a
# FD_SET abort on HDMI hotplug otherwise)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.hwc.close_fbt_fence=true

# Composer: the nvidia HWC1 glitches on the rotated panel while HDMI shows
# the same buffers as overlays; compose the panel on the GPU meanwhile
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.hwc.client_primary_with_external=true

# Composer: the nvidia HWC1 shows buffers of SurfaceControl layers
# (Chromium's child surface) garbled as overlays; compose them on the GPU
PRODUCT_PROPERTY_OVERRIDES += \
    debug.sf.client_composition_buffer_state=1

# Camera: the nvidia HAL never closes the buffer acquire fences, let the
# passthrough wrapper wait for them (one fd leak per buffer otherwise)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.camera.wait_acquire_fences=true

# GPS: android.hardware.gnss@1.0-impl loads the legacy module gps.brcm
# (set by gps_select.sh in the stock firmware)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware.gps=brcm

# Zygote: do not preload the nvidia GL stack. Otherwise zygote keeps
# /dev/nvhost-ctrl open, webview_zygote inherits it, may not stat it
# (gpu_device neverallow) and aborts with "Unable to stat".
PRODUCT_PROPERTY_OVERRIDES += \
    ro.zygote.disable_gl_preload=1

# Updater: own OTA list instead of download.lineageos.org.
# {device} is replaced by the Updater; keeps the value below 91 bytes.
PRODUCT_SYSTEM_DEFAULT_PROPERTIES += \
    lineage.updater.uri=https://raw.githubusercontent.com/damnms/android_releases_{device}/main/{device}.json

# eBPF: the kernel (branch shieldtablet-ebpf) carries the eBPF and cgroup
# BPF backport; let bpfloader and netd use it on this pre-P launch device.
# Only ship together with that kernel: without bpf() bpfloader fails and
# reboot_on_failure loops the boot.
PRODUCT_PROPERTY_OVERRIDES += \
    ro.kernel.ebpf.supported=true
