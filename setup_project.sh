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

# A heredoc for config.json

cat > attendance_tracker_$input/Helpers/config.json << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

cat > attendance_tracker_$input/Helpers/assets.csv << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF
