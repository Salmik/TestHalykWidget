#!/bin/bash

# Проверяем, передан ли аргумент с названием схемы
if [ -z "$1" ]; then
  echo "Ошибка: Не указана схема для сборки."
  exit 1
fi

SCHEME="$1"

echo "Сборка для iOS устройств"
# iOS devices
xcodebuild archive \
  -workspace "HalykWidget.xcworkspace" \
  -scheme "$SCHEME" \
  -archivePath "./build/ios_devices.xcarchive" \
  -sdk iphoneos \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "Сборка для iOS симулятора"
# iOS simulator
xcodebuild archive \
  -workspace "HalykWidget.xcworkspace" \
  -scheme "$SCHEME" \
  -archivePath "./build/ios_simulators.xcarchive" \
  -sdk iphonesimulator \
  SKIP_INSTALL=NO \
  BUILD_LIBRARY_FOR_DISTRIBUTION=YES

echo "❇ Создание XCFramework"
# XCFramework
xcodebuild -create-xcframework \
  -framework "./build/ios_devices.xcarchive/Products/Library/Frameworks/HalykWidget.framework" \
  -framework "./build/ios_simulators.xcarchive/Products/Library/Frameworks/HalykWidget.framework" \
  -output "HalykWidget.xcframework"
