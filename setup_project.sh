#!/bin/bash
# Asks for the user input
read -p "Enter your project name: " input
echo "attendance_tracker_$input"

# This is a signal trap that the user cancels mid execution

signal_trap() {

    echo "Script was interrupted"

    tar -czf "attendance_tracker_${input}_archive" "attendance_tracker_$input"

    if [ -d "attendance_tracker_$input" ]
    then
	
         rm -rf "attendance_tracker_$input"
    fi     
    # exit 1 prevents any unecessary running of the rest of te script after archiving.
    exit 1
}

trap signal_trap SIGINT

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

# A heredoc for assets.csv
cat > attendance_tracker_$input/Helpers/assets.csv << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

# A heredoc for reports.log
cat > attendance_tracker_$input/reports/reports.log << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

# A heredoc for attendance_checker.py
cat > attendance_tracker_$input/attendance_checker.py << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100

            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
               if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

# Entering new threshold value
read -p "Do you want to update thresholds? (yes/no): " user_input

if [ "$user_input" = "yes" ] 
then

        # Warning threshold
       read -p " Enter warning threshold value: " warning
       
       # Verifies if the numbers are valid for warning
       if [ -z "$warning" ] || \
	  [[ ! "$warning" =~ ^[0-9]+$ ]] || \
          [ "$warning" -gt 100 ]
       then
            echo "Invalid input, write the correct input.;"
            exit 1


	fi
       
       # Failure threshold
       read -p " Enter failure threshold value: " failure
       
       # Verifies if the number is valid for failure
       if [ -z "$failure" ] || \
	  [[ ! "$failure" =~ ^[0-9]+$ ]] || \
          [ "$failure" -gt 100 ] 
       then 
	     echo "Invalid input, write the correct input. "
             exit 1
       fi


# Using sed  to change the actual numers from config.json
       sed -i 's/"warning": [0-9]*/"warning": '"$warning"'/' "attendance_tracker_$input/Helpers/config.json"
       sed -i 's/"failure": [0-9]*/"failure": '"$failure"'/' "attendance_tracker_$input/Helpers/config.json"
       
       echo " Thresholds updated successfully"
fi

#Checking if python exists
echo "Searching for python3..."
if python3 --version >/dev/null
then 
	echo "python3 is installed: $(python3 --version)"
else
	echo "python3 is not found"
fi



# Directory structure verification
echo "Verifying directory structure..."
errors=0

if [ ! -d "attendance_tracker_$input" ]
then 
	echo "Error found: Main directory is missing"
	errors=$((errors + 1))

fi

# Helpers directory
if [ ! -d "attendance_tracker_$input/Helpers" ]
then
	echo "Error found: Helpers directory missing"
	errors=$((errors + 1))
fi

# reports directory
if [ ! -d "attendance_tracker_$input/reports" ]
then
        echo "Error found: reports directory missing"
        errors=$((errors + 1))
fi

#attendance_checker.py
if [ ! -f "attendance_tracker_$input/attendance_checker.py" ]
then
	echo "Error found: attendance_checker.py missing"
	errors=$((errors + 1)) 
fi

# config.json file located in Helpers directory
if [ ! -f "attendance_tracker_$input/Helpers/config.json" ]
then
        echo "Error found: config.json file missing"
        errors=$((errors + 1))
fi

# assests.csv file located in Helpers directory
if [ ! -f "attendance_tracker_$input/Helpers/assets.csv" ]
then
        echo "Error found: assets.csv file missing"
        errors=$((errors + 1))
fi

# reports.log file loacted in reports folders
if [ ! -f "attendance_tracker_$input/reports/reports.log" ]
then
        echo "Error found: reports.log file missing"
        errors=$((errors + 1))
fi

# If no error found
if [ $errors -eq 0 ]
then 
	echo "Structure verified was successful"
else
	echo "$errors issue found"
fi

# Project verification
echo "Project setup complete! Continue at attendance_tracker_$input"
