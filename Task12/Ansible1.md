Шаг 1: Подготовка окружения  
Создаем рабочую директорию и файлы  
bash  
mkdir ansible-nginx && cd ansible-nginx  
Создаем Vagrantfile  
ruby  
# Vagrantfile  
Vagrant.configure("2") do |config|  
  config.vm.define "nginx" do |nginx|  
    nginx.vm.box = "ubuntu/focal64"  
    nginx.vm.network "private_network", ip: "192.168.56.10"  
    nginx.vm.provider "virtualbox" do |vb|  
      vb.memory = "1024"  
      vb.cpus = 1  
    end  
  end  
end  
Шаг 2: Запускаем виртуальную машину  
bash  
vagrant up  
Проверяем доступность хоста  
bash  
vagrant ssh-config  
Шаг 3: Установка Ansible  
bash  
# Для Ubuntu/Debian  
sudo apt update  
sudo apt install -y software-properties-common  
sudo apt-add-repository --yes --update ppa:ansible/ansible  
sudo apt install -y ansible  
  
# Проверяем версию  
ansible --version  
Шаг 4: Настройка Ansible  
Создаем структуру каталогов  
bash  
mkdir -p staging group_vars templates roles/nginx/tasks roles/nginx/handlers roles/nginx/templates  
Создаем inventory файл  
bash  
# staging/hosts  
[web]  
nginx ansible_host=192.168.56.10 ansible_port=22 ansible_user=vagrant ansible_private_key_file=.vagrant/machines/nginx/virtualbox/private_key  
Создаем конфигурационный файл ansible.cfg  
ini  
# ansible.cfg  
[defaults]  
inventory = staging/hosts  
remote_user = vagrant  
host_key_checking = False  
retry_files_enabled = False  
private_key_file = .vagrant/machines/nginx/virtualbox/private_key  
Проверяем подключение  
bash  
ansible all -m ping  
Шаг 5: Создаем Ansible роль для nginx  
Создаем главный playbook  
yaml  
# nginx.yml  
---  
- name: Deploy and configure NGINX  
  hosts: web  
  become: true  
  vars:  
    nginx_listen_port: 8080  
      
  roles:  
    - nginx  
Создаем задачи для роли nginx  
yaml  
# roles/nginx/tasks/main.yml  
---  
- name: Update apt cache  
  apt:  
    update_cache: yes  
    cache_valid_time: 3600  
  
- name: Install NGINX  
  apt:  
    name: nginx  
    state: present  
  
- name: Create NGINX config directory  
  file:  
    path: /etc/nginx/conf.d  
    state: directory  
    owner: root  
    group: root  
    mode: '0755'  
  
- name: Copy NGINX configuration from template  
  template:  
    src: nginx.conf.j2  
    dest: /etc/nginx/conf.d/default.conf  
  notify:  
    - reload nginx  
  
- name: Ensure NGINX is running and enabled  
  systemd:  
    name: nginx  
    state: started  
    enabled: yes  
Создаем handlers для nginx  
yaml  
# roles/nginx/handlers/main.yml  
---  
- name: restart nginx  
  systemd:  
    name: nginx  
    state: restarted  
    enabled: yes  
  
- name: reload nginx  
  systemd:  
    name: nginx  
    state: reloaded  
Создаем шаблон конфигурации nginx  
nginx  
# roles/nginx/templates/nginx.conf.j2  
server {  
    listen {{ nginx_listen_port }} default_server;  
    listen [::]:{{ nginx_listen_port }} default_server;  
      
    root /var/www/html;  
    index index.html index.htm;  
      
    server_name _;  
      
    location / {  
        try_files $uri $uri/ =404;  
    }  
}  
Шаг 6: Запускаем playbook  
Проверяем синтаксис  
bash  
ansible-playbook --syntax-check nginx.yml  
Запускаем в тестовом режиме (dry-run)  
bash  
ansible-playbook --check nginx.yml  
Запускаем playbook  
bash  
ansible-playbook nginx.yml  
Шаг 7: Проверяем результат  
Проверяем статус nginx на удаленном хосте  
bash  
ansible web -m shell -a "systemctl status nginx"  
Проверяем порт прослушивания  
bash  
ansible web -m shell -a "netstat -tlnp | grep nginx"  
Тестируем доступность через curl  
bash  
curl http://192.168.56.10:8080  
