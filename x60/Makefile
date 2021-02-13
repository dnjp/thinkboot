# references:
# 	- http://www.zerocat.org/projects/../coreboot-machines/doc/generated-documentation/html/md_doc_build-../coreboot-x230.html
# 	- https://github.com/merge/skulls

# build dependencies:
# 	- gcc-ada
# m4
# bison
# flex

deps = bucts \
	flashrom \
	coreboot

all: $(deps)

.PHONY: flashrom
flashrom:
	cd ../flashrom && git reset --hard
	cd ../flashrom && git checkout v1.2
	cd ../flashrom && git apply ../patches/libflashrom.patch
	cd ../flashrom && patch -p0 < ../patches/lenovobios_sst.diff
	cd ../flashrom && patch -p0 < ../patches/lenovobios_macronix.diff
	cd ../flashrom && make
	cd ../flashrom && sudo make install

.PHONY: bucts
bucts:
	cd ../coreboot/util/bucts && make

.PHONY: coreboot
coreboot:
	cd ./../coreboot && git clean -fdx
	cd ./../coreboot && git checkout 4.13
	cd ./../coreboot && git submodule update --init --recursive
	cp config ../coreboot/.config
	cd ../coreboot && make crossgcc-i386 CPUS=2
	cd ../coreboot && make

.PHONY: backup
backup:
	sudo /usr/local/sbin/flashrom --programmer internal -r bios/cur_1.bin
	sudo /usr/local/sbin/flashrom --programmer internal -r bios/cur_2.bin
	sudo /usr/local/sbin/flashrom --programmer internal --verify bios/cur_1.bin
	sudo /usr/local/sbin/flashrom --programmer internal --verify bios/cur_2.bin
	sha512sum bios/cur*

.PHONY: findchips_ch341a
findchips_ch341a:
	sudo /usr/local/sbin/flashrom -p ch341a_spi

.PHONY: backup_ch341a
backup_ch341a:
	sudo /usr/local/sbin/flashrom -p ch341a_spi -r bios/cur_1.bin -c SST25VF016B
	sudo /usr/local/sbin/flashrom -p ch341a_spi -r bios/cur_2.bin -c SST25VF016B
	sudo /usr/local/sbin/flashrom -p ch341a_spi --verify bios/cur_1.bin
	sudo /usr/local/sbin/flashrom -p ch341a_spi --verify bios/cur_2.bin
	sha512sum bios/cur*

.PHONY: run
run:
	cd ../coreboot/util/bucts && sudo ./bucts --set
	sudo flashrom --programmer internal \
		--write ../coreboot/build/coreboot.rom \
		--layout x60_layout \
		--image RW

.PHONY: run_ch341a
run_ch341a:
	time sudo /usr/local/sbin/flashrom \
		--chip SST25VF016B \
		--programmer ch341a_spi \
		--write ../coreboot/build/coreboot.rom

.PHONY: restore_ch341a
restore_ch341a:
	time sudo /usr/local/sbin/flashrom \
		--chip SST25VF016B \
		--programmer ch341a_spi \
		--write bios/cur_1.bin


.PHONY: corebootsettings
corebootsettings:
	cd ../coreboot/util/nvramtool && make
	cd ../coreboot/util/nvramtool && sudo ./nvramtool \
		-y ../../src/mainboard/lenovo/x60/cmos.layout \
		-p ../../src/mainboard/lenovo/x60/cmos.default

