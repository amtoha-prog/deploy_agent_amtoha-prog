#!/bin/bash
# Asks for the user input
read -p "Enter your project name: " input
echo "attendance_tracker_$input"

# This checks for existing directory if not creates the directories
if [ -d "attendance_tracker_$input" ]
then
   echo "Directory already exists"
   exit 1

else 
    echo "Creating folders..." 
    mkdir -p "attendance_tracker_$input/Helpers/" "attendance_tracker_$input/reports"
fi 
