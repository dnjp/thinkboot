deps = flashrom \
	coreboot

all: $(deps)

.PHONY: flashrom
flashrom:
	cd ./flashrom && git reset --hard
	cd ./flashrom && git checkout v1.2
	cd ./flashrom && git apply ../libflashrom.patch
	cd ./flashrom && make
	cd ./flashrom && sudo make install

.PHONY: ifdtool
ifdtool:
	cd coreboot/util/ifdtool && make
	cd coreboot/util/ifdtool && sudo make install

.PHONY: coreboot
coreboot:
	cd ./coreboot && git submodule update --init --recursive

.PHONY: checkconn
checkconn: 
	sudo /usr/local/sbin/flashrom -p linux_spi:dev=/dev/spidev0.0
	sudo /usr/local/sbin/flashrom -p linux_spi:dev=/dev/spidev0.0 -r flash01.bin
	sudo /usr/local/sbin/flashrom -p linux_spi:dev=/dev/spidev0.0 -r flash02.bin
	sudo /usr/local/sbin/flashrom -p linux_spi:dev=/dev/spidev0.0 -r flash03.bin
	md5sum flash01.bin flash02.bin flash03.bin

.PHONY: splitfirmware
splitfirmware:
	ifdtool -x original_dump.bin

.PHONY: cleanme
cleanme:
	python ./me_cleaner/me_cleaner.py -t -r me.bin -O out.bin

flash: checkconn splitfirmware
	make checkconn
