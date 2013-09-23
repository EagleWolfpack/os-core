#!/usr/bin/make -f

_busybox: Sources/busybox.config
	cp Sources/busybox.config Sources/busybox/.config
	cd Sources/busybox && \
	CONFIG_PREFIX="../../rootfs" CFLAGS="-m32" LDFLAGS="-m32" make install

_rootfs: rootfs/bin/busybox
	-mkdir -p Image-new/boot/syslinux
	( cd rootfs && find . | sudo cpio -H newc -ov | gzip -9v ) > Image-new/boot/syslinux/initrd.gz

# CROSS = false
export KVERS = 3.9.10

x86 = CFLAGS="-m32" LDFLAGS="-m32" ARCH="i386"
x86_64 = CFLAGS="-m64" LDFLAGS="-m64" ARCH="x86_64"



_kernel: Sources/kernel.config
	 cp Sources/kernel.config Kernel/linux-$(KVERS)/.config
	 cd Kernel/linux-$(KVERS) && \
	 $(x86) make oldconfig && \
	 $(x86) make -j8 && \
	 cp arch/x86/boot/bzImage ../../Image-new/boot/syslinux/linux

_kernel64: Sources/kernel.config
	 cp Sources/kernel.config Kernel/linux-$(KVERS)/.config
	 cd Kernel/linux-$(KVERS) && \
	 $(x86_64) make oldconfig && \
	 $(x86_64) make -j8 && \
	 cp arch/x86/boot/bzImage ../../Image-new/boot/syslinux/linux

#PHONY

_clean:
	-rm -rf ./Image-new

_image: 
	Scripts/OTC.mkimage Image-new

_dev2: _busybox _rootfs _kernel
		scp Image-new/boot/syslinux/linux root@otc-dd-dev2:/opt/openthinclient/server/default/data/nfs/root/tftp/vmlinuz
		scp Image-new/boot/syslinux/initrd.gz root@otc-dd-dev2:/opt/openthinclient/server/default/data/nfs/root/tftp/initrd.img

_dev2-nobuild: 
		scp Image-new/boot/syslinux/linux root@otc-dd-dev2:/opt/openthinclient/server/default/data/nfs/root/tftp/vmlinuz
		scp Image-new/boot/syslinux/initrd.gz root@otc-dd-dev2:/opt/openthinclient/server/default/data/nfs/root/tftp/initrd.img

