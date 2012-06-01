#coding=utf-8
# params:
#        $1 : project path
#        $2 : app name
#        $3 : sdk version
#        $4 : simulator locatoin

PROJECT="/Users/thunderzhulei/lay-zhu/ios/OFQAAPI_IOS/OFQAAPI.xcodeproj"
TARGET="OFQAJenkins"
AIMSDK="iphonesimulator5.1"
DSTROOT="/Users/thunderzhulei/Library/Application Support/iPhone Simulator/5.1/"
COMMAND="install"

xcodebuild -project "$PROJECT" -target "$2" -configuration Debug -sdk "$AIMSDK" DSTROOT="$1/$3" $COMMAND
