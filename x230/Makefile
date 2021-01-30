# references:
# 	- http://www.zerocat.org/projects/coreboot-machines/doc/generated-documentation/html/md_doc_build-coreboot-x230.html
# 	- https://github.com/merge/skulls

# build dependencies:
# 	- gcc-ada

deps = flashrom \
	ifdtool

all: $(deps)

.PHONY: flashrom
flashrom:
	cd ../flashrom && git reset --hard
	cd ../flashrom && git checkout v1.2
	cd ../flashrom && git apply ../patches/libflashrom.patch
	cd ../flashrom && make
	cd ../flashrom && sudo make install

.PHONY: ifdtool
ifdtool:
	cd ../coreboot/util/ifdtool && make
	cd ../coreboot/util/ifdtool && sudo make install

.PHONY: bucts
bucts:
	cd ../coreboot/util/bucts && make

.PHONY: checkconn
checkconn: 
	sudo /usr/local/sbin/flashrom -p linux_spi:dev=/dev/spidev0.0
	sudo /usr/local/sbin/flashrom -p linux_spi:dev=/dev/spidev0.0 -r flash01.bin
	sudo /usr/local/sbin/flashrom -p linux_spi:dev=/dev/spidev0.0 -r flash02.bin
	sudo /usr/local/sbin/flashrom -p linux_spi:dev=/dev/spidev0.0 -r flash03.bin
	md5sum flash01.bin flash02.bin flash03.bin

.PHONY: splitfirmware
splitfirmware:
	cd ./bios && ifdtool -x original_dump.bin

.PHONY: coreboot
coreboot:
	cd ../coreboot && git submodule update --init --recursive
	cd ../coreboot/3rdparty && git clone https://review.coreboot.org/blobs
	cd ../coreboot && mkdir -p 3rdparty/blobs/mainboard/lenovo/x230
	cp bios/* ../coreboot/3rdparty/blobs/mainboard/lenovo/x230
	cd ../coreboot && make crossgcc-i386 CPUS=6

.PHONY: cleanme
cleanme:
	cd bios && python ../../me_cleaner/me_cleaner.py -t -r me.bin -O out.bin

flash: checkconn splitfirmware
	make checkconn

