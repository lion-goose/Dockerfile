#!/bin/sh
set -e

mergedListFile="/scripts/docker/merged_list_file.sh"

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

#### monk-coder https://github.com/monk-coder/dust
#rm -rf /monkcoder /scripts/monkcoder_*
#git clone https://github.com/monk-coder/dust.git /monkcoder
#
for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/"); do cp ${jsname} /scripts/monkcoder_${jsname##*/}; done
for jsname in $(find /monkcoder -name "*.js" | grep -vE "\/backup\/"); do
    jsnamecron="$(cat $jsname | grep -oE "/?/?cron \".*\"" | cut -d\" -f2)"
    test -z "$jsnamecron" || echo "$jsnamecron node /scripts/monkcoder_${jsname##*/} >> /scripts/logs/monkcoder_${jsname##*/}.log 2>&1" >> /scripts/docker/merged_list_file.sh
done

#### yangtingxiao https://github.com/yangtingxiao/QuantumultX
wget --no-check-certificate -O /scripts/jd_lottery_machine.js https://raw.githubusercontent.com/yangtingxiao/QuantumultX/master/scripts/jd/jd_lotteryMachine.js
echo "6 0,8,16,22 * * * node /scripts/jd_lottery_machine.js |ts >> /scripts/logs/jd_lottery_machine.log 2>&1" >> /scripts/docker/merged_list_file.sh

#### whyour https://github.com/whyour/hundun
wget --no-check-certificate -O /scripts/jd_zjd_tuan.js https://raw.githubusercontent.com/whyour/hundun/master/quanx/jd_zjd_tuan.js
echo "4 * * * * node /scripts/jd_zjd_tuan.js |ts >> /scripts/logs/jd_zjd_tuan.log 2>&1" >> /scripts/docker/merged_list_file.sh


wget --no-check-certificate -O /scripts/z_asus_iqiyi.js https://raw.githubusercontent.com/monk-coder/dust/dust/backup/z_asus_iqiyi.js
echo "0 0 5-11 4 * node /scripts/z_asus_iqiyi.js |ts >> /scripts/logs/z_asus_iqiyi.log 2>&1" >> /scripts/docker/merged_list_file.sh

