markdown
# ZFS Практическое задание

## Создание ZFS пулов и тестирование сжатия

### Подготовка окружения
Перешли в домашнюю директорию пользователя и создали исполняемый скрипт:
```bash
sudo -i
cd /home/zfs/
vi zfs.sh
chmod +x zfs.sh

## Доступные диски ##
### Просмотр доступных дисковых устройств: ###

text
NAME                      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
sda                         8:0    0   25G  0 disk
├─sda1                      8:1    0    1M  0 part
├─sda2                      8:2    0    2G  0 part /boot
└─sda3                      8:3    0   23G  0 part
  └─ubuntu--vg-ubuntu--lv 252:0    0 11.5G  0 lvm  /
sdb                         8:16   0  512M  0 disk
sdc                         8:32   0  512M  0 disk
sdd                         8:48   0  512M  0 disk
sde                         8:64   0  512M  0 disk
sdf                         8:80   0  512M  0 disk
sdg                         8:96   0  512M  0 disk
sdh                         8:112  0  512M  0 disk
sdi                         8:128  0  512M  0 disk
Создание ZFS пулов в режиме RAID 1
Запуск скрипта создал 4 пула:

text
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   164K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   164K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   132K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M    94K   480M        -         -     0%     0%  1.00x    ONLINE  -
Настройка алгоритмов сжатия
Для каждого пула установлен свой алгоритм сжатия:

text
otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip-9                 local
otus4  compression           zle                    local
Тестирование сжатия
Скачан тестовый файл (39M) во все пулы:

bash
wget https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Результаты сжатия
Размеры файлов после сжатия:

text
/otus1: total 22111     (lzjb)
/otus2: total 18013     (lz4) 
/otus3: total 10969     (gzip-9)
/otus4: total 28699     (zle)
Используемое пространство и коэффициенты сжатия:

text
NAME    USED  AVAIL  REFER  MOUNTPOINT  COMPRESSRATIO
otus1  21.7M   330M  21.6M  /otus1      1.82x
otus2  17.7M   334M  17.6M  /otus2      2.23x
otus3  10.9M   341M  10.7M  /otus3      3.66x
otus4  28.2M   324M  28.0M  /otus4      1.00x
Работа с экспортированным пулом
Скачан и распакован архив:

bash
wget https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb
tar -xzf archive.tar.gz
Импорт пула otus:

bash
zpool import -d zpoolexport/ otus
Параметры пула otus
Ключевые параметры импортированного пула:

Размер: 350M available

Тип доступа: readonly off

Размер записи: 128K recordsize

Тип сжатия: zle compression

Тип контрольной суммы: sha256 checksum

Восстановление из снапшота
Скачан файл снапшота:

bash
wget https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI
Восстановление данных:

bash
zfs receive otus/test@today < otus_task2.file
Поиск и чтение секретного сообщения:

bash
find /otus/test -name "secret_message"
cat /otus/test/task1/file_mess/secret_message
https://otus.ru/lessons/linux-hl/
