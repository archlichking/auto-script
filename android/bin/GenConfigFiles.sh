#!/bin/bash
#Run this script to get the local.properties that indicate the sdk.dir
android -s create project --target 1 --name MyAndroidApp --path ./MyAndroidAppProject --activity MyAndroidAppActivity --package com.example.myandroid
cd ./MyAndroidAppProject 
#android -s update project --path .
cp local.properties ../
cp build.xml ../
cd ..
rm -rf ./MyAndroidAppProject
echo "Done"
