#!/bin/bash

# Скрипт настройки NFS-клиента для Ubuntu 24.04
# Требует запуска с правами root

set -e  # Завершать скрипт при любой ошибке

# Проверка прав root
if [ "$EUID" -ne 0 ]; then
    echo "Ошибка: Скрипт должен быть запущен с правами root"
    echo "Используйте: sudo $0"
    exit 1
fi

# Параметры конфигурации
NFS_SERVER="192.168.50.10"
SHARE_PATH="/srv/share"
MOUNT_POINT="/mnt"
NFS_OPTIONS="vers=3,noauto,x-systemd.automount"

echo "=== Настройка NFS-клиента ==="

# Установка NFS-клиента
echo "Устанавливаем nfs-common..."
apt update
apt install -y nfs-common

# Создание точки монтирования
echo "Создаем точку монтирования $MOUNT_POINT..."
mkdir -p "$MOUNT_POINT"

# Добавление в fstab
echo "Добавляем запись в /etc/fstab..."

# Проверяем, нет ли уже такой записи
if grep -q "$MOUNT_POINT" /etc/fstab; then
    echo "Запись для $MOUNT_POINT уже существует в fstab"
else
    # Добавляем запись в fstab
    echo "$NFS_SERVER:$SHARE_PATH $MOUNT_POINT nfs $NFS_OPTIONS 0 0" >> /etc/fstab
    echo "Запись добавлена в /etc/fstab"
fi

# Применяем изменения
echo "Применяем изменения systemd..."
systemctl daemon-reload
systemctl restart remote-fs.target

echo "Ждем завершения процесса..."
sleep 2

# Проверяем монтирование
echo "Проверяем монтирование..."
if mount | grep -q "$MOUNT_POINT"; then
    echo "✓ NFS успешно смонтирован"
    mount | grep "$MOUNT_POINT"
else
    echo "⚠ NFS не смонтирован автоматически (ожидается монтирование при первом обращении)"
fi

# Тестируем доступ
echo "Тестируем доступ к NFS..."
if ls "$MOUNT_POINT" >/dev/null 2>&1; then
    echo "✓ Доступ к NFS-шаре успешен"
    echo "Содержимое шары:"
    ls -la "$MOUNT_POINT/"
else
    echo "⚠ Не удалось получить доступ к NFS-шаре"
    echo "Проверьте подключение к серверу $NFS_SERVER"
fi

echo "=== Настройка завершена ==="
