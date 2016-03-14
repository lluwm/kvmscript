#!/bin/bash

BASE_FOLDER="/home/llei/kvm/decouple"
LINUX="linux-4.3.3"
LINUX_FOLDER=$BASE_FOLDER"/"$LINUX

ARCH_X86_KVM=$LINUX_FOLDER"/arch/x86/kvm"
ARCH_X86_KVM2=$LINUX_FOLDER"/arch/x86/kvm2"

VIRT_KVM=$LINUX_FOLDER"/virt/kvm"
VIRT_KVM2=$LINUX_FOLDER"/virt/kvm2"

# Handle source files
ARCH_X86_KVM2_FILES=`ls $ARCH_X86_KVM2 | grep '\.h\|\.c'`

for eachfile in $ARCH_X86_KVM2_FILES ; do
	filepath=$ARCH_X86_KVM2"/"$eachfile
	KVM2_IS_REPLACED_IN_FILE=`grep 'KVM2' $filepath``grep 'kvm2' $filepath`
	if [[ ! $KVM2_IS_REPLACED_IN_FILE ]]; then
		 sed 's/KVM/KVM2/g' -i $filepath
		 sed 's/kvm/kvm2/g' -i $filepath
	fi
done

# Handle source files
VIRT_KVM2_FILES=`ls $VIRT_KVM2 | grep '\.h\|\.c'`

for eachfile in $VIRT_KVM2_FILES ; do
	filepath=$VIRT_KVM2"/"$eachfile
	KVM2_IS_REPLACED_IN_FILE=`grep 'KVM2' $filepath``grep 'kvm2' $filepath`
	if [[ ! $KVM2_IS_REPLACED_IN_FILE ]]; then
		 sed 's/KVM/KVM2/g' -i $filepath
		 sed 's/kvm/kvm2/g' -i $filepath
	fi
done
