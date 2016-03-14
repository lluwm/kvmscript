#!/bin/bash

BASE_FOLDER="/home/llei/kvm/decouple"
LINUX="linux-4.3.3"
LINUX_FOLDER=$BASE_FOLDER"/"$LINUX

ARCH_X86_KVM=$LINUX_FOLDER"/arch/x86/kvm"
ARCH_X86_KVM2=$LINUX_FOLDER"/arch/x86/kvm2"

VIRT_KVM=$LINUX_FOLDER"/virt/kvm"
VIRT_KVM2=$LINUX_FOLDER"/virt/kvm2"

# cp arch/x86/kvm to arch/x86/kvm2
if [ ! -d $ARCH_X86_KVM2 ]; then
	cp -r $ARCH_X86_KVM $ARCH_X86_KVM2
fi

# cp virt/kvm to virt/kvm2
if [ ! -d $VIRT_KVM2 ]; then
	cp -r $VIRT_KVM $VIRT_KVM2
fi

######################################
# Change source file name if has kvm #
######################################
# Handle ./arch/x86/include/asm/  kvm header files
ARCH_X86_KVM2_FILES=`ls $ARCH_X86_KVM2|grep 'kvm' | grep -v 'kvm2'`

for eachfile in $ARCH_X86_KVM2_FILES ; do
	newname=${eachfile/kvm/kvm2}
	filepath=$ARCH_X86_KVM2"/"$eachfile
	newfilepath=$ARCH_X86_KVM2"/"$newname

	if [ ! -e $newfilepath ]; then
		echo "mv $filepath $newfilepath"
		mv $filepath $newfilepath
	fi
done

VIRT_KVM2_FILES=`ls $VIRT_KVM2 | grep 'kvm' | grep -v 'kvm2'`

for eachfile in $VIRT_KVM2_FILES ; do
	newname=${eachfile/kvm/kvm2}
	filepath=$VIRT_KVM2"/"$eachfile
	newfilepath=$VIRT_KVM2"/"$newname

	if [ ! -e $newfilepath ]; then
		echo "mv $filepath $newfilepath"
		mv $filepath $newfilepath
	fi
done
###############################
# edit arch/x86/kvm2/Makefile #
###############################

ARCH_X86_KVM2_MAKEFILE=$ARCH_X86_KVM2"/Makefile"

# -Iarch/x86/kvm -> -Iarch/x86/kvm2
#sed 's/-Iarch\/x86\/kvm$/-Iarch\/x86\/kvm2/g' -i $ARCH_X86_KVM2_MAKEFILE

#../../../virt/kvm -> ../../../virt/kvm2
#sed 's/..\/..\/..\/virt\/kvm$/..\/..\/..\/virt\/kvm2/g' -i $ARCH_X86_KVM2_MAKEFILE

# kvm-y -> kvm2-y
#sed 's/kvm-y/kvm2-y/g' -i $ARCH_X86_KVM2_MAKEFILE

# kvm-$(CONFIG_KVM_ASYNC_PF) -> kvm2-$(CONFIG_KVM_ASYNC_PF)
#sed 's/kvm-$(CONFIG_KVM_ASYNC_PF)/kvm2-$(CONFIG_KVM_ASYNC_PF)/g' -i $ARCH_X86_KVM2_MAKEFILE

# kvm-$(CONFIG_KVM_DEVICE_ASSIGNMENT) -> kvm2-$(CONFIG_KVM_DEVICE_ASSIGNMENT)
#sed 's/kvm-$(CONFIG_KVM_DEVICE_ASSIGNMENT)/kvm2-$(CONFIG_KVM_DEVICE_ASSIGNMENT)/g' -i $ARCH_X86_KVM2_MAKEFILE

# kvm-intel-y -> kvm2-intel-y
#sed 's/kvm-intel-y/kvm2-intel-y/g' -i $ARCH_X86_KVM2_MAKEFILE

# kvm-amd-y -> kvm2-amd-y
#sed 's/kvm-amd-y/kvm2-amd-y/g' -i $ARCH_X86_KVM2_MAKEFILE

# kvm.o -> kvm2.o
#sed 's/kvm.o/kvm2.o/g' -i $ARCH_X86_KVM2_MAKEFILE

# kvm-intel.o -> kvm2-intel.o
#sed 's/kvm-intel.o/kvm2-intel.o/g' -i $ARCH_X86_KVM2_MAKEFILE

# KVM -> KVM2
KVM2_IS_REPLACED_IN_MAKEFILE=`grep 'KVM2' $ARCH_X86_KVM2_MAKEFILE`
if [[ ! $KVM2_IS_REPLACED_IN_MAKEFILE ]]; then
	sed 's/KVM/KVM2/g' -i $ARCH_X86_KVM2_MAKEFILE
	sed 's/kvm/kvm2/g' -i $ARCH_X86_KVM2_MAKEFILE
fi


##################################
# edit .config -- not going work #
##################################
#CONFIG_FILE=$LINUX_FOLDER"/.config"

#KVM2_IS_REPLACED_IN_CONFIG=`grep 'KVM2' $CONFIG_FILE`

#if [[ ! $KVM2_IS_REPLACED_IN_CONFIG_FILE ]]; then
#	awk ' BEGIN { toappend = ""}
#		/KVM/ && !/CONFIG_KVM_GUEST/ {
#			temp = sub(/KVM/, "KVM2", $0)
#			toappend = toappend "" $0 "\n"
#		}
#		END {
#			print toappend
#		}
#	' $CONFIG_FILE >> $CONFIG_FILE
#fi


################
# edit Kconfig #
################

ARCH_X86_KCONFIG_FILE=$LINUX_FOLDER"/arch/x86/Kconfig"
ARCH_X86_KVM2_KCONFIG_FILE=$LINUX_FOLDER"/arch/x86/kvm2/Kconfig"
VIRT_KVM2_KCONFIG_FILE=$LINUX_FOLDER"/virt/kvm2/Kconfig"

#append 'select HAVE_KVM2' after 'select HAVE_KVM'
KVM2_IS_REPLACED_IN_ARCH_X86_KCONFIG_FILE=`grep 'KVM2' $ARCH_X86_KCONFIG_FILE`
if [[ ! $KVM2_IS_REPLACED_IN_X86_KCONFIG_FILE ]]; then
	sed '/select HAVE_KVM/a\
    select HAVE_KVM2' -i  $ARCH_X86_KCONFIG_FILE
    sed '/source "arch\/x86\/kvm\/Kconfig"/a\
	source "arch\/x86\/kvm2\/Kconfig"' -i $ARCH_X86_KCONFIG_FILE
fi

#handle arch/x86/kvm2/Kconfig
KVM2_IS_REPLACED_IN_ARCH_X86_KVM2_KCONFIG_FILE=`grep 'KVM2' $ARCH_X86_KVM2_KCONFIG_FILE`
if [[ ! $KVM2_IS_REPLACED_IN_X86_KVM2_KCONFIG_FILE ]]; then
    # arch/x86/kvm2/Kconfig
    # source "virt/kvm/Kconfig" -> source "virt/kvm2/Kconfig"
	sed 's/virt\/kvm\/Kconfig/virt\/kvm2\/Kconfig/g' -i $ARCH_X86_KVM2_KCONFIG_FILE
	sed 's/menuconfig VIRTUALIZATION/menuconfig VIRTUALIZATION2/g' -i $ARCH_X86_KVM2_KCONFIG_FILE
	sed 's/bool "Virtualization"/bool "Virtualization2"/g' -i $ARCH_X86_KVM2_KCONFIG_FILE
	sed 's/if VIRTUALIZATION/if VIRTUALIZATION2/g' -i $ARCH_X86_KVM2_KCONFIG_FILE
	sed 's/KVM/KVM2/g' -i $ARCH_X86_KVM2_KCONFIG_FILE
fi

#handle virt/kvm2/Kconfig
KVM2_IS_REPLACED_IN_VIRT_KVM2_KCONFIG_FILE=`grep 'KVM2' $VIRT_KVM2_KCONFIG_FILE`
if [[ ! $KVM2_IS_REPLACED_IN_VIRT_KVM2_KCONFIG_FILE ]]; then
	sed 's/KVM/KVM2/g' -i $VIRT_KVM2_KCONFIG_FILE
fi

#make menuconfig to generate .config file

