#!/bin/sh
set -e

cp -f /scripts/logs/docker/* /scripts/docker/

echo "定义定时任务合并处理用到的文件路径..."
defaultListFile="/scripts/docker/$DEFAULT_LIST_FILE"
echo "默认文件定时任务文件路径为 ${defaultListFile}"
mergedListFile="/scripts/docker/merged_list_file.sh"
echo "合并后定时任务文件路径为 ${mergedListFile}"

echo "第1步将默认定时任务列表添加到并后定时任务文件..."
cat $defaultListFile >$mergedListFile

echo "第2步判断是否存在自定义任务任务列表并追加..."
if [ $CUSTOM_LIST_FILE ]; then
    echo "您配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
    # 无论远程还是本地挂载, 均复制到 $customListFile
    customListFile="/scripts/docker/custom_list_file.sh"
    echo "自定义定时任务文件临时工作路径为 ${customListFile}"
    if expr "$CUSTOM_LIST_FILE" : 'http.*' &>/dev/null; then
        echo "自定义任务文件为远程脚本，开始下载自定义远程任务。"
        wget -O $customListFile $CUSTOM_LIST_FILE
        echo "下载完成..."
    elif [ -f /scripts/docker/$CUSTOM_LIST_FILE ]; then
        echo "自定义任务文件为本地挂载。"
        cp /scripts/docker/$CUSTOM_LIST_FILE $customListFile
    fi

    if [ -f "$customListFile" ]; then
        if [ $CUSTOM_LIST_MERGE_TYPE == "append" ]; then
            echo "合并默认定时任务文件：$DEFAULT_LIST_FILE 和 自定义定时任务文件：$CUSTOM_LIST_FILE"
            echo -e "" >>$mergedListFile
            cat $customListFile >>$mergedListFile
        elif [ $CUSTOM_LIST_MERGE_TYPE == "overwrite" ]; then
            echo "配置了自定义任务文件：$CUSTOM_LIST_FILE，自定义任务类型为：$CUSTOM_LIST_MERGE_TYPE..."
            cat $customListFile >$mergedListFile
        else
            echo "配置配置了错误的自定义定时任务类型：$CUSTOM_LIST_MERGE_TYPE，自定义任务类型为只能为append或者overwrite..."
        fi
    else
        echo "配置的自定义任务文件：$CUSTOM_LIST_FILE未找到，使用默认配置$DEFAULT_LIST_FILE..."
    fi
else
    echo "当前只使用了默认定时任务文件 $DEFAULT_LIST_FILE ..."
fi



echo "第3步判断是否配置了默认脚本更新任务..."
if [ $(grep -c "default_task.sh" $mergedListFile) -eq '0' ]; then
    echo "合并后的定时任务文件，未包含必须的默认定时任务，增加默认定时任务..."
    echo -e >>$mergedListFile
    echo "45 */1 * * * docker_entrypoint.sh >> /scripts/logs/default_task.log 2>&1" >>$mergedListFile
    echo "44 23 * * * find /scripts/logs -name '*.log' | grep -v 'sharecodeCollection' | xargs rm -rf" >>$mergedListFile
else
    sed -i "/default_task.sh/d" $mergedListFile
    echo "#脚本追加默认定时任务" >>$mergedListFile
    echo "45 */1 * * * docker_entrypoint.sh >> /scripts/logs/default_task.log 2>&1" >>$mergedListFile
    echo "44 23 * * * find /scripts/logs -name '*.log' | grep -v 'sharecodeCollection' | xargs rm -rf" >>$mergedListFile
fi

echo "第4步判断是否配置了随即延迟参数..."
if [ $RANDOM_DELAY_MAX ]; then
    if [ $RANDOM_DELAY_MAX -ge 1 ]; then
        echo "已设置随机延迟为 $RANDOM_DELAY_MAX , 设置延迟任务中..."
        sed -i "/\(jd_bean_sign.js\|jd_blueCoin.js\|jd_xtg.js\|jd_818.js\|jd_newYearMoney.js\|jd_cfd_cashOut.js\|jd_joy_reward.js\|jd_joy_steal.js\|jd_joy_feedPets.js\|jd_car_exchange.js\)/!s/node/sleep \$((RANDOM % \$RANDOM_DELAY_MAX)); node/g" $mergedListFile
    fi
else
    echo "未配置随即延迟对应的环境变量，故不设置延迟任务..."
fi

echo "第5步判断是否配置自定义shell执行脚本..."
if [ 0"$CUSTOM_SHELL_FILE" = "0" ]; then
    echo "未配置自定shell脚本文件，跳过执行。"
else
    if expr "$CUSTOM_SHELL_FILE" : 'http.*' &>/dev/null; then
        echo "自定义shell脚本为远程脚本，开始下载自定义远程脚本。"
        wget -O /scripts/docker/shell_script_mod.sh $CUSTOM_SHELL_FILE
        echo "下载完成，开始执行..."
        echo "#远程自定义shell脚本追加定时任务" >>$mergedListFile
        sh -x /scripts/docker/shell_script_mod.sh
        echo "自定义远程shell脚本下载并执行结束。"
    else
        if [ ! -f $CUSTOM_SHELL_FILE ]; then
            echo "自定义shell脚本为docker挂载脚本文件，但是指定挂载文件不存在，跳过执行。"
        else
            echo "docker挂载的自定shell脚本，开始执行..."
            echo "#docker挂载自定义shell脚本追加定时任务" >>$mergedListFile
            sh -x $CUSTOM_SHELL_FILE
            echo "docker挂载的自定shell脚本，执行结束。"
        fi
    fi
fi



echo "第6步删除不运行的脚本任务..."
if [ $DO_NOT_RUN_SCRIPTS ]; then
    echo "您配置了不运行的脚本：$DO_NOT_RUN_SCRIPTS"
    arr=${DO_NOT_RUN_SCRIPTS//&/ }
    for item in $arr; do
        sed -ie '/'"${item}"'/d' ${mergedListFile}
    done

fi

echo "第7步 自动助力"
if [ -n "$ENABLE_AUTO_HELP" ]; then
  #直接判断变量，如果未配置，会导致sh抛出一个错误，所以加了上面一层
  if [ "$ENABLE_AUTO_HELP" = "true" ]; then
    echo "开启自动助力"
    #在所有脚本执行前，先执行助力码导出
    sed -i 's/node/ . \/scripts\/docker\/auto_help.sh export > \/scripts\/logs\/auto_help_export.log \&\& node /g' ${mergedListFile}
  else
    echo "未开启自动助力"
  fi
fi

echo "第8步增加 |ts 任务日志输出时间戳..."
sed -i "/\( ts\| |ts\|| ts\)/!s/>>/\|ts >>/g" $mergedListFile

echo "第9步执行proc_file.sh脚本任务..."
sh -x /scripts/docker/proc_file.sh

echo "第10步加载最新的定时任务文件..."
crontab $mergedListFile

echo "第11步将仓库的docker_entrypoint.sh脚本更新至系统/usr/local/bin/docker_entrypoint.sh内..."
cat /jds/jd_scripts/docker_entrypoint.sh >/usr/local/bin/docker_entrypoint.sh

# echo "第12步打包脚本文件到/scripts/logs/scripts.tar.gz"
# apk add tar
# tar -zcvf /scripts/logs/scripts.tar.gz --exclude=scripts/node_modules --exclude=scripts/logs/*.log  --exclude=scripts/logs/*.gz /scripts
