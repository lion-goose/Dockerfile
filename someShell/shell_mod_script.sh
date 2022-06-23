#!/bin/sh

if [ -d "/data/forwardBot/" ]; then
    cd /data/forwardBot/
    sh start.sh
fi

if [ -d "/data/liby_forward/" ]; then
    cd /data/liby_forward/
    sh liby_start.sh
fi

#if [ -d "/data/sun_forward/" ]; then
#    cd /data/sun_forward/
#    sh sun_start.sh
#fi

mergedListFile="/scripts/merged_list_file.sh"

echo "附加功能1，使用jds仓库的genCodeConf.list文件"
cp /jds/dd_scripts/genCodeConf.list "$GEN_CODE_LIST"

echo "#bot重启" >>$mergedListFile
echo "55 1 * * * sh /data/forwardBot/start.sh restart" >>$mergedListFile
echo "56 1 * * * sh /data/liby_forward/liby_start.sh restart" >>$mergedListFile
#echo "57 23 * * * sh /data/sun_forward/sun_start.sh restart" >>$mergedListFile
echo "#刷新cookie" >>$mergedListFile
echo "0 */8 * * * ddBot -up renewCookie" >>$mergedListFile

# echo "创建其他定时任务"
# echo "# 中青任务" >> $mergedListFile
# echo "*/30 5-23 * * * node /scripts/somescripts/youth/youth.js >> /data/logs/youth.log 2>&1" >> $mergedListFile
# echo "15 5,10,15,19,22 * * * node /scripts/somescripts/youth/Youth_Read-ange.js >> /data/logs/Youth_Read-ange.log 2>&1" >> $mergedListFile
# echo "38 9 * * * node /scripts/somescripts/youth/youth_gain-ange.js >> /data/logs/youth_gain-ange.log 2>&1" >> $mergedListFile
# echo "45 6,11,16,19,23 * * * node /scripts/somescripts/youth/Youth_Read-hexor.js >> /data/logs/Youth_Read-hexor.log 2>&1" >> $mergedListFile
# echo "28 10 * * * node /scripts/somescripts/youth/youth_gain-hexor.js >> /data/logs/youth_gain-hexor.log 2>&1" >> $mergedListFile

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
#             test -z "$jsnamecron" || echo "$jsnamecron node /scripts/$scriptFile >> /data/logs/$(echo $scriptFile | sed "s/.js/.log/g") 2>&1" >> $mergedListFile
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

cd /data/cust_repo/curtinlv/OpenCard
rn=1
for ck in $(cat /data/cookies.list | grep -v "//" | tr "\n" " "); do
    if [ ${#ck} -gt 10 ];then
        if [ $rn == 1 ]; then
            echo "账号$rn【$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")】$ck" >/data/cust_repo/curtinlv/JDCookies.txt
            sed -i "/qjd_zlzh =/s/= \(.*\)/= ['$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_qjd.py
            sed -i "/zlzh =/s/= \(.*\)/= ['$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_zjd.py
            sed -i "/cash_zlzh =/s/= \(.*\)/= ['$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_cashHelp.py
        else
            if [ $rn == 4 ] || [ $rn == 3 ]; then
                sed -i "/qjd_zlzh =/s/]/'$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_qjd.py
                sed -i "/zlzh =/s/]/'$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_zjd.py
                sed -i "/cash_zlzh =/s/]/'$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")',]/g" /data/cust_repo/curtinlv/jd_cashHelp.py
            fi
            echo "账号$rn【$(echo $ck | sed -n "s/.*pt_pin=\(.*\)\;/\1/p")】$ck" >>/data/cust_repo/curtinlv/JDCookies.txt
        fi
        rn=$(expr $rn + 1)
    fi
done
OpenCardCookies=$(cat /data/cookies.list | grep -v "#\|jd_WUUpyT\|jd_SgGoap\|620311248_" | tr "\n" "&" | sed "s/&$//")
sed -i "/JD_COOKIE =/s/= \(.*\)/= '$OpenCardCookies'/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini
sed -i "/openCardBean =/s/= \(.*\)/= 20/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini
sed -i "/memory =/s/= \(.*\)/= no/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini
sed -i "/TG_BOT_TOKEN =/s/= \(.*\)/= $TG_BOT_TOKEN/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini
sed -i "/TG_USER_ID =/s/= \(.*\)/= $TG_USER_ID/g" /data/cust_repo/curtinlv/OpenCard/OpenCardConfig.ini


# echo "#curtinlv的赚京豆 " >>$mergedListFile
# echo "05 0,7,23 * * * cd /data/cust_repo/curtinlv && python3 jd_zjd.py |ts >>/data/logs/jd_zjd.log 2>&1 &" >>$mergedListFile

# echo "#curtinlv抢京豆" >>$mergedListFile
echo "11 0 * * * cd /data/cust_repo/curtinlv && python3 jd_qjd.py |ts >>/data/logs/jd_qjd.log 2>&1 &" >>$mergedListFile

# echo "#城城分现金内部助力" >>$mergedListFile
echo "0 0 9-21 * * cd /data/cust_repo/curtinlv && python3 jd_ccfxj_help.py |ts >>/data/logs/jd_ccfxj_help.log 2>&1 &" >>$mergedListFile

# echo "#curtinlv东东超市兑换" >>$mergedListFile
# sed -i "/coinToBeans =/s/''/'京豆包'/g" /data/cust_repo/curtinlv/jd_blueCoin.py
# sed -i "/blueCoin_Cc = /s/False/True/g" /data/cust_repo/curtinlv/jd_blueCoin.py
# echo "59 23 * * * cd /data/cust_repo/curtinlv && python3 jd_blueCoin.py |ts >>/data/logs/jd_blueCoinPy.log 2>&1 &" >>$mergedListFile

# echo "#curtinlv的关注有礼任务 " >>$mergedListFile
# cat /data/cookies.list >/data/cust_repo/curtinlv/getFollowGifts/JDCookies.txt
# echo "15 8,15 * * * cd /data/cust_repo/curtinlv/getFollowGifts && python3 jd_getFollowGift.py |ts >>/data/logs/jd_getFollowGift.log 2>&1 &" >>$mergedListFile


# echo "附加功能5，拉取@passerby-b的JDDJ仓库的代码，并增加相关任务"
# if [ ! -d "/data/cust_repo/JDDJ/" ]; then
#     echo "未检查到JDDJ仓库脚本，初始化下载相关脚本..."
#     git clone https://github.com/passerby-b/JDDJ.git /data/cust_repo/JDDJ
# else
#     echo "更新JDDJ脚本相关文件..."
#     git -C /data/cust_repo/JDDJ reset --hard
#     git -C /data/cust_repo/JDDJ pull --rebase
# fi
# rm -rf /scripts/jddj
# cp -rf /data/cust_repo/JDDJ /scripts/jddj
# for jsname in $(ls /scripts/jddj | grep -E "jddj_.*.js$" | tr "\n" " "); do
#     jsname_cn="$(grep "cron" /scripts/jddj/$jsname | grep -oE "/?/?tag\=.*" | cut -d"=" -f2)"
#     jsname_log="$(echo /scripts/jddj/$jsname | sed 's;^.*/\(.*\)\.js;\1;g')"
#     jsnamecron="$(cat /scripts/jddj/$jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
#     test -z "$jsname_cn" && jsname_cn=$jsname_log
#     test -z "$jsnamecron" || echo "# $jsname_cn" >> $mergedListFile
#     test -z "$jsnamecron" || echo "$jsnamecron node /scripts/jddj/$jsname >> /data/logs/$jsname_log.log 2>&1" >> $mergedListFile
# done
# # echo "15 12 * * * node /scripts/jddj/jddj_fruit.js >> /data/logs/jddj_fruit.log 2>&1" >> $mergedListFile
# echo "5 13 * * * node /scripts/jddj/jd_fruit2.js >> /data/logs/jd_fruit2.log 2>&1" >> $mergedListFile
# echo "10 12 * * * node /scripts/jddj/jd_dreamFactory2.js >> /data/logs/jd_dreamFactory2.log 2>&1" >> $mergedListFile
# echo "5 8,19 * * * node /scripts/jddj/jd_cfd2.js >> /data/logs/jd_cfd2.log 2>&1" >> $mergedListFile

echo "附加功能6，拉取@leeyiding的seresCheckin仓库的代码，并增加相关任务"
if [ ! -d "/data/cust_repo/seresCheckin/" ]; then
    echo "未检查到seresCheckin的会员开卡仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/leeyiding/seresCheckin.git /data/cust_repo/seresCheckin
else
    echo "更新seresCheckin的会员开卡脚本相关文件..."
    git -C /data/cust_repo/seresCheckin reset --hard
    git -C /data/cust_repo/seresCheckin pull --rebase
fi

# echo "#宠汪汪积分兑换京豆组合 " >>$mergedListFile
# echo "47,57 7,15,16,23 * * * node /scripts/jd_task_validate_init.js >> /data/logs/jd_task_validate_init.log 2>&1" >>$mergedListFile
# echo "47,58 7,15,16,23 * * * sleep 2s; node conc /scripts/jd_task_validate.js >> /data/logs/jd_task_validate.log 2>&1" >>$mergedListFile
# echo "59 7,15,23 * * * sleep 57s; node conc /scripts/jd_joy_reward_new.js >> /data/logs/jd_joy_reward_new.log 2>&1" >>$mergedListFile
# echo "0,48 0,8,16 * * * node conc /scripts/jd_joy_reward_new.js >> /data/logs/jd_joy_reward_new.log 2>&1" >>$mergedListFile
# echo "#E5AutoApi调用任务 " >>$mergedListFile
# echo "25 */3 * * * cd /data/somescripts/AutoApiSecret && sh start.sh" >>$mergedListFile
echo "#京东饭粒" >>$mergedListFile
echo "24 1,15,23 * * * node /scripts/jd_fanli.js >> /data/logs/jd_fanli.log 2>&1" >>$mergedListFile
echo "#seresCheckin任务" >>$mergedListFile
echo "18 6,13,19,23 * * * cd /data/cust_repo/seresCheckin && python3 main.py" >>$mergedListFile
echo "#小米刷步数任务" >>$mergedListFile
echo "15 17 * * * cd /data/somescripts && python3 xmsport.py |ts >>/data/logs/xmsport.log 2>&1 &" >>$mergedListFile
