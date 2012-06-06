#
# Added by Vincent at 2012/6/6
#

# ========== Config ==================

project_root="/Users/vincentxie/OpenFeint/ggpautomation/android/GGPClient-Android/"
sdk_root="/Users/vincentxie/Downloads/tmp/qaarchive_android_2579/"
sdk_path="sdk/"
gson_path="vendor/gson/"
PTR_path="vendor/Android-PullToRefresh/library/"
signpost_core_path="vendor/signpost/signpost-core/"
signpost_common_path="vendor/signpost/signpost-commonshttp4/"
local_pro="local.properties"
apk_path="bin/GGPClient-Automation-release.apk"


# ========== Action Begin ==========

#Copy local.properties to all relied project
if [ ! -f $local_pro ]
then
  echo "local.properties is not exists, generate a new one"
  sh GenLocalProperties.sh
fi

cp $local_pro $sdk_root$sdk_path
cp $local_pro $sdk_root$gson_path
cp $local_pro $sdk_root$PTR_path
cp $local_pro $sdk_root$signpost_core_path
cp $local_pro $sdk_root$signpost_common_path

#Use ant to build the project
cd $project_root
rm $apk_path
ant release >/dev/null
if [ -f $apk_path ]
then
  echo "build success..."
fi
