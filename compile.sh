#!/bin/bash

error() {
  local red='\033[0;31m'
  local normal="\033[0m"
  echo -e "${red} $1 ${normal}"
}

info() {
     local green="\033[1;32m"
     local normal="\033[0m"
     echo -e "[${green}info${normal}] $1"
}



if [ "$1" != "" ]; then
    PROJECT_DIR="$1"
else
    error "Must pass the directory of the project"
    exit
fi

PLIST=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/SDKSettings.plist
AD_HOC_CODE_SIGNING_ALLOWED=$(/usr/libexec/PlistBuddy -c "Print :DefaultProperties:AD_HOC_CODE_SIGNING_ALLOWED" $PLIST)
if [ $AD_HOC_CODE_SIGNING_ALLOWED == "NO" ]; then
  info "Enabling AD_HOC_CODE_SIGN"
  /usr/libexec/PlistBuddy -c "Set :DefaultProperties:AD_HOC_CODE_SIGNING_ALLOWED YES" $PLIST
fi

CODE_SIGNING_REQUIRED=$(/usr/libexec/PlistBuddy -c "Print :DefaultProperties:CODE_SIGNING_REQUIRED" $PLIST)
if [ $CODE_SIGNING_REQUIRED == "YES" ]; then
  info "Disabling manditory code signing"
  /usr/libexec/PlistBuddy -c "Set :DefaultProperties:CODE_SIGNING_REQUIRED NO" $PLIST
fi

CURRENT_DIR=$(pwd)

cd $PROJECT_DIR
xcodebuild -workspace "PopcornTime.xcworkspace" -scheme "PopcornTimeiOS" -sdk "iphoneos12.1" -configuration Release CODE_SIGN_IDENTITY="-" CODE_SIGNING_REQUIRED="NO" CODE_SIGNING_ALLOWED="NO" archive -archivePath $CURRENT_DIR/PopcornTime.xcarchive

if [[ $? == 0 ]]; then
  info "Build Succeeded"
else
  error "Build Failed"
  exit
fi

cd $CURRENT_DIR/PopcornTime.xcarchive/Products/Applications
chmod 755 PopcornTime.app/PopcornTime
ldid -S PopcornTime.app/PopcornTime

cp -r PopcornTime.app $CURRENT_DIR/projects/Popcorn\ Time/Applications

cd $CURRENT_DIR

./update.sh

if [ $AD_HOC_CODE_SIGNING_ALLOWED == "YES" ]; then
  info "Re-Disabling AD_HOC_CODE_SIGN"
  /usr/libexec/PlistBuddy -c "Set :DefaultProperties:AD_HOC_CODE_SIGNING_ALLOWED NO" $PLIST
fi

if [ $CODE_SIGNING_REQUIRED == "NO" ]; then
  info "Re-Enabling manditory code signing"
  /usr/libexec/PlistBuddy -c "Set :DefaultProperties:CODE_SIGNING_REQUIRED YES" $PLIST
fi
