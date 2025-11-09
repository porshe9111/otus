## Vagrantfile  
Vagrant.configure("2") do |config|  
  # Используем базовый образ Ubuntu  
  config.vm.box = "ubuntu/focal64"  
    
  # Настройка памяти ВМ  
  config.vm.provider "virtualbox" do |vb|  
    vb.memory = 1024  
      
    # Добавление двух виртуальных дисков по 1 ГБ  
    vb.customize ['createhd', '--filename', 'disk1.vdi', '--size', 1024]  
    vb.customize ['createhd', '--filename', 'disk2.vdi', '--size', 1024]  
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', 'disk1.vdi']  
    vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', 'disk2.vdi']  
  end  
    
  # Настройка сети - проброс порта 80 гостевой на 8080 хостовой  
  config.vm.network "forwarded_port", guest: 80, host: 8080  
    
  # Провижининг  
  config.vm.provision "shell", inline: <<-SHELL  
    # Обновление пакетов  
    apt-get update  
      
    # Поиск добавленных дисков  
    DISK1=$(lsblk -o NAME,SIZE | grep "1G" | head -1 | awk '{print $1}')  
    DISK2=$(lsblk -o NAME,SIZE | grep "1G" | tail -1 | awk '{print $1}')  
      
    echo "Найденные диски: $DISK1 и $DISK2"  
      
    # Форматирование дисков в ext4  
    mkfs.ext4 /dev/$DISK1  
    mkfs.ext4 /dev/$DISK2  
      
    # Создание точек монтирования  
    mkdir -p /mnt/disk1  
    mkdir -p /mnt/disk2  
      
    # Монтирование дисков  
    mount /dev/$DISK1 /mnt/disk1  
    mount /dev/$DISK2 /mnt/disk2  
      
    # Добавление записей в fstab для автоматического монтирования  
    echo "/dev/$DISK1 /mnt/disk1 ext4 defaults 0 0" >> /etc/fstab  
    echo "/dev/$DISK2 /mnt/disk2 ext4 defaults 0 0" >> /etc/fstab  
      
    # Установка веб-сервера для проверки проброса портов  
    apt-get install -y nginx  
      
    echo "Провижининг завершен успешно!"  
  SHELL  
end  
Используемые команды в провижининге:  
apt-get update - обновление информации о пакетах  
  
lsblk -o NAME,SIZE - просмотр блочных устройств и их размеров  
  
grep "1G" - фильтрация строк с размером 1ГБ  
  
head -1 / tail -1 - получение первой/последней строки  
  
awk '{print $1}' - извлечение первого столбца (имя устройства)  
  
mkfs.ext4 - форматирование в файловую систему ext4  
  
mkdir -p - создание директорий с родительскими каталогами  
  
mount - монтирование файловых систем  
  
echo "... >> /etc/fstab - добавление записей в файл fstab  
  
apt-get install -y nginx - установка веб-сервера nginx  
  
Команды для выполнения:  
Создание и запуск ВМ:  
  
bash  
vagrant up  
Подключение к ВМ:  
  
bash  
vagrant ssh  
Проверка монтирования дисков (внутри ВМ):  
  
bash  
df -h  
Проверка проброса портов (на хостовой машине):  
  
bash  
netstat -tulpn | grep 8080  
Ожидаемый вывод:  
Команда df -h покажет:  
  
text  
Filesystem      Size  Used Avail Use% Mounted on  
/dev/sda1        ...   ...   ...   ... /  
/dev/sdb1       1.0G   ...   ...   ... /mnt/disk1  
/dev/sdc1       1.0G   ...   ...   ... /mnt/disk2  
Команда netstat -tulpn | grep 8080 покажет:  
  
text  
tcp6       0      0 :::8080                 :::*                    LISTEN      .../VBoxHeadless  
