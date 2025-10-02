# TASK 8 Инициализация системы. Systemd   
  
# Автоматизация настройки системы мониторинга логов, установку spawn-fcgi и конфигурацию Nginx для запуска нескольких инстансов на Ubuntu.    
  
Ansible плейбук setup-services.yml  
yaml  
---  
- name: Настройка системы мониторинга и сервисов  
  hosts: all  
  become: yes  
  vars:  
    monitor_keyword: "ERROR"  
    monitor_logfile: "/var/log/syslog"  
    nginx_instances:  
      - name: nginx-main  
        config: "/etc/nginx/nginx.conf"  
        port: 80  
      - name: nginx-alt  
        config: "/etc/nginx/nginx-alt.conf"  
        port: 8080  
  
  tasks:  
    - name: Обновление списка пакетов  
      apt:  
        update_cache: yes  
  
    - name: Установка необходимых пакетов  
      apt:  
        name:  
          - spawn-fcgi  
          - nginx  
          - python3  
          - python3-pip  
        state: present  
  
    - name: Создание директории для конфигурации мониторинга  
      file:  
        path: /etc/default  
        state: directory  
        mode: 0755  
  
    - name: Создание конфигурационного файла для мониторинга  
      copy:  
        content: |  
          # Конфигурация мониторинга логов  
          KEYWORD="{{ monitor_keyword }}"  
          LOGFILE="{{ monitor_logfile }}"  
          INTERVAL=30  
        dest: /etc/default/log-monitor  
        mode: 0644  
  
    - name: Создание скрипта мониторинга  
      copy:  
        content: |  
          #!/bin/bash  
          # Скрипт мониторинга логов  
          source /etc/default/log-monitor  
  
          if [[ -z "  KEYWORD" || -z "  LOGFILE" ]]; then  
              echo "Ошибка: KEYWORD или LOGFILE не установлены в /etc/default/log-monitor"  
              exit 1  
          fi  
  
          if [[ ! -f "  LOGFILE" ]]; then  
              echo "Ошибка: Файл лога   LOGFILE не существует"  
              exit 1  
          fi  
  
          while true; do  
              if tail -n 50 "  LOGFILE" | grep -q "  KEYWORD"; then  
                  echo "  (date): Обнаружено ключевое слово '  KEYWORD' в   LOGFILE" >> /var/log/monitor-service.log  
              fi  
              sleep   INTERVAL  
          done  
        dest: /usr/local/bin/monitor-log.sh  
        mode: 0755  
  
    - name: Создание systemd service для мониторинга  
      copy:  
        content: |  
          [Unit]  
          Description=Log Monitor Service  
          After=network.target  
  
          [Service]  
          Type=simple  
          ExecStart=/usr/local/bin/monitor-log.sh  
          Restart=always  
          RestartSec=10  
          User=root  
          EnvironmentFile=/etc/default/log-monitor  
  
          [Install]  
          WantedBy=multi-user.target  
        dest: /etc/systemd/system/monitor-log.service  
        mode: 0644  
  
    - name: Создание unit-файла для spawn-fcgi  
      copy:  
        content: |  
          [Unit]  
          Description=Spawn-fcgi service  
          After=network.target  
  
          [Service]  
          Type=forking  
          PIDFile=/var/run/spawn-fcgi.pid  
          ExecStart=/usr/bin/spawn-fcgi -a 127.0.0.1 -p 9000 -u www-data -g www-data -f /usr/bin/php-cgi -P /var/run/spawn-fcgi.pid  
          ExecStop=/bin/kill -15   MAINPID  
          Restart=on-failure  
          RestartSec=10  
  
          [Install]  
          WantedBy=multi-user.target  
        dest: /etc/systemd/system/spawn-fcgi.service  
        mode: 0644  
  
    - name: Создание дополнительных конфигураций Nginx  
      block:  
        - name: Создание альтернативной конфигурации Nginx  
          copy:  
            content: |  
              user www-data;  
              worker_processes auto;  
              pid /run/nginx-alt.pid;  
  
              events {  
                  worker_connections 768;  
              }  
  
              http {  
                  sendfile on;  
                  tcp_nopush on;  
                  tcp_nodelay on;  
                  keepalive_timeout 65;  
                  types_hash_max_size 2048;  
  
                  include /etc/nginx/mime.types;  
                  default_type application/octet-stream;  
  
                  access_log /var/log/nginx/alt-access.log;  
                  error_log /var/log/nginx/alt-error.log;  
  
                  server {  
                      listen 8080;  
                      listen [::]:8080;  
  
                      root /var/www/html;  
                      index index.html index.htm;  
  
                      location / {  
                          try_files   uri   uri/ =404;  
                      }  
                  }  
              }  
            dest: "{{ item.config }}"  
          loop: "{{ nginx_instances }}"  
          when: item.name == "nginx-alt"  
  
    - name: Создание systemd служб для каждого инстанса Nginx  
      copy:  
        content: |  
          [Unit]  
          Description=nginx - high performance web server for {{ item.name }}  
          Documentation=https://nginx.org/en/docs/  
          After=network.target  
  
          [Service]  
          Type=forking  
          PIDFile=/run/nginx-{{ item.name | replace('nginx-', '') }}.pid  
          ExecStart=/usr/sbin/nginx -c {{ item.config }}  
          ExecReload=/bin/kill -s HUP   MAINPID  
          ExecStop=/bin/kill -s TERM   MAINPID  
          Restart=on-failure  
          RestartSec=10  
  
          [Install]  
          WantedBy=multi-user.target  
        dest: "/etc/systemd/system/{{ item.name }}.service"  
      loop: "{{ nginx_instances }}"  
  
    - name: Перезагрузка systemd daemon  
      systemd:  
        daemon_reload: yes  
  
    - name: Запуск и включение службы мониторинга  
      systemd:  
        name: monitor-log  
        state: started  
        enabled: yes  
  
    - name: Запуск и включение spawn-fcgi  
      systemd:  
        name: spawn-fcgi  
        state: started  
        enabled: yes  
  
    - name: Запуск и включение инстансов Nginx  
      systemd:  
        name: "{{ item.name }}"  
        state: started  
        enabled: yes  
      loop: "{{ nginx_instances }}"  
  
    - name: Проверка статуса служб  
      command: systemctl status "{{ item }}"  
      register: service_status  
      loop:  
        - monitor-log  
        - spawn-fcgi  
        - nginx-main  
      ignore_errors: yes  
  
    - name: Вывод статуса служб  
      debug:  
        msg: "Статус {{ item.item }}: {{ item.stdout }}"  
      loop: "{{ service_status.results }}"  
# Файл инвентаризации inventory.ini  
ini  
[webservers]  
server1 ansible_host=10.20.30.1
  
[webservers:vars]  
ansible_ssh_private_key_file=~/.ssh/your-private-key  
Использование  
1. Подготовка окружения  
bash  
# Клонирование репозитория с решением  
git clone <repository-url>  
cd ansible-ubuntu-services  
  
# Настройка инвентаризации    
cp inventory.example.ini inventory.ini  
# Отредактировать inventory.ini
2. Запуск Ansible плейбука  
bash  
# Проверка синтаксиса    
ansible-playbook --syntax-check setup-services.yml  
  
# Запуск плейбука    
ansible-playbook -i inventory.ini setup-services.yml  
3. Проверка работы сервисов  
bash  
# Проверка статуса службы мониторинга    
systemctl status monitor-log  
  
# Проверка статуса spawn-fcgi    
systemctl status spawn-fcgi  
  
# Проверка статуса инстансов Nginx    
systemctl status nginx-main  
systemctl status nginx-alt  
  
# Просмотр логов мониторинга    
tail -f /var/log/monitor-service.log  
Конфигурационные файлы  
/etc/default/log-monitor  
bash  
# Конфигурация мониторинга логов    
KEYWORD="ERROR"  
LOGFILE="/var/log/syslog"  
INTERVAL=30  
Мониторинг логов  
•	Сервис: monitor-log.service  
•	Скрипт: /usr/local/bin/monitor-log.sh  
•	Конфигурация: /etc/default/log-monitor  
•	Логи: /var/log/monitor-service.log  
Spawn-fcgi  
•	Сервис: spawn-fcgi.service  
•	Порт: 9000  
•	Пользователь: www-data  
Nginx инстансы  
•	nginx-main: порт 80, конфиг /etc/nginx/nginx.conf  
•	nginx-alt: порт 8080, конфиг /etc/nginx/nginx-alt.conf  
Управление сервисами  
bash  
# Перезапуск мониторинга    
sudo systemctl restart monitor-log  
  
# Просмотр логов мониторинга    
sudo journalctl -u monitor-log -f  
  
# Изменение ключевого слова для мониторинга    
sudo nano /etc/default/log-monitor  
sudo systemctl restart monitor-log  
  
# Проверка работы Nginx инстансов    
curl http://localhost  
curl http://localhost:8080  
.  
  
  
