#!/bin/bash


# This script formats data from two sources to create a third merged output. It takes in Jira story information from our FPP planning spreadhseat and 
# combines it with a jira export of the latest stories. The result is a new merged version that preserves the sprint a story has been allocated to in 
# the spreadsheet with the latest story information.

# The hope is that we can update jira reporting enough to remove the need to maintain the release plan in a separate sheet.

# new_stories.csv is the export from JIra using the PG - MVP fiter
# old-stories is the export from the burndown spreadsheet
#
# ./format_story_export.sh <old story file> <new story file> <output file>
# 
# Old file fields
#
# JIRA STORY ID,JIRA EPIC ID,Epic Name,User Story,Sprint,Notes,MVP Must Haves,Story Points
#
# New file fields
#
# Issue key,Issue id,Summary,Custom field (Epic Link),Custom field (Story Points),Custom field (Story Points),Custom field (Epic Name),Status

# Instructions
# 
# 1. Export the fields from the Google planning sheet as Old fields: https://docs.google.com/spreadsheets/d/180FpdXTaT1UBO_FbNVnlhTkEbBfCXCg_NCnPWcT4FiE/edit#gid=1276684868
# 2. Use the MVP filter to export the new stories from Jira as new fields: https://sb97digital.atlassian.net/issues/?filter=11112
# 3. Remove all header rows from old and new
# 4. Run this script on old new to create merged csv
# 5. Open the merged csv in Google sheets. 
# 6. Copy and paste the merged data to replace the stories in the Google planning sheet. You may decide to duplicate the current version so you don't lose the history
# 7. Make sure Jira and Sheet totals match. Epic name lookup formual is replaced. Summary sheet updated to point to new sheet name if you created on

# NOTE: This script uses an extension to awk to allow a pattern to be used as a Field delimeter. 
# This is to get round excel csv have , in fields and as the delimeter e.g. 1,"This field contains a , and breaks MACOS awk",3
# I was able to install gawk using "brew install gawk"
# 
# Petes-MacBook-Pro:~ petegordon$ awk --version
# GNU Awk 5.1.0, API: 3.0 (GNU MPFR 4.1.0, GNU MP 6.2.1)
# Copyright (C) 1989, 1991-2020 Free Software Foundation.

# NOTE: The merged output is in Tab delimied format so when you copy and paste it into Google sheets it formats as multiple columns correctly
# This can be updated by changing BEGIN { OFS = ","; }

# JIRA STORY ID	JIRA EPIC ID	Epic Name	User Story	Sprint	Notes	MVP Must Haves	Story Points
# FPP-6,71684,Create Content for Repayment Calculator (Summary),FPP-21,3.0,,,Ready to Test MATCHED FPP-6,FPP-21,Calculator -Step 1,Create Content for Repayment Calculator (Summary),5,,Y,3,5,,,,,,,,

# FPP-349	FPP-23	FPP-23	Content for What Can I Expect - Change of copy	11	New copy change - yet to be estimated	Y	5.0

# This is the output format order

# JIRA STORY ID	JIRA EPIC ID	Epic Name	User Story	Sprint	Notes	MVP Must Haves	Story Points
# $1 = Jira ID
# OFS
# $4 = Epic ID
# OFS
# OFS
# $3 = User Story
# OFS
# $10 = Sprint
# OFS
# OFS
# $12 = MVP
# OFS
# $13 = Points

# This was the original version using the export and the sheet
# awk -vFPAT='[^,]*|"[^"]*"' 'NR==FNR{F1[$1]=$0;next} F1[$1]=="" {print $0} F1[$1]!="" {print $0 FS "MATCHED" FS F1[$1]}' "$1" "$2" | awk -vFPAT='[^,]*|"[^"]*"' 'BEGIN { OFS = "\t"; } { print($1 OFS $4 OFS $10 OFS $3 OFS $12 OFS $13 OFS $14 OFS $5) }' | tee "$3"
awk -vFPAT='[^,]*|"[^"]*"' 'NR==FNR{F1[$1]=$0;next} F1[$1]=="" {print $0} F1[$1]!="" {print $0 FS "MATCHED" FS F1[$1]}' "$1" "$2" | tee 'temp.csv' | awk -vFPAT='[^,]*|"[^"]*"' 'BEGIN { OFS = "\t"; } { print($1 OFS $4 OFS OFS $3 OFS $10 OFS OFS $12 OFS $13) }' | tee "$3"