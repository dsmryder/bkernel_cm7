###################################################
#build.sh -                                       #
#Shell script to build the froyo kernel for the   #
#Motorola Triumph and zip it into a CWM flashable #
#package                                          #
#                                                 #
#Written by shane87                               #
#Modified by b_randon14                           #
###################################################

#This part exports the variables needed by the build script in order to build the kernel correctly
export ARCH=arm
#This is the kernel version that will be appended to the default kernel version
export KBUILD_BUILD_VERSION="v2.3"
#This is the name that the CWM flashable zip will be named as, MUST END WITH .zip!!
KERNELZIP_VERSION=bKernel-CM7-2.3.zip

#This exports the path to you toolchain, and it currently setup for the linaro 4.6 android toolchain found at www.linaro.org
export CROSS_COMPILE=/home/`whoami`/android-toolchain-eabi/bin/arm-eabi-

#This section cleans out the build directory to ensure a good build
make clean

#This section initiates the build process, and it is optimized to read the processor infor of your system and build as many things 
#as it can at one time to speed the make process up
make -j`grep 'processor' /proc/cpuinfo | wc -l`

#This next section is where it take the zImage(compressed kernel image) and combines it with the init ramdisk created and packages it as a boot.img
#and then puts it into the flashable zip file.
cd releasetools
rm -f *.img
cp ../arch/arm/boot/zImage zImage
../tools/bootimg/mkbootfs ../usr/initram-files | gzip > ramdisk.gz
../tools/bootimg/mkbootimg --kernel zImage --ramdisk ramdisk.gz --cmdline "console=ttyMSM1 androidboot.hardware=qcom" -o boot.img --base 0x00200000
rm -f zImage
rm -f *.gz
rm -f *.zip
zip -r $KERNELZIP_VERSION *
cd ..
echo "Finished building bKernel. Please flash the zip through CWM to test it!"
echo "Always remember to make a nandroid backup!"
unset ARCH
