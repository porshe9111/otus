#!/bin/bash

# Скрипт настройки NFS-сервера для Ubuntu 24.04
# Требует запуска с правами root

set -e  # Завершать скрипт при любой ошибке

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: Скрипт должен быть запущен с правами root"
    echo "Используйте: sudo $0"
    exit 1
fi

echo "=== Настройка NFS-сервера ==="

# Установка NFS-сервера
echo "Устанавливаем NFS-сервер..."
apt update
apt install -y nfs-kernel-server

echo "Проверяем сетевые порты..."
ss -tnplu | grep -E '(2049|111)'

# Создание и настройка директории
echo "Создаем директорию для экспорта..."
mkdir -p /srv/share/upload
chown -R nobody:nogroup /srv/share
chmod 0777 /srv/share/upload

# Настройка экспорта
echo "Настраиваем экспорт директории..."
cat > /etc/exports << EOF
/srv/share 192.168.50.11/32(rw,sync,root_squash)
EOF

# Применение настроек
echo "Применяем настройки экспорта..."
exportfs -r

# Проверка настроек
echo "Проверяем экспортированные директории..."
exportfs -s

echo "Перезапускаем службы NFS..."
systemctl restart nfs-server
systemctl enable nfs-server

echo "Проверяем статус служб..."
systemctl status nfs-server --no-pager -l

echo "=== Настройка завершена ==="
echo "Проверьте экспортированные директории:"
exportfs -v

# Дополнительная проверка портов
echo ""
echo "Проверка открытых портов:"
ss -tnplu | grep -E '(2049|111)' || echo "Порты 2049 или 111 не найдены"
