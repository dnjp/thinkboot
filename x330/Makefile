# references:
# 	- http://www.zerocat.org/projects/coreboot-machines/doc/generated-documentation/html/md_doc_build-coreboot-x230.html
# 	- https://github.com/merge/skulls

# build dependencies:
# 	- gcc-ada (gnat-8 in debian repos)
# 	- libpci (libpci-dev in debian repos)
# 	- libusb-1.0 (libusb-1.0 in debian repos)
# 	- rename (rename in debian repos)

##############################
#         Process
##############################
# 1. flashroom
# 2. ifdtool
# 3. coreboot_init
# 4. findchips_ch341a (top chip)
#    - update chip names
# 5. findchips_ch341a (bottom chip)
#    - update chip names
# 6. findchips_ch341a (bottom chip)
# 7. backup_top_ch341a
# 8. verify_top_ch341a
# 9. backup_bottom_ch341a
# 10. verify_bottom_ch341a
# 11. extract_blobs
# 12. coreboot_config
# 13. show_options (make changes if necessary)
# 14. splitrom
# 15. flash_top
# 16. flash_bottom

deps = flashrom \
	ifdtool \
	coreboot_init

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

.PHONY: nvramtool
nvramtool:
	cd ../coreboot/util/nvramtool && make
	cd ../coreboot/util/nvramtool && sudo make install

.PHONY: coreboot
coreboot_init:
	cd ./../coreboot && git clean -xfd
	cd ./../coreboot && git submodule foreach --recursive git clean -xfd
	cd ./../coreboot && git reset --hard
	cd ./../coreboot && git submodule foreach --recursive git reset --hard
	cd ./../coreboot && git submodule update --init --recursive
	cd ./../coreboot && git checkout master && git pull
	cd ./../coreboot && git checkout 4.13
	cd ./../coreboot && \
		git fetch https://review.coreboot.org/coreboot refs/changes/50/28950/12 && \
		git cherry-pick FETCH_HEAD
	cd ./../coreboot && git submodule update --init --recursive
	cd ../coreboot && make crossgcc CPUS=8

.PHONY: coreboot_config
coreboot_config:
	cp config ../coreboot/.config
	cp -r extra ../coreboot/extra
	cd ../coreboot && make

.PHONY: findchips_ch341a
findchips_ch341a:
	sudo /usr/local/sbin/flashrom -p ch341a_spi
	# top:    MX25L3206E/MX25L3208E
	# bottom: MX25L6406E/MX25L6408E

.PHONY: backup_top_ch341a
backup_top_ch341a:
	sudo /usr/local/sbin/flashrom -p ch341a_spi -r bios/factory_top_1.bin -c "MX25L3206E/MX25L3208E"
	sudo /usr/local/sbin/flashrom -p ch341a_spi -r bios/factory_top_2.bin -c "MX25L3206E/MX25L3208E"
.PHONY: verify_top_ch341a
verify_top_ch341a:
	sudo /usr/local/sbin/flashrom -p ch341a_spi --verify bios/factory_top_1.bin -c "MX25L3206E/MX25L3208E"
	sudo /usr/local/sbin/flashrom -p ch341a_spi --verify bios/factory_top_2.bin -c "MX25L3206E/MX25L3208E"
	sha512sum bios/factory_top*
.PHONY: backup_bottom_ch341a
backup_bottom_ch341a:
	sudo /usr/local/sbin/flashrom -p ch341a_spi -r bios/factory_bottom_1.bin -c "MX25L6406E/MX25L6408E"
	sudo /usr/local/sbin/flashrom -p ch341a_spi -r bios/factory_bottom_2.bin -c "MX25L6406E/MX25L6408E"
.PHONY: verify_bottom_ch341a
verify_bottom_ch341a:
	sudo /usr/local/sbin/flashrom -p ch341a_spi --verify bios/factory_bottom_1.bin -c "MX25L6406E/MX25L6408E"
	sudo /usr/local/sbin/flashrom -p ch341a_spi --verify bios/factory_bottom_2.bin -c "MX25L6406E/MX25L6408E"
	sha512sum bios/factory_bottom*

.PHONY: rom
rom:
	cat bios/factory_bottom_1.bin bios/factory_top_1.bin > bios/x230-bios.rom

.PHONY: extract_blobs
extract_blobs:
	mkdir -p bios/flashparts
	cd bios/flashparts && ifdtool -x ../x230-bios.rom
	# File x230-bios.rom is 12582912 bytes
	#   Flash Region 0 (Flash Descriptor): 00000000 - 00000fff
	#   Flash Region 1 (BIOS): 00500000 - 00bfffff
	#   Flash Region 2 (Intel ME): 00003000 - 004fffff
	#   Flash Region 3 (GbE): 00001000 - 00002fff
	#   Flash Region 4 (Platform Data): 00fff000 - 00000fff (unused)

	cp bios/flashparts/flashregion*.bin ../coreboot/3rdparty/blobs/mainboard/lenovo/x230/

	# Strip the first 14 characters from the filename (flashregion_#_)
	cd ../coreboot/3rdparty/blobs/mainboard/lenovo/x230/ && rename 's/.{14}//' *.bin
	cd ../coreboot/3rdparty/blobs/mainboard/lenovo/x230/ && mv flashdescriptor.bin descriptor.bin
	cd ../coreboot/3rdparty/blobs/mainboard/lenovo/x230/ && mv intel_me.bin me.bin

.PHONY: splitfirmware
splitfirmware:
	cd ./bios && ifdtool -x original_dump.bin

.PHONY: show_options
show_options:
	sudo nvramtool -C ../coreboot/build/coreboot.rom -a

.PHONY: splitrom
splitrom:
	cd ../coreboot/build && dd if=coreboot.rom of=coreboot-bottom.rom bs=1M count=8
	cd ../coreboot/build && dd if=coreboot.rom of=coreboot-top.rom bs=1M skip=8

.PHONY: flash_top
flash_top:

		
	time sudo flashrom --chip "MX25L3206E/MX25L3208E" --programmer ch341a_spi --write ../coreboot/build/coreboot-top.rom

.PHONY: flash_bottom
flash_bottom:
	
	time sudo flashrom --chip "MX25L6406E/MX25L6408E" --programmer ch341a_spi --write ../coreboot/build/coreboot-bottom.rom

.PHONY: cleanme
cleanme:
	cd bios && python ../../me_cleaner/me_cleaner.py -t -r ../coreboot/3rdparty/blobs/mainboard/lenovo/x230/me.bin -O out.bin

