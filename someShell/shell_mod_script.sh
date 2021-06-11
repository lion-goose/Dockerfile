#!/bin/sh


mergedListFile="/scripts/docker/merged_list_file.sh"

echo "附加功能1，使用jds仓库的genCodeConf.list文件"
cp /jds/dd_scripts/genCodeConf.list "$GEN_CODE_LIST"

echo "附加功能2，创建其他任务"
if [ -d "/scripts/somescripts/" ]; then
    cp -r /data/somescripts/ /scripts/somescripts
    echo "# 百度和中青任务" >> $mergedListFile
    echo "*/30 5-23 * * * node /scripts/somescripts/youth/youth.js >> /scripts/logs/youth.log 2>&1" >> $mergedListFile
    echo "15 5,8,11,14,17,20 * * * node /scripts/somescripts/youth/Youth_Read-ange.js >> /scripts/logs/Youth_Read-ange.log 2>&1" >> $mergedListFile
    echo "45 6,9,12,15,18,21 * * * node /scripts/somescripts/Youth_Read-hexor.js >> /scripts/logs/Youth_Read-hexor.log 2>&1" >> $mergedListFile
    echo "*/30 5-23 * * * node /scripts/somescripts/baidu/baidu_speed.js >> //scripts/logs/baidu_speed.log 2>&1" >> $mergedListFile
fi
