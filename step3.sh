
BASE_FOLDER="/home/llei/kvm/decouple"
LINUX="linux-4.3.3"
LINUX_FOLDER=$BASE_FOLDER"/"$LINUX

#arg1 = headers
#arg2 = base path

function copy_kvm_header_and_replace_contents () {
	headers=$1
	base=$2
	for eachfile in $headers ; do
		newname=${eachfile/kvm/kvm2}
		filepath=$base"/"$eachfile
		newfilepath=$base"/"$newname
		if [ ! -e $newfilepath ]; then
			echo "cp $filepath $newfilepath"
			cp $filepath $newfilepath
			sed 's/kvm/kvm2/g' -i $newfilepath
			sed 's/KVM/KVM2/g' -i $newfilepath
		fi
	done
}

# Handle ./arch/x86/include/asm/  kvm header files
ARCH_X86_INCLUDE_ASM=$LINUX_FOLDER"/arch/x86/include/asm"
ARCH_X86_INCLUDE_ASM_KVM_HEADERS=`ls $ARCH_X86_INCLUDE_ASM|grep 'kvm' | grep -v 'kvm2'`

copy_kvm_header_and_replace_contents "$ARCH_X86_INCLUDE_ASM_KVM_HEADERS" "$ARCH_X86_INCLUDE_ASM"

# Handle ./include/linux/  kvm header files
INCLUDE_LINUX=$LINUX_FOLDER"/include/linux"
INCLUDE_LINUX_KVM_HEADERS=`ls $INCLUDE_LINUX|grep 'kvm' | grep -v 'kvm2'`

copy_kvm_header_and_replace_contents "$INCLUDE_LINUX_KVM_HEADERS" "$INCLUDE_LINUX"

# Handle ./include/trace/events/  kvm header files
INCLUDE_TRACE_EVENTS=$LINUX_FOLDER"/include/trace/events"
INCLUDE_TRACE_EVENTS_HEADERS=`ls $INCLUDE_TRACE_EVENTS | grep 'kvm' | grep -v 'kvm2'`

copy_kvm_header_and_replace_contents "$INCLUDE_TRACE_EVENTS_HEADERS" "$INCLUDE_TRACE_EVENTS"

# Handle ./include/kvm/  kvm header files
INCLUDE_KVM=$LINUX_FOLDER"/include/kvm"
INCLUDE_KVM2=$LINUX_FOLDER"/include/kvm2"

if [ ! -d $INCLUDE_KVM2 ] ; then
	cp -r $INCLUDE_KVM $INCLUDE_KVM2
	
	INCLUDE_KVM2_HEADERS=`ls $INCLUDE_KVM2`
	for eachfile in $INCLUDE_KVM2_HEADERS ; do
		path=$INCLUDE_KVM2"/"$eachfile
		sed 's/kvm/kvm2/g' -i $path
		sed 's/KVM/KVM2/g' -i $path
	done
fi

# Handle ./include/uapi/linux  kvm header files
INCLUDE_UAPI_LINUX=$LINUX_FOLDER"/include/uapi/linux"
INCLUDE_UAPI_LINUX_HEADERS=`ls $INCLUDE_UAPI_LINUX | grep 'kvm' | grep -v 'kvm2'`

copy_kvm_header_and_replace_contents "$INCLUDE_UAPI_LINUX_HEADERS" "$INCLUDE_UAPI_LINUX"

# Handle ./arch/x86/include/uapi/asm  kvm header files
ARCH_ARM_INCLUDE_UAPI_ASM=$LINUX_FOLDER"/arch/x86/include/uapi/asm"
INCLUDE_UAPI_LINUX_HEADERS=`ls $ARCH_ARM_INCLUDE_UAPI_ASM | grep 'kvm' | grep -v 'kvm2'`

copy_kvm_header_and_replace_contents "$INCLUDE_UAPI_LINUX_HEADERS" "$ARCH_ARM_INCLUDE_UAPI_ASM"

#./include/linux/miscdevice.h:#define KVM2_MINOR		233
MISDEVICE=$LINUX_FOLDER"/include/linux/miscdevice.h"
#if this file exist
if [ -e $MISDEVICE ]; then
	changed=`grep KVM2_MINOR $MISDEVICE`
	#check whether it is already changed, if not changed do the following, otherwise quit
	if [[ -z "${changed// }" ]]; then 
		num=`awk '$2 ~ /KVM_MINOR/ {print $3}' $MISDEVICE`
		exist=`grep $num $MISDEVICE`
		while [[ ! -z "${exist// }" ]]; do
			num=$(($num + 1))
			exist=`grep $num $MISDEVICE`
		done
		sed "/KVM_MINOR/a\
		#define KVM2_MINOR	$num " -i $MISDEVICE
	fi
fi

#./include/linux/profile.h
PROFILE=$LINUX_FOLDER"/include/linux/profile.h"
#if this file exist
if [ -e $PROFILE ]; then
	changed=`grep KVM2 $PROFILE`
	#check whether it is already changed, if not changed do the following, otherwise quit
	if [[ -z "${changed// }" ]]; then 
		num=`awk '$2 ~ /KVM_PROFILING/ {print $3}' $PROFILE`
		exist=`grep $num $PROFILE`
		while [[ ! -z "${exist// }" ]]; do
			num=$(($num + 1))
			exist=`grep $num $PROFILE`
		done
		echo $num
		sed "/KVM_PROFILING/a\
		#define KVM2_PROFILING	$num " -i $PROFILE
	fi
fi

ARCH_X86_INCLUDE_ASM_VMX=$LINUX_FOLDER"/arch/x86/include/asm/vmx.h"
#if this file exist
if [ -e $ARCH_X86_INCLUDE_ASM_VMX ]; then
	changed=`grep KVM2 $ARCH_X86_INCLUDE_ASM_VMX`
	#check whether if it is changed, if not do the following, otherwise quit
	if [[ -z "${changed// }" ]]; then
		sed 's/KVM/KVM2/g' -i $ARCH_X86_INCLUDE_ASM_VMX
	fi
fi


# handle duplicate exported symbol
BASE_FOLDER="/home/llei/kvm/decouple"
DEPENDENCY=$BASE_FOLDER"/output.dep.uniq"
SYMBOL=$BASE_FOLDER"/output.export.symbol"

export_words=`awk '$3 !~ /kvm/ {print $3}' $SYMBOL`

#export_words="__gfn_to_pfn_memslot __x86_set_memory_region cpuid_query_maxphyaddr gfn_to_hva gfn_to_hva_memslot gfn_to_memslot gfn_to_page gfn_to_page_many_atomic gfn_to_pfn gfn_to_pfn_atomic gfn_to_pfn_memslot gfn_to_pfn_memslot_atomic gfn_to_pfn_prot handle_mmio_page_fault_common load_pdptrs mark_page_dirty reprogram_counter reprogram_fixed_counter reprogram_gp_counter reset_shadow_zero_bits_mask x86_emulate_instruction x86_set_memory_region"

for oneword in $export_words ; do
	onereplace=$oneword"_for_kvm2"
	file=`awk -v word="$oneword" -v replace="$onereplace" '
	$1=="E" && $2==word {print $3}
	' $DEPENDENCY`
	changed=`grep "("$onereplace")" $file`
	headerfile1=$LINUX_FOLDER"/include/linux/kvm2_host.h"
	headerfile2=$LINUX_FOLDER"/arch/x86/include/asm/kvm2_host.h"
	headerfile3=$LINUX_FOLDER"/arch/x86/kvm2/cpuid.h"
	headerfile4=$LINUX_FOLDER"/arch/x86/kvm2/mmu.h"
	headerfile5=$LINUX_FOLDER"/arch/x86/kvm2/pmu.h"
	
	if [[ -z "${changed// }" ]]; then 
		echo in
		gawk -v word="$oneword"  -v word_replace="$onereplace" -v p="'" '
		$1=="F" && $2==word {cmd=sprintf("sed %s%ss/%s/%s/g%s -i %s", p, $4, word, word_replace, p, $3); print cmd; system(cmd)}
		$1=="C" && $5==word {cmd=sprintf("sed %s%ss/%s/%s/g%s -i %s", p, $4, word, word_replace, p, $3); print cmd; system(cmd)}
		$1=="E" && $2==word {cmd=sprintf("sed %s%ss/%s/%s/g%s -i %s", p, $4, word, word_replace, p, $3); print cmd; system(cmd)} ' $DEPENDENCY >> $BASE_FOLDER"/cmd"
		src=" "$oneword"(" #space is important to avoid incorrect matches
		dst=" "$onereplace"("
		sed "s/$src/$dst/g" -i $headerfile1
		sed "s/$src/$dst/g" -i $headerfile2
		sed "s/$src/$dst/g" -i $headerfile3
		sed "s/$src/$dst/g" -i $headerfile4
		sed "s/$src/$dst/g" -i $headerfile5
		src="*"$oneword"(" #
		dst="*"$onereplace"("
		sed "s/$src/$dst/g" -i $headerfile1
		sed "s/$src/$dst/g" -i $headerfile2
		sed "s/$src/$dst/g" -i $headerfile3
		sed "s/$src/$dst/g" -i $headerfile4
		sed "s/$src/$dst/g" -i $headerfile5
	fi
done
