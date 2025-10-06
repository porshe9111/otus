#!/bin/bash

# Блокировка от множественного запуска
LOCKFILE="/tmp/webserver_report.lock"
if [ -e "${LOCKFILE}" ] && kill -0 "$(cat "${LOCKFILE}")"; then
    echo "Script is already running. Exiting."
    exit 1
fi

trap 'rm -f "${LOCKFILE}"; exit $?' INT TERM EXIT
echo $$ > "${LOCKFILE}"

# Конфигурация
LOG_FILE="/var/log/nginx/access.log"
EMAIL_RECIPIENT="admin@example.com"
REPORT_FILE="/tmp/webserver_report_$(date +%Y%m%d_%H%M%S).txt"
LAST_RUN_FILE="/tmp/webserver_report_lastrun"

# Определяем временной диапазон
CURRENT_TIME=$(date +%s)
HOUR_AGO=$(date -d '1 hour ago' +%s)

# Если файл последнего запуска существует, используем его время
if [ -f "${LAST_RUN_FILE}" ]; then
    LAST_RUN_TIME=$(cat "${LAST_RUN_FILE}")
else
    LAST_RUN_TIME=${HOUR_AGO}
fi

# Формируем отчёт
{
    echo "Отчёт о работе веб-сервера"
    echo "Временной диапазон: $(date -d @${LAST_RUN_TIME} '+%Y-%m-%d %H:%M:%S') - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "==========================================="
    echo ""
    
    # Проверяем существование лог-файла
    if [ ! -f "${LOG_FILE}" ]; then
        echo "ОШИБКА: Лог-файл ${LOG_FILE} не найден!"
        exit 1
    fi
    
    # Фильтруем логи за указанный период
    TEMP_LOG="/tmp/temp_access_log"
    awk -v start=${LAST_RUN_TIME} -v end=${CURRENT_TIME} '
    {
        # Парсим дату из лога (формат может отличаться в зависимости от конфигурации)
        "date -d \""$4"\" +%s" | getline timestamp
        close("date -d \""$4"\" +%s")
        if (timestamp >= start && timestamp <= end) {
            print $0
        }
    }' "${LOG_FILE}" > "${TEMP_LOG}"
    
    # 1. Топ IP-адресов по количеству запросов
    echo "1. Топ-10 IP-адресов по количеству запросов:"
    echo "-------------------------------------------"
    awk '{print $1}' "${TEMP_LOG}" | sort | uniq -c | sort -nr | head -10
    echo ""
    
    # 2. Топ запрашиваемых URL
    echo "2. Топ-10 запрашиваемых URL:"
    echo "---------------------------"
    awk '{print $7}' "${TEMP_LOG}" | sort | uniq -c | sort -nr | head -10
    echo ""
    
    # 3. Ошибки веб-сервера (коды 4xx и 5xx)
    echo "3. Ошибки веб-сервера (коды 4xx и 5xx):"
    echo "--------------------------------------"
    awk '$9 ~ /^[45][0-9][0-9]$/ {print $9" - "$7" - "$1}' "${TEMP_LOG}" | \
    sort | uniq -c | sort -nr | head -10
    echo ""
    
    # 4. Статистика HTTP-кодов ответов
    echo "4. Статистика HTTP-кодов ответов:"
    echo "-------------------------------"
    awk '{print $9}' "${TEMP_LOG}" | sort | uniq -c | sort -nr
    echo ""
    
    # Общая статистика
    echo "5. Общая статистика:"
    echo "------------------"
    echo "Всего запросов: $(wc -l < "${TEMP_LOG}")"
    echo "Уникальных IP-адресов: $(awk '{print $1}' "${TEMP_LOG}" | sort -u | wc -l)"
    echo "Уникальных URL: $(awk '{print $7}' "${TEMP_LOG}" | sort -u | wc -l)"
    
} > "${REPORT_FILE}"

# Отправляем email
if [ -s "${REPORT_FILE}" ]; then
    mail -s "Отчёт о работе веб-сервера за $(date '+%Y-%m-%d %H:%M')" \
         "${EMAIL_RECIPIENT}" < "${REPORT_FILE}"
    
    if [ $? -eq 0 ]; then
        echo "Отчёт успешно отправлен на ${EMAIL_RECIPIENT}"
    else
        echo "Ошибка при отправке email"
    fi
fi

# Сохраняем время последнего запуска
echo "${CURRENT_TIME}" > "${LAST_RUN_FILE}"

# Очистка
rm -f "${TEMP_LOG}" "${REPORT_FILE}" "${LOCKFILE}"
trap - INT TERM EXIT
