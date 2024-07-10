#!/bin/bash
install() {
    LOGIN="analys"
    PASSWORD=$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    LOCAL_IP_INTERFACE=$(ip -o -4 addr show | awk '{print $2, $4}' | grep $(hostname -I | awk '{print $1}') | awk '{print $1}')

    touch cred.txt
    echo "$LOGIN:$PASSWORD" > cred.txt

    sudo apt update
    git clone --recurse-submodules https://gitlab.com/packmate/Packmate.git
    cd Packmate
    sudo docker compose stop
    sudo docker compose rm -f
    pwd
    cat <<EOF > .env

# Локальный IP сервера, на который приходит игровой трафик
PACKMATE_LOCAL_IP=$LOCAL_IP
# Имя пользователя для web-авторизации
PACKMATE_WEB_LOGIN=$LOGIN
# Пароль для web-авторизации
PACKMATE_WEB_PASSWORD=$PASSWORD

# Режим работы - перехват
PACKMATE_MODE=LIVE
# Интерфейс, на котором производится перехват трафика
PACKMATE_INTERFACE=$LOCAL_IP_INTERFACE

PACKMATE_OLD_STREAMS_CLEANUP_ENABLED=true
# Интервал удаления старых стримов (в минутах).
# Лучше ставить маленькое число, чтобы стримы удалялись маленькими кусками, и это не нагружало систему
PACKMATE_OLD_STREAMS_CLEANUP_INTERVAL=1
# Насколько старым стрим должен быть для удаления (в минутах от текущего времени)
PACKMATE_OLD_STREAMS_CLEANUP_THRESHOLD=240

EOF

    echo "Файл .env создан"

    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list 
    sudo apt install -y curl
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /tmp/docker.gpg && sudo mv -f /tmp/docker.gpg /etc/apt/keyrings/docker.gpg

    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io

    echo "Докер установлен"

    sudo docker compose up --build -d

    firefox "http://localhost:65000"
    exit
}

status() {
    echo "Checking status..."
    cd Packmate/
    sudo docker ps
}

restart() {
    echo "Restarting Docker container..."
    cd Packmate/
    sudo docker compose restart
}

# Main script
if [ "$1" == "install" ]; then
    install
elif [ "$1" == "status" ]; then
    status
elif [ "$1" == "restart" ]; then
    restart
else
    echo "Usage: $0 {install|status|restart}"
fi
