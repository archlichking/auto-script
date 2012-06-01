#coding=utf-8
# params :
#       $1 : simulator position
#       $2 : app name

APP_PATH="/Users/thunderzhulei/Library/Application Support/iPhone Simulator/5.1/Applications/"
#APP_NAME="B8B41C22-C2AF-41DB-8CE3-A71D1D2BA54E/OFQAJenkins.app"
APP_NAME="OFQAJenkins.app"

#../lib/ios-sim/Release/ios-sim launch "$APP_PATH/$APP_NAME"
../lib/ios-sim/Release/ios-sim launch "$1/$3/Applications/$2.app"
