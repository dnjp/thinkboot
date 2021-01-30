# references:
# 	- http://www.zerocat.org/projects/../coreboot-machines/doc/generated-documentation/html/md_doc_build-../coreboot-x230.html
# 	- https://github.com/merge/skulls

# build dependencies:
# 	- gcc-ada

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
	cd ./../coreboot && git submodule update --init --recursive
	cp config ../coreboot/.config
	cd ../coreboot && make crossgcc-i386 CPUS=2
	cd ../coreboot && make

.PHONY: run
run:
	flashrom --programmer internal -r backup.rom
	flashrom --programmer internal --verify backup.rom
	cd ../coreboot/util/bucts && ./bucts --set
	flashrom --programmer internal \
		--write ../coreboot/build/coreboot.rm \
		--layout x60_layout \
		--image RW

.PHONY: corebootsettings
corebootsettings:
	cd ../coreboot/util/nvramtool && make
	cd ../coreboot/util/nvramtool && ./nvramtool \
		-y ../../src/mainboard/lenovo/x60/cmos.layout \
		-p ../../src/mainboard/lenovo/x60/cmos.default

