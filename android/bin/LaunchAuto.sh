#
# Added by Vincent at 2012/5/31
#

avd_name="avd_2.3.3"
apk_path="/Users/vincentxie/OpenFeint/ggpautomation/android/GGPClient-Android/bin/GGPClient-Automation.apk"
activity="com.openfeint.qa.ggp/.DailyRunActivity"

#Launch avd
echo "Starting emulator...."
emulator -avd $avd_name &
sleep 120s

#Install automation app
echo Install automation app....
adb install -r $apk_path 
while [ $? -ne 0 ]
do
  echo "try install again..."
  sleep 5s
  adb install -r $apk_path
done

#Start MainActivity to begin test run
echo "Let start to run..."
sleep 3s
adb shell am start -n $activity

