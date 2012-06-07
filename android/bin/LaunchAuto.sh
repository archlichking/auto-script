#
# Added by Vincent at 2012/5/31
#

# ========== Config ==================

avd_name="my_avd"
apk_path="/Users/vincentxie/OpenFeint/ggpautomation/android/GGPClient-Android/bin/GGPClient-Automation.apk"
activity="com.openfeint.qa.ggp/.DailyRunActivity"

# ========== Init Parameter ==========
# params:
#       $1 : avd name
#       $2 : apk name
#       $3 : activity path
if [ ! -z $1 ]
then
  avd_name=$1
fi

if [ ! -z $2 ]
then
  apk_path=$2
fi

if [ ! -z $3 ]
then
  activity=$3
fi

# ========== Action Begin ==========

#Got last emulator
last_emulator=`adb devices | grep emulator | tail -1 | awk '{print $1}'`
if [ -z $last_emulator ]
then
  last_emulator="empty"
fi
echo "Last emulator before launch is "$last_emulator

#Launch avd
echo "Starting emulator...."
emulator -avd $avd_name &

#Wait until a new emulator launch completed
sleep 20s
new_emulator=`adb devices | grep emulator | tail -1 | awk '{print $1}'`
echo "New emulator launched is "$new_emulator

if [ $last_emulator != $new_emulator ]
then
  #wait launch complete
  emulator_status=`adb devices | grep emulator | tail -1 | awk '{print $2}'`
  while [ $emulator_status != "device" ]
  do
    echo "emulator still launching..."
    sleep 3s
    emulator_status=`adb devices | grep emulator | tail -1 | awk '{print $2}'`
  done
  echo "Launch done..."
else
  echo "Launch failed, need retry"
  exit
fi

#Install automation app
sleep 5s
echo Install automation app....
adb -s $new_emulator install -r $apk_path 
while [ $? -ne 0 ]
do
  echo "try install again..."
  sleep 5s
  adb -s $new_emulator install -r $apk_path
done

#Start MainActivity to begin test run
sleep 3s
echo "Let start to run..."
adb -s $new_emulator shell am start -n $activity

