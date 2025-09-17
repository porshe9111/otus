zfs@zfs:~$ sudo -i
[sudo] password for zfs:
root@zfs:~# cd /home/zfs/
root@zfs:/home/zfs# vi zfs.sh
root@zfs:/home/zfs# ls -lh
total 4.0K
-rw-rw-r-- 1 zfs zfs 3.3K Sep 17 17:51 zfs.sh
root@zfs:/home/zfs# chmod +x zfs.sh
root@zfs:/home/zfs# lsblk
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
sr0                        11:0    1  2.6G  0 rom
root@zfs:/home/zfs# ./zfs.sh
=== Создание пулов ZFS в режиме RAID 1 ===


=== Информация о пулах ===
NAME    SIZE  ALLOC   FREE  CKPOINT  EXPANDSZ   FRAG    CAP  DEDUP    HEALTH  ALTROOT
otus1   480M   164K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus2   480M   164K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus3   480M   132K   480M        -         -     0%     0%  1.00x    ONLINE  -
otus4   480M    94K   480M        -         -     0%     0%  1.00x    ONLINE  -

=== Настройка разных алгоритмов сжатия ===

=== Проверка методов сжатия ===
otus1  compression           lzjb                   local
otus2  compression           lz4                    local
otus3  compression           gzip-9                 local
otus4  compression           zle                    local

=== Скачивание тестового файла во все пулы ===
--2025-09-17 17:52:14--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41174169 (39M) [text/plain]
Saving to: ‘/otus1/pg2600.converter.log’

pg2600.converter.log            100%[=====================================================>]  39.27M  6.15MB/s    in 7.0s

2025-09-17 17:52:22 (5.64 MB/s) - ‘/otus1/pg2600.converter.log’ saved [41174169/41174169]

--2025-09-17 17:52:22--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41174169 (39M) [text/plain]
Saving to: ‘/otus2/pg2600.converter.log’

pg2600.converter.log            100%[=====================================================>]  39.27M  9.21MB/s    in 5.1s

2025-09-17 17:52:27 (7.75 MB/s) - ‘/otus2/pg2600.converter.log’ saved [41174169/41174169]

--2025-09-17 17:52:27--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41174169 (39M) [text/plain]
Saving to: ‘/otus3/pg2600.converter.log’

pg2600.converter.log            100%[=====================================================>]  39.27M  7.13MB/s    in 6.1s

2025-09-17 17:52:34 (6.40 MB/s) - ‘/otus3/pg2600.converter.log’ saved [41174169/41174169]

--2025-09-17 17:52:34--  https://gutenberg.org/cache/epub/2600/pg2600.converter.log
Resolving gutenberg.org (gutenberg.org)... 152.19.134.47, 2610:28:3090:3000:0:bad:cafe:47
Connecting to gutenberg.org (gutenberg.org)|152.19.134.47|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 41174169 (39M) [text/plain]
Saving to: ‘/otus4/pg2600.converter.log’

pg2600.converter.log            100%[=====================================================>]  39.27M  8.97MB/s    in 5.3s

2025-09-17 17:52:40 (7.44 MB/s) - ‘/otus4/pg2600.converter.log’ saved [41174169/41174169]


=== Проверка размера файлов ===
/otus1:
total 22111
-rw-r--r-- 1 root root 41174169 Sep  2 07:31 pg2600.converter.log

/otus2:
total 18013
-rw-r--r-- 1 root root 41174169 Sep  2 07:31 pg2600.converter.log

/otus3:
total 10969
-rw-r--r-- 1 root root 41174169 Sep  2 07:31 pg2600.converter.log

/otus4:
total 28699
-rw-r--r-- 1 root root 41174169 Sep  2 07:31 pg2600.converter.log

=== Используемое пространство в пулах ===
NAME    USED  AVAIL  REFER  MOUNTPOINT
otus1  21.7M   330M  21.6M  /otus1
otus2  17.7M   334M  17.6M  /otus2
otus3  10.9M   341M  10.7M  /otus3
otus4  28.2M   324M  28.0M  /otus4

=== Коэффициенты сжатия ===
otus1  compressratio         1.82x                  -
otus2  compressratio         2.23x                  -
otus3  compressratio         3.66x                  -
otus4  compressratio         1.00x                  -

=== Скачивание и распаковка архива ===
--2025-09-17 17:52:40--  https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download
Resolving drive.usercontent.google.com (drive.usercontent.google.com)... 74.125.205.132, 2a00:1450:4007:806::2001
Connecting to drive.usercontent.google.com (drive.usercontent.google.com)|74.125.205.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 7275140 (6.9M) [application/octet-stream]
Saving to: ‘archive.tar.gz’

archive.tar.gz                  100%[=====================================================>]   6.94M  11.3MB/s    in 0.6s

2025-09-17 17:52:47 (11.3 MB/s) - ‘archive.tar.gz’ saved [7275140/7275140]

zpoolexport/
zpoolexport/filea
zpoolexport/fileb

=== Проверка возможности импорта пула ===
   pool: otus
     id: 6554193320433390805
  state: ONLINE
status: Some supported features are not enabled on the pool.
        (Note that they may be intentionally disabled if the
        'compatibility' property is set.)
 action: The pool can be imported using its name or numeric identifier, though
        some features will not be available without an explicit 'zpool upgrade'.
 config:

        otus                             ONLINE
          mirror-0                       ONLINE
            /home/zfs/zpoolexport/filea  ONLINE
            /home/zfs/zpoolexport/fileb  ONLINE

=== Импорт пула ===

=== Статус импортированного пула ===
  pool: otus
 state: ONLINE
status: Some supported and requested features are not enabled on the pool.
        The pool can still be used, but some features are unavailable.
action: Enable all features using 'zpool upgrade'. Once this is done,
        the pool may no longer be accessible by software that does not support
        the features. See zpool-features(7) for details.
config:

        NAME                             STATE     READ WRITE CKSUM
        otus                             ONLINE       0     0     0
          mirror-0                       ONLINE       0     0     0
            /home/zfs/zpoolexport/filea  ONLINE       0     0     0
            /home/zfs/zpoolexport/fileb  ONLINE       0     0     0

errors: No known data errors

=== Все параметры пула otus ===
NAME  PROPERTY              VALUE                  SOURCE
otus  type                  filesystem             -
otus  creation              Fri May 15  4:00 2020  -
otus  used                  2.04M                  -
otus  available             350M                   -
otus  referenced            24K                    -
otus  compressratio         1.00x                  -
otus  mounted               yes                    -
otus  quota                 none                   default
otus  reservation           none                   default
otus  recordsize            128K                   local
otus  mountpoint            /otus                  default
otus  sharenfs              off                    default
otus  checksum              sha256                 local
otus  compression           zle                    local
otus  atime                 on                     default
otus  devices               on                     default
otus  exec                  on                     default
otus  setuid                on                     default
otus  readonly              off                    default
otus  zoned                 off                    default
otus  snapdir               hidden                 default
otus  aclmode               discard                default
otus  aclinherit            restricted             default
otus  createtxg             1                      -
otus  canmount              on                     default
otus  xattr                 on                     default
otus  copies                1                      default
otus  version               5                      -
otus  utf8only              off                    -
otus  normalization         none                   -
otus  casesensitivity       sensitive              -
otus  vscan                 off                    default
otus  nbmand                off                    default
otus  sharesmb              off                    default
otus  refquota              none                   default
otus  refreservation        none                   default
otus  guid                  14592242904030363272   -
otus  primarycache          all                    default
otus  secondarycache        all                    default
otus  usedbysnapshots       0B                     -
otus  usedbydataset         24K                    -
otus  usedbychildren        2.01M                  -
otus  usedbyrefreservation  0B                     -
otus  logbias               latency                default
otus  objsetid              54                     -
otus  dedup                 off                    default
otus  mlslabel              none                   default
otus  sync                  standard               default
otus  dnodesize             legacy                 default
otus  refcompressratio      1.00x                  -
otus  written               24K                    -
otus  logicalused           1020K                  -
otus  logicalreferenced     12K                    -
otus  volmode               default                default
otus  filesystem_limit      none                   default
otus  snapshot_limit        none                   default
otus  filesystem_count      none                   default
otus  snapshot_count        none                   default
otus  snapdev               hidden                 default
otus  acltype               off                    default
otus  context               none                   default
otus  fscontext             none                   default
otus  defcontext            none                   default
otus  rootcontext           none                   default
otus  relatime              on                     default
otus  redundant_metadata    all                    default
otus  overlay               on                     default
otus  encryption            off                    default
otus  keylocation           none                   default
otus  keyformat             none                   default
otus  pbkdf2iters           0                      default
otus  special_small_blocks  0                      default

=== Конкретные параметры пула otus ===
Размер:
NAME  PROPERTY   VALUE  SOURCE
otus  available  350M   -

Тип доступа:
NAME  PROPERTY  VALUE   SOURCE
otus  readonly  off     default

Размер записи:
NAME  PROPERTY    VALUE    SOURCE
otus  recordsize  128K     local

Тип сжатия:
NAME  PROPERTY     VALUE           SOURCE
otus  compression  zle             local

Тип контрольной суммы:
NAME  PROPERTY  VALUE      SOURCE
otus  checksum  sha256     local

=== Скачивание файла снапшота ===

=== Восстановление из снапшота ===
--2025-09-17 17:52:52--  https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI
cannot receive: failed to read from stream
root@zfs:/home/zfs# Resolving drive.usercontent.google.com (drive.usercontent.google.com)... 74.125.205.132, 2a00:1450:4007:806::2001
Connecting to drive.usercontent.google.com (drive.usercontent.google.com)|74.125.205.132|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 5432736 (5.2M) [application/octet-stream]
Saving to: ‘otus_task2.file’

otus_task2.file                 100%[=====================================================>]   5.18M  15.8MB/s    in 0.3s

2025-09-17 17:52:55 (15.8 MB/s) - ‘otus_task2.file’ saved [5432736/5432736]

~
-bash: /root: Is a directory
root@zfs:/home/zfs# zfs create otus/test
cannot create 'otus/test': dataset already exists
root@zfs:/home/zfs# zfs receive otus/test@today < otus_task2.file
cannot receive new filesystem stream: destination 'otus/test' exists
must specify -F to overwrite it
root@zfs:/home/zfs# find /otus/test -name "secret_message"
root@zfs:/home/zfs# cat /otus/test/task1/file_mess/secret_message
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
Доступные диски
Просмотр доступных дисковых устройств:

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
