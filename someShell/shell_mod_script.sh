#!/bin/sh


mergedListFile="/scripts/docker/merged_list_file.sh"

echo "附加功能1，使用jds仓库的genCodeConf.list文件"
cp /jds/dd_scripts/genCodeConf.list "$GEN_CODE_LIST"

echo "附加功能2，创建其他任务"
echo "更新中青和百度任务文件夹"
rm -rf /scripts/somescripts
cp -r /data/somescripts /scripts/somescripts
echo "创建其他定时任务"
echo "# 百度和中青任务" >> $mergedListFile
echo "*/30 5-23 * * * node /scripts/somescripts/youth/youth.js >> /scripts/logs/youth.log 2>&1" >> $mergedListFile
echo "15 5,8,11,14,17,20 * * * node /scripts/somescripts/youth/Youth_Read-ange.js >> /scripts/logs/Youth_Read-ange.log 2>&1" >> $mergedListFile
echo "45 6,9,12,15,18,21 * * * node /scripts/somescripts/youth/Youth_Read-hexor.js >> /scripts/logs/Youth_Read-hexor.log 2>&1" >> $mergedListFile
echo "*/30 5-23 * * * node /scripts/somescripts/baidu/baidu_speed.js >> //scripts/logs/baidu_speed.log 2>&1" >> $mergedListFile

# echo "附加功能3，拉取zooPanda仓库的代码，并增加相关任务"
# if [ ! -d "/data/cust_repo/zoo/" ]; then
#     echo "未检查到zooPanda仓库脚本，初始化下载相关脚本..."
#     git clone https://github.com/zooPanda/zoo.git /data/cust_repo/zoo
# else
#     echo "更新zooPanda脚本相关文件..."
#     git -C /data/cust_repo/zoo reset --hard
#     git -C /data/cust_repo/zoo pull --rebase
# fi

# rm -rf /scripts/zoo*

# if [ -n "$(ls /data/cust_repo/zoo/zoo*.js)" ]; then
#     cd /data/cust_repo/zoo/
#     for scriptFile in $(ls zoo*.js | tr "\n" " "); do
#         if [[ -n "$(cat $scriptFile | grep -oE "/?/?cron.{,50}$" | awk -F[\ ] '{print $2,$3,$4,$5,$6}')" ]]; then
#             cp $scriptFile /scripts
#             jsnamecron="$(cat $scriptFile | grep -oE "/?/?cron.{,50}$" | awk -F[\ ] '{print $2,$3,$4,$5,$6}')"
#             echo "#Zoo仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >> $mergedListFile
#             test -z "$jsnamecron" || echo "$jsnamecron node /scripts/$scriptFile >> /scripts/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1" >> $mergedListFile
#         fi
#     done
# fi


echo "附加功能4，拉取@curtinlv的 JD-Script仓库的代码，并增加相关任务"
if [ ! -d "/data/cust_repo/curtinlv/" ]; then
    echo "未检查到@curtinlv的会员开卡仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/curtinlv/JD-Script.git /data/cust_repo/curtinlv
else
    echo "更新@curtinlv的会员开卡脚本相关文件..."
    git -C /data/cust_repo/curtinlv reset --hard
    git -C /data/cust_repo/curtinlv pull --rebase
fi

if type pip3 >/dev/null 2>&1; then
    echo "会员开卡脚本需环境经存在，跳过安装依赖环境"
    if [[ "$(pip3 list | grep Telethon)" == "" || "$(pip3 list | grep APScheduler)" == "" ]]; then
        pip3 install requests
    fi
else
    echo "会员开卡脚本需要python3环境，安装所需python3及依赖环境"
    apk add --update python3-dev py3-pip
    pip3 install requests
fi
echo "#curtinlv的关注有礼任务 " >>$mergedListFile
echo "5 12,18 * * * cd /data/cust_repo/curtinlv/getFollowGifts && python3 jd_getFollowGift.py |ts >>/data/logs/jd_getFollowGift.log 2>&1 &" >>$mergedListFile

echo "#curtinlv的赚京豆 " >>$mergedListFile
echo "05 0,7,23 * * * cd /data/cust_repo/curtinlv && python3 jd_zjd.py |ts >>/data/logs/jd_zjd.log 2>&1 &" >>$mergedListFile

echo "#curtinlv签到领陷阱 " >>$mergedListFile
echo "11 0 * * * cd /data/cust_repo/curtinlv && python3 jd_cashHelp.py |ts >>/data/logs/jd_cashHelp.log 2>&1 &" >>$mergedListFile

echo "#curtinlv的全民抢京豆 " >>$mergedListFile
echo "15 0 * * * cd /data/cust_repo/curtinlv && python3 jd_qjd.py |ts >>/data/logs/jd_qjd.log 2>&1 &" >>$mergedListFile

echo "附加功能5，拉取@passerby-b的JDDJ仓库的代码，并增加相关任务"
if [ ! -d "/data/cust_repo/JDDJ/" ]; then
    echo "未检查到JDDJ仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/passerby-b/JDDJ.git /data/cust_repo/JDDJ
else
    echo "更新JDDJ脚本相关文件..."
    git -C /data/cust_repo/JDDJ reset --hard
    git -C /data/cust_repo/JDDJ pull --rebase
fi
rm -rf /scripts/jddj
cp -rf /data/cust_repo/JDDJ /scripts/jddj
cp -f /scripts/jdFruitShareCodes.js /scripts/jddj
cp -f /scripts/jdDreamFactoryShareCodes.js /scripts/jddj
for jsname in $(ls /scripts/jddj | grep -E "jddj_.*.js$" | tr "\n" " "); do
    jsname_cn="$(grep "cron" /scripts/jddj/$jsname | grep -oE "/?/?tag\=.*" | cut -d"=" -f2)"
    jsname_log="$(echo /scripts/jddj/$jsname | sed 's;^.*/\(.*\)\.js;\1;g')"
    jsnamecron="$(cat /scripts/jddj/$jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
    test -z "$jsname_cn" && jsname_cn=$jsname_log
    test -z "$jsnamecron" || echo "# $jsname_cn" >> /scripts/docker/merged_list_file.sh
    test -z "$jsnamecron" || echo "$jsnamecron node /scripts/jddj/$jsname >> /scripts/logs/$jsname_log.log 2>&1" >> /scripts/docker/merged_list_file.sh
done
echo "5 13 * * * node /scripts/jddj/jd_fruit2.js >> /scripts/logs/jd_fruit2.log 2>&1" >> $mergedListFile
echo "10 12 * * * node /scripts/jddj/jd_dreamFactory2.js >> /scripts/logs/jd_dreamFactory2.log 2>&1" >> $mergedListFile
echo "5 8,19 * * * node /scripts/jddj/jd_cfd2.js >> /scripts/logs/jd_cfd2.log 2>&1" >> $mergedListFile
echo "28 6-23/2 * * * node /scripts/jd_cfd_loop.js >> /scripts/logs/jd_cfd_loop.log 2>&1" >> $mergedListFile
