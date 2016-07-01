#!/bin/bash
#=========================================================
# [First of All] Get the directory path and name of this script
#=========================================================
script_path=$(readlink -f "$0")
script_dir=`dirname $script_path` 
script_name=`basename $script_path`
#=========================================================
# [Variables]
#=========================================================
src_base_dir="$script_dir"
target_base_dir="/usr/share/security-config/test"
utils_dir="$target_base_dir/utils"

src_root_test_dir="$src_base_dir/root_test"
target_root_test_dir="$target_base_dir/root_test"

src_capability_test_dir="$src_base_dir/capability_test"
target_capability_test_dir="$target_base_dir/capability_test"

src_smack_rule_test_dir="$src_base_dir/smack_rule_test"
target_smack_rule_test_dir="$target_base_dir/smack_rule_test"

src_setuid_test_dir="$src_base_dir/setuid_test"
target_setuid_test_dir="$target_base_dir/setuid_test"

src_path_check_test_dir="$src_base_dir/path_check_test"
target_path_check_test_dir="$target_base_dir/path_check_test"
#=========================================================
# Script Begin
#=========================================================

sdb root on

###############################
#  Check profile and arch
###############################
profile_info=`sdb shell cat /etc/info.ini | grep "Build="`

if [[ $profile_info == *"mobile"* ]]
then
	profile="mobile"
elif [[ $profile_info == *"wearable"* ]]
then
	profile="wearable"
else
	echo "Unknow profile!!"
	exit 1
fi

arch_info=`sdb shell $utils_dir/file* $utils_dir/file*`
if [[ $arch_info == *"aarch64"* ]]
then
	arch="aarch64"
    arch_dir="emul"
elif [[ $arch_info == *"ARM"* ]]
then
	arch="arm"
    arch_dir="target"
elif [[ $arch_info == *"x86-64"* ]]
then
	arch="x86_64"
    arch_dir="target"
elif [[ $arch_info == *"Intel"* ]]
then
	arch="i386"
    arch_dir="emul"
fi

echo "#========================================================="
echo "# profile = $profile, arch = $arch"
echo "#========================================================="

# push root_test lists
sdb push $src_root_test_dir/list/$arch_dir/$profile/*.stable $target_root_test_dir

# push capability_test lists
sdb push $src_capability_test_dir/list/$arch_dir/$profile/*.stable $target_capability_test_dir

# push smack_rule_test lists
sdb push $src_smack_rule_test_dir/*.stable $target_smack_rule_test_dir

# push setuid_test list
sdb push $src_setuid_test_dir/scripts/*.stable $target_setuid_test_dir/scripts

# push path_check_test list
sdb push $src_path_check_test_dir/*.stable $target_path_check_test_dir

echo "#========================================================="
echo "# Set exception lists ... "
echo "#========================================================="
#######################################
#  Replace original exception lists
#######################################
for files in `sdb shell find $target_base_dir -name *"\.stable"`
do
	files=`echo $files | tr -d '\r'`
	file_changes=${files%.*}
	echo "$file_changes"
	sdb shell mv $files $file_changes
done
echo ""
