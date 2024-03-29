#!/bin/bash
clear

red='\033[0;31m'
green='\033[0;32m'
plain='\033[0m'


function pre_check() {
    [[ $EUID -ne 0 ]] && echo -e "${red}错误: ${plain} 需要root权限\n" && exit 1

    command -v git >/dev/null 2>&1
    if [[ $? != 0 ]]; then
        echo -e "正在安装Git..."
        apt install git -y >/dev/null 2>&1
        echo -e "${green}Git${plain} 安装成功"
    fi

    command -v curl >/dev/null 2>&1
    if [[ $? != 0 ]]; then
        echo -e "正在安装curl..."
        apt install curl -y >/dev/null 2>&1
        echo -e "${green}curl${plain} 安装成功"
    fi

    command -v docker >/dev/null 2>&1
    if [[ $? != 0 ]]; then
        echo -e "正在安装Docker..."
        bash <(curl -fsL https://get.docker.com) >/dev/null 2>&1
        systemctl enable docker.service
        systemctl enable containerd.service
        groupadd docker
        usermod -aG docker $USER
        echo -e "${green}Docker${plain} 安装成功"
        curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        chmod +x /usr/local/bin/docker-compose
        docker-compose version
    fi

    command -v tar >/dev/null 2>&1
    if [[ $? != 0 ]]; then
        echo -e "正在安装tar..."
        apt install tar -y >/dev/null 2>&1
        echo -e "${green}tar${plain} 安装成功"
    fi
}

pre_check
