# TASK 8 Инициализация системы. Systemd 

## 1. Service для мониторинга лога

### Создание конфигурационного файла
```bash
sudo nano /etc/default/log-monitor

ini

LOG_FILE=/var/log/application/error.log
KEYWORD=CRITICAL
CHECK_INTERVAL=30

### Создание скрипта мониторинга

bash

sudo nano /usr/local/bin/log-monitor.sh

bash

#!/bin/bash

# Загрузка конфигурации
source /etc/default/log-monitor

# Проверка существования файла лога
if [[ ! -f "$LOG_FILE" ]]; then
    echo "Log file $LOG_FILE does not exist"
    exit 1
fi

# Основной цикл мониторинга
while true; do
    if grep -q "$KEYWORD" "$LOG_FILE"; then
        echo "$(date): Keyword '$KEYWORD' found in $LOG_FILE" | systemd-cat -p warning -t log-monitor
        # Дополнительные действия при обнаружении ключевого слова
    fi
    sleep $CHECK_INTERVAL
done

bash

sudo chmod +x /usr/local/bin/log-monitor.sh

### Создание systemd service

bash

sudo nano /etc/systemd/system/log-monitor.service

ini

[Unit]
Description=Log Monitor Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/log-monitor.sh
Restart=always
RestartSec=10
User=root

[Install]
WantedBy=multi-user.target

### Активация сервиса

bash

sudo systemctl daemon-reload
sudo systemctl enable log-monitor.service
sudo systemctl start log-monitor.service

## 2. Установка spawn-fcgi и создание unit-файла

### Установка spawn-fcgi

bash

sudo apt update
sudo apt install spawn-fcgi

### Создание unit-файла на основе init-скрипта

bash

sudo nano /etc/systemd/system/spawn-fcgi.service

ini

[Unit]
Description=Spawn FCGI service
After=network.target

[Service]
Type=forking
PIDFile=/var/run/spawn-fcgi.pid
ExecStart=/usr/bin/spawn-fcgi -a 127.0.0.1 -p 9000 -u www-data -g www-data -f /usr/bin/php-cgi -P /var/run/spawn-fcgi.pid
ExecStop=/bin/kill -TERM $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

### Альтернативный вариант с параметрами из /etc/default

bash

sudo nano /etc/default/spawn-fcgi

ini

FCGI_SOCKET=127.0.0.1:9000
FCGI_PROGRAM=/usr/bin/php-cgi
FCGI_USER=www-data
FCGI_GROUP=www-data
FCGI_EXTRA_OPTIONS="-P /var/run/spawn-fcgi.pid"

### Обновленный unit-файл с использованием конфигурации

ini

[Unit]
Description=Spawn FCGI service
After=network.target

[Service]
Type=forking
EnvironmentFile=/etc/default/spawn-fcgi
PIDFile=/var/run/spawn-fcgi.pid
ExecStart=/usr/bin/spawn-fcgi -a ${FCGI_SOCKET%:*} -p ${FCGI_SOCKET##*:} -u $FCGI_USER -g $FCGI_GROUP -f $FCGI_PROGRAM $FCGI_EXTRA_OPTIONS
ExecStop=/bin/kill -TERM $MAINPID
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target

### Активация сервиса

bash

sudo systemctl daemon-reload
sudo systemctl enable spawn-fcgi.service
sudo systemctl start spawn-fcgi.service

## 3. Доработка unit-файла Nginx для нескольких инстансов

### Создание шаблона службы

bash

sudo nano /etc/systemd/system/nginx@.service

ini

[Unit]
Description=nginx - high performance web server (%i)
Documentation=https://nginx.org/en/docs/
After=network-online.target remote-fs.target nss-lookup.target
Wants=network-online.target

[Service]
Type=forking
PIDFile=/var/run/nginx-%i.pid
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-%i.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-%i.conf
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s TERM $MAINPID

[Install]
WantedBy=multi-user.target

### Создание конфигурационных файлов для разных инстансов

bash

# Первый инстанс
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx-1.conf
sudo sed -i 's|/var/run/nginx.pid|/var/run/nginx-1.pid|' /etc/nginx/nginx-1.conf

# Второй инстанс
sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx-2.conf
sudo sed -i 's|/var/run/nginx.pid|/var/run/nginx-2.pid|' /etc/nginx/nginx-2.conf
sudo sed -i 's|listen 80|listen 8080|' /etc/nginx/nginx-2.conf

### Запуск нескольких инстансов

bash

sudo systemctl daemon-reload
sudo systemctl enable nginx@1.service
sudo systemctl enable nginx@2.service
sudo systemctl start nginx@1.service
sudo systemctl start nginx@2.service

### Проверка статуса

bash

sudo systemctl status nginx@1.service
sudo systemctl status nginx@2.service

### Альтернативный вариант с помощью instantiated services

bash

sudo mkdir -p /etc/systemd/system/nginx.service.d
sudo nano /etc/systemd/system/nginx.service.d/override.conf

ini

[Unit]
Description=nginx - multiple instances
After=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-1.conf
ExecStartPre=/usr/sbin/nginx -t -c /etc/nginx/nginx-2.conf
ExecStart=/usr/sbin/nginx -c /etc/nginx/nginx-1.conf
ExecStartPost=/bin/sleep 2
ExecStartPost=/usr/sbin/nginx -c /etc/nginx/nginx-2.conf

ExecReload=/bin/kill -s HUP $(cat /var/run/nginx-1.pid)
ExecReload=/bin/kill -s HUP $(cat /var/run/nginx-2.pid)

ExecStop=/bin/kill -s TERM $(cat /var/run/nginx-1.pid)
ExecStop=/bin/kill -s TERM $(cat /var/run/nginx-2.pid)

### Пример Ansible плейбука для автоматизации

yaml

---
- name: Configure Ubuntu 24.04 services
  hosts: all
  become: yes
  tasks:
    - name: Install required packages
      apt:
        name:
          - spawn-fcgi
          - nginx
        state: present
        update_cache: yes

    - name: Create log monitor configuration
      copy:
        content: | LOG_FILE=/var/log/application/error.log
          KEYWORD=CRITICAL
          CHECK_INTERVAL=30
        dest: /etc/default/log-monitor
        owner: root
        group: root
        mode: 0644

    - name: Deploy log monitor script
      copy:
        src: files/log-monitor.sh
        dest: /usr/local/bin/log-monitor.sh
        owner: root
        group: root
        mode: 0755

    - name: Deploy log monitor service
      copy:
        src: files/log-monitor.service
        dest: /etc/systemd/system/log-monitor.service
        owner: root
        group: root
        mode: 0644

    - name: Deploy spawn-fcgi service
      copy:
        src: files/spawn-fcgi.service
        dest: /etc/systemd/system/spawn-fcgi.service
        owner: root
        group: root
        mode: 0644

    - name: Deploy nginx template service
      copy:
        src: files/nginx@.service
        dest: /etc/systemd/system/nginx@.service
        owner: root
        group: root
        mode: 0644

    - name: Reload systemd
      systemd:
        daemon_reload: yes

    - name: Enable and start services
      systemd:
        name: "{{ item }}"
        enabled: yes
        state: started
      loop:
        - log-monitor
        - spawn-fcgi
        - nginx@1
