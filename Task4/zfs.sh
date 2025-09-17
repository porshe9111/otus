#!/bin/bash

set -e

echo "=== Установка ZFS (если не установлен) ==="
if ! command -v zpool &> /dev/null; then
    apt update
    apt install -y zfsutils-linux
fi

echo -e "\n=== Создание пулов ZFS в режиме RAID 1 ==="

# Создаем пулы
zpool create otus1 mirror /dev/sdb /dev/sdc
zpool create otus2 mirror /dev/sdd /dev/sde
zpool create otus3 mirror /dev/sdf /dev/sdg
zpool create otus4 mirror /dev/sdh /dev/sdi

echo -e "\n=== Информация о пулах ==="
zpool list

echo -e "\n=== Настройка разных алгоритмов сжатия ==="
zfs set compression=lzjb otus1
zfs set compression=lz4 otus2
zfs set compression=gzip-9 otus3
zfs set compression=zle otus4

echo -e "\n=== Проверка методов сжатия ==="
zfs get all | grep compression | grep -v default

echo -e "\n=== Скачивание тестового файла во все пулы ==="
for i in {1..4}; do
    wget -P /otus$i https://gutenberg.org/cache/epub/2600/pg2600.converter.log
done

echo -e "\n=== Проверка размера файлов ==="
ls -l /otus*

echo -e "\n=== Используемое пространство в пулах ==="
zfs list

echo -e "\n=== Коэффициенты сжатия ==="
zfs get all | grep compressratio | grep -v ref

echo -e "\n=== Скачивание и распаковка архива ==="
wget -O archive.tar.gz --no-check-certificate 'https://drive.usercontent.google.com/download?id=1MvrcEp-WgAQe57aDEzxSRalPAwbNN1Bb&export=download'
tar -xzvf archive.tar.gz

echo -e "\n=== Проверка возможности импорта пула ==="
zpool import -d zpoolexport/

echo -e "\n=== Импорт пула ==="
zpool import -d zpoolexport/ otus

echo -e "\n=== Статус импортированного пула ==="
zpool status otus

echo -e "\n=== Все параметры пула otus ==="
zfs get all otus

echo -e "\n=== Конкретные параметры пула otus ==="
echo "Размер:"
zfs get available otus
echo -e "\nТип доступа:"
zfs get readonly otus
echo -e "\nРазмер записи:"
zfs get recordsize otus
echo -e "\nТип сжатия:"
zfs get compression otus
echo -e "\nТип контрольной суммы:"
zfs get checksum otus

echo -e "\n=== Скачивание файла снапшота ==="
wget -O otus_task2.file --no-check-certificate https://drive.usercontent.google.com/download?id=1wgxjih8YZ-cqLqaZVa0lA3h3Y029c3oI&export=download

echo -e "\n=== Восстановление из снапшота ==="
zfs create otus/test
zfs receive otus/test@today < otus_task2.file

echo -e "\n=== Поиск secret_message ==="
find /otus/test -name "secret_message"

echo -e "\n=== Содержимое secret_message ==="
cat /otus/test/task1/file_mess/secret_message