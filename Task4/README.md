# Доступные диски
echo "Просмотр доступных дисковых устройств:"
lsblk

# Создание ZFS пулов в режиме RAID 1
echo "Создание ZFS пулов..."
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi

# Проверка создания пулов
echo "Созданные пулы:"
zpool list

# Настройка алгоритмов сжатия
echo "Настройка алгоритмов сжатия..."
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4

# Проверка настроек сжатия
echo "Текущие настройки сжатия:"
zfs get compression otus1 otus2 otus3 otus4

# Тестирование сжатия
echo "Скачивание тестового файла..."
wget -O /tmp/test_file.txt https://gutenberg.org/cache/epub/2600/pg2600.converter.log

# Копирование файла во все пулы
echo "Копирование файла в пулы..."
cp /tmp/test_file.txt /otus1/
cp /tmp/test_file.txt /otus2/
cp /tmp/test_file.txt /otus3/
cp /tmp/test_file.txt /otus4/

# Результаты сжатия
echo "Результаты сжатия:"
echo "otus1 (lzjb):"
du -sh /otus1/test_file.txt
echo "otus2 (lz4):"
du -sh /otus2/test_file.txt
echo "otus3 (gzip-9):"
du -sh /otus3/test_file.txt
echo "otus4 (zle):"
du -sh /otus4/test_file.txt

# Используемое пространство и коэффициенты сжатия
echo "Статистика использования:"
zfs list -o name,used,avail,refer,compressratio

# Работа с экспортированным пулом
echo "Скачивание и распаковка архива..."
wget -O archive.tar.gz "https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb"
tar -xzf archive.tar.gz

# Импорт пула otus
echo "Импорт пула otus..."
zpool import -d zpoolexport/ otus

# Параметры пула otus
echo "Параметры пула otus:"
zpool list otus
zfs get compression,checksum,recordsize,readonly otus

# Восстановление из снапшота
echo "Скачивание файла снапшота..."
wget -O otus_task2.file "https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI"

# Восстановление данных
echo "Восстановление данных из снапшота..."
zfs receive otus/test@today < otus_task2.file

# Поиск и чтение секретного сообщения
echo "Поиск секретного сообщения..."
find /otus/test -name "secret_message" -exec cat {} \;

EOF
