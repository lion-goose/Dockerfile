#!/usr/bin/env bash
set -e



mergedListFile="/scripts/docker/merged_list_file.sh"

sed -i 's/COOKIES_LIST/COOKIE_LIST/g' /scripts/docker/auto_help.sh

echo "附加功能1，使用jds仓库的gen_code_conf.list文件"
cp /jds/jd_scripts_bot/gen_code_conf.list "$GEN_CODE_LIST"

echo "附加功能2，自定义仓库和任务"
#@shylocks仓库脚本
function initLiongoose() {
    git clone https://github.com/lion-goose/BackUp.git /lion-goose
}

if [ ! -d "/lion-goose/" ]; then
    echo "未检查到lion-goose仓库脚本，初始化下载相关脚本"
    initLiongoose
else
    echo "更新lion-goose脚本相关文件"
    git -C /lion-goose reset --hard
    git -C /lion-goose pull --rebase
    #npm install --loglevel error
fi

##复制两个文件
cp -f /lion-goose/jd*.js /scripts/
cp -f /lion-goose/xmSports.js /scripts/

echo "附加功能3，拉取he1pu/JDHelp仓库的代码，并增加相关任务"
apk add grep
if [ ! -d "/JDHelp/" ]; then
    echo "未检查到he1pu/JDHelp仓库脚本，初始化下载相关脚本..."
    git clone https://github.com/he1pu/JDHelp.git /JDHelp
else
    echo "更新he1pu/JDHelp脚本相关文件..."
    git -C /JDHelp reset --hard
    git -C /JDHelp pull --rebase
fi

rm -rf /scripts/he1pu*

if [ -n "$(ls /JDHelp/*.js)" ]; then
    cd /JDHelp/
    for scriptFile in $(ls *.js | tr "\n" " "); do
        if [[ -n "$(cat $scriptFile | grep -oE "/?/?cron.{,50}$" | awk -F[\ ] '{print $2,$3,$4,$5,$6}')" ]]; then
            cp ${scriptFile} /scripts/he1pu_${scriptFile##*/}
            jsnamecron="$(cat $scriptFile | grep -oE "/?/?cron.{,50}$" | awk -F[\ ] '{print $2,$3,$4,$5,$6}')"
            echo "#he1pu/JDHelp仓库任务-$(sed -n "s/.*new Env('\(.*\)').*/\1/p" $scriptFile)($scriptFile)" >> $mergedListFile
            test -z "$jsnamecron" || echo "$jsnamecron node /scripts/he1pu_${jsname##*/} >> /scripts/logs/$(echo he1pu_${jsname##*/} | sed "s/.js/.log/g") 2>&1" >> $mergedListFile
        fi
    done
fi


function diycron(){
    #### yangtingxiao https://github.com/yangtingxiao/QuantumultX
    wget --no-check-certificate -O /scripts/jd_lottery_machine.js https://raw.githubusercontent.com/yangtingxiao/QuantumultX/master/scripts/jd/jd_lotteryMachine.js
    echo "1 0,16,22 * * * node /scripts/jd_lottery_machine.js |ts >> /scripts/logs/jd_lottery_machine.log 2>&1" >> /scripts/docker/merged_list_file.sh
    #### whyour https://github.com/whyour/hundun
    wget --no-check-certificate -O /scripts/whyour_jx_nc.js https://raw.githubusercontent.com/whyour/hundun/master/quanx/jx_nc.js
    echo "0 2,9 * * * node /scripts/whyour_jx_nc.js |ts >> /scripts/logs/whyour_jx_nc.log 2>&1" >> /scripts/docker/merged_list_file.sh
    wget --no-check-certificate -O /scripts/whyour_jx_factory.js https://raw.githubusercontent.com/whyour/hundun/master/quanx/jx_factory.js
    echo "13 */4 * * * node /scripts/whyour_jx_factory.js |ts >> /scripts/logs/whyour_jx_factory.log 2>&1" >> /scripts/docker/merged_list_file.sh
    wget --no-check-certificate -O /scripts/jd_zjd_tuan.js https://raw.githubusercontent.com/whyour/hundun/master/quanx/jd_zjd_tuan.js
    echo "4 * * * * node /scripts/jd_zjd_tuan.js |ts >> /scripts/logs/jd_zjd_tuan.log 2>&1" >> /scripts/docker/merged_list_file.sh
    #https://raw.githubusercontent.com/ZCY01/daily_scripts/main/jd/jd_try.js
    wget --no-check-certificate -O /scripts/zcy01_jd_try.js https://raw.githubusercontent.com/lion-goose/BackUp/master/zcy01_jd_try.js
    echo "55 15 */2 * * node /scripts/zcy01_jd_try.js |ts >> /scripts/logs/zcy01_jd_try.log 2>&1" >> /scripts/docker/merged_list_file.sh
    #### moposmall https://github.com/moposmall/Script/tree/main/Me
    wget --no-check-certificate -O /scripts/moposmall_jx_cfd.js https://raw.githubusercontent.com/moposmall/Script/main/Me/jx_cfd.js
    echo "0 0,9,17 * * * node /scripts/moposmall_jx_cfd.js |ts >> /scripts/logs/moposmall_jx_cfd.log 2>&1" >> /scripts/docker/merged_list_file.sh
    wget --no-check-certificate -O /scripts/moposmall_jx_mc.js https://raw.githubusercontent.com/moposmall/Script/main/Me/jx_mc.js
    echo "5 2,10,18 * * * node /scripts/moposmall_jx_mc.js |ts >> /scripts/logs/moposmall_jx_mc.log 2>&1" >> /scripts/docker/merged_list_file.sh
    wget --no-check-certificate -O /scripts/moposmall_jx_mc_coin.js https://raw.githubusercontent.com/moposmall/Script/main/Me/jx_mc_coin.js
    echo "10 */4 * * * node /scripts/moposmall_jx_mc_coin.js |ts >> /scripts/logs/moposmall_jx_mc_coin.log 2>&1" >> /scripts/docker/merged_list_file.sh
    wget --no-check-certificate -O /scripts/moposmall_jx_mc_emptycabbage.js https://raw.githubusercontent.com/moposmall/Script/main/Me/jx_mc_emptycabbage.js
    echo "15 3,11,19 * * * node /scripts/moposmall_jx_mc_emptycabbage.js |ts >> /scripts/logs/moposmall_jx_mc_emptycabbage.log 2>&1" >> /scripts/docker/merged_list_file.sh
    #### he1pu https://github.com/he1pu/JDHelp
    wget --no-check-certificate -O /scripts/he1pu_jd_cfdtx.js https://raw.githubusercontent.com/he1pu/JDHelp/main/jd_cfdtx.js
    echo "0 0,12 * * * 59 11,23 * * * sleep 57s; node /scripts/he1pu_jd_cfdtx.js |ts >> /scripts/logs/he1pu_jd_cfdtx.log 2>&1" >> /scripts/docker/merged_list_file.sh
    wget --no-check-certificate -O /scripts/he1pu_jd_joy_park.js https://raw.githubusercontent.com/he1pu/JDHelp/main/jd_joy_park.js
    echo "20 0-23/3 * * * node /scripts/he1pu_jd_joy_park.js |ts >> /scripts/logs/he1pu_jd_joy_park.log 2>&1" >> /scripts/docker/merged_list_file.sh
    wget --no-check-certificate -O /scripts/he1pu_jd_joypark_open.js https://raw.githubusercontent.com/he1pu/JDHelp/main/jd_joypark_open.js
    echo "20 9 * * * node /scripts/he1pu_jd_joypark_open.js |ts >> /scripts/logs/he1pu_jd_joypark_open.log 2>&1" >> /scripts/docker/merged_list_file.sh
    wget --no-check-certificate -O /scripts/he1pu_jd_joypark_task.js https://raw.githubusercontent.com/he1pu/JDHelp/main/jd_joypark_task.js
    echo "20 7,9,17,20 node /scripts/he1pu_jd_joypark_task.js |ts >> /scripts/logs/he1pu_jd_joypark_task.log 2>&1" >> /scripts/docker/merged_list_file.sh
}


function main(){
    # 首次运行时拷贝docker目录下文件及创建dust脚本使用文件夹
    [[ ! -d /jd_diy ]] && mkdir /jd_diy && cp -rf /scripts/docker/* /jd_diy
    # DIY脚本执行前后信息
    a_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    a_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    b_jsnum=$(ls -l /scripts | grep -oE "^-.*js$" | wc -l)
    b_jsname=$(ls -l /scripts | grep -oE "^-.*js$" | grep -oE "[^ ]*js$")
    # DIY任务
    diycron
    # DIY脚本更新TG通知
    info_more=$(echo $a_jsname  $b_jsname | tr " " "\n" | sort | uniq -c | grep -oE "1 .*$" | grep -oE "[^ ]*js$" | tr "\n" " ")
    [[ "$a_jsnum" == "0" || "$a_jsnum" == "$b_jsnum" ]] || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=DIY脚本更新完成：$a_jsnum $b_jsnum $info_more" >/dev/null
    # LXK脚本更新TG通知
    lxktext="$(diff /jd_diy/crontab_list.sh /scripts/docker/crontab_list.sh | grep -E "^[+-]{1}[^+-]+" | grep -oE "node.*\.js" | cut -d/ -f3 | tr "\n" " ")"
    test -z "$lxktext" || curl -sX POST "https://api.telegram.org/bot$TG_BOT_TOKEN/sendMessage" -d "chat_id=$TG_USER_ID&text=LXK脚本更新完成：$(cat /jd_diy/crontab_list.sh | grep -vE "^#" | wc -l) $(cat /scripts/docker/crontab_list.sh | grep -vE "^#" | wc -l) $lxktext" >/dev/null
    # 拷贝docker目录下文件供下次更新时对比
    cp -rf /scripts/docker/* /jd_diy
}

main
