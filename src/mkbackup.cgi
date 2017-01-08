#!/bin/sh
DATE=`date`
cat <<EOF
Date: $DATE
Content-type: text/plain

EOF
cd $PWD/../PlantSale-backup
FILE=plantsale-backup.`date +%Y%m%d`.sql
mysqldump -h p3smysql21.secureserver.net -u plantsale --password=plantsale --add-drop-table plantsale >$FILE
rm $FILE.zip
zip $FILE.zip $FILE
rm $FILE
echo "Created plantsale backup:" `ls -l $FILE.zip`

