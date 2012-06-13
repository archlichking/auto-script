auto-script
===========

script for QA CI invocation

## Setup Jenkins for Android in OSX
### Install Jenkins
1. Download Jenkins native package here: http://jenkins-ci.org/
2. Install the package
3. Jenkins will automatic add as deamon task (task define in /Library/LaunchDaemons/org.jenkins-ci.plist)
4. Modify the plist file (/Library/LaunchDaemons/org.jenkins-ci.plist):
  * Set <string>/Users/vincentxie/.jenkins</string> under <key>JENKINS_HOME</key>
  * Set <string>staff</string> under <key>GroupName</key>
  * Set <string>{your username}</string> under <key>UserName</key>
5. Unload the task: sudo launchctl unload -w /Library/LaunchDaemons/org.jenkins-ci.plist
6. Reload the task: sudo launchctl load -w /Library/LaunchDaemons/org.jenkins-ci.plist

### Setup Jenkins Jobs
1. Set Global variable: 
  * Go to "Manage Jenkins" - "Configure System" - "Global properties" - "Environment variables"
  * Add variable with name: PATH and value: {path of android sdk tools}:$PATH. (Android sdk path like /Users/vincentxie/android_sdk/platform-tools:/Users/vincentxie/android_sdk/tools)
2. Add Jenkins plugins:
  * Go to "Manage Jenkins" - "Manage Plugins", select available tab
  * Find these plugins to install: Android Emulator Plugin, GitHub plugin, Jenkins GIT plugin
3. Add job to checkout gree sdk:
  * Add an free-style project named ClientSDK-Android
  * Set GitHub project as https://git.gree-dev.net/ggpsdk/android/
  * Select git under "Source Code Management" section   
      * Set "Repository URL" as git@git.gree-dev.net:ggpsdk/android.git   
      * Set "Branch Specifier" as master
  * Save and create the job
4. Add job for automation app:
  * Add an free-style project named ClientSDK-Automation-Android
  * Set GitHub project as https://git.gree-dev.net/ggpautomation/android/
  * Select git under "Source Code Management" section
      * Set "Repository URL" as git@git.gree-dev.net:ggpautomation/android.git
      * Set "Branch Specifier" as master
  * Selected "Build Triggers" - "Build after other projects are built", set project relys on as "ClientSDK-Android"
  * Add "execute shell" under "Build" section and fill below commands into the blank   

path="{path of auto-script repo}" #like /Users/vincentxie/OpenFeint/ggpautomation/auto-script/android/bin   
cp $path/*.sh .   
sh -ex BuildAutoApp.sh   
sh -ex LaunchAuto.sh   
  * Save and create the job