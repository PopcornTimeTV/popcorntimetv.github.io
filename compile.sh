#!/bin/bash

PLIST=/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/SDKSettings.plist
AD_HOC_CODE_SIGNING_ALLOWED=$(/usr/libexec/PlistBuddy -c "Print :DefaultProperties:AD_HOC_CODE_SIGNING_ALLOWED" $PLIST)
if [ $AD_HOC_CODE_SIGNING_ALLOWED == "NO" ]; then
  echo "Enabling AD_HOC_CODE_SIGN"
  /usr/libexec/PlistBuddy -c "Set :DefaultProperties:AD_HOC_CODE_SIGNING_ALLOWED YES" $PLIST
fi

CODE_SIGNING_REQUIRED=$(/usr/libexec/PlistBuddy -c "Print :DefaultProperties:CODE_SIGNING_REQUIRED" $PLIST)
if [ $CODE_SIGNING_REQUIRED == "YES" ]; then
  echo "Disabling manditory code signing"
  /usr/libexec/PlistBuddy -c "Set :DefaultProperties:CODE_SIGNING_REQUIRED NO" $PLIST
fi

CURRENT_DIR=$(pwd)

cd ~/Documents/PopcornTimeiOS/
xcodebuild -workspace "PopcornTime.xcworkspace" -scheme "PopcornTime" -sdk "iphonesimulator9.3" -destination "platform=iOS Simulator,OS=9.3,name=iPhone 6s" -configuration Release ONLY_ACTIVE_ARCH=NO build

if [[ $? == 0 ]]; then
  echo "Success"
else
  red=`tput setaf 1`
  echo "${red} Failed"
  exit
fi

cd ~/Library/Developer/Xcode/DerivedData/PopcornTime-*/Build/Products/Release-iphonesimulator/
chmod 755 Popcorn\ Time.app/Popcorn\ Time
ldid -S Popcorn\ Time.app/Popcorn\ Time

cp -r Popcorn\ Time.app $CURRENT_DIR/projects/Popcorn\ Time/Applications

cd $CURRENT_DIR

./update.sh

if [ $AD_HOC_CODE_SIGNING_ALLOWED == "YES" ]; then
  echo "Re-Disabling AD_HOC_CODE_SIGN"
  /usr/libexec/PlistBuddy -c "Set :DefaultProperties:AD_HOC_CODE_SIGNING_ALLOWED NO" $PLIST
fi

if [ $CODE_SIGNING_REQUIRED == "NO" ]; then
  echo "Re-Enabling manditory code signing"
  /usr/libexec/PlistBuddy -c "Set :DefaultProperties:CODE_SIGNING_REQUIRED YES" $PLIST
fi
