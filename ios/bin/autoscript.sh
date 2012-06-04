#coding=utf-8

APP_LOCATION="/Users/thunderzhulei/Library/Application Support/iPhone Simulator/"
if [ ! -z $1 ]
then
  APP_LOCATION=$1
fi

APP_NAME="OFQAJenkins"
if [ ! -z $2 ]
then
  APP_NAME=$2
fi

IOS_VERSION="5.1"
if [ ! -z $3 ]
then
  IOS_VERSION=$3
fi


SIMULATOR_LOCATION="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneSimulator.platform/Developer/Applications/iPhone Simulator.app"

# 0. build OFQAJenkins
# params : 
sh -x buildAuto.sh "$APP_LOCATION" "$APP_NAME" "$IOS_VERSION"

# 1. launch ios simulator with parameters
# params : sim version = 5.1
sh -x launchSimulator.sh "$SIMULATOR_LOCATION"

# 2. launch OFQAJenkins in simulator with parameters.
# params : tcm suite id = 178
#          tcm run id   = 402
sh -x launchAuto.sh "$APP_LOCATION" "$APP_NAME" "$IOS_VERSION"
