#!/bin/bash

# Скрипт для тестирования конкурирующих процессов I/O с разными настройками ionice
# Использование: ./io_competition.sh [размер_файла_MB] [кол-во_блоков]

set -e

# Параметры по умолчанию
FILE_SIZE_MB=${1:-500}
BLOCK_COUNT=${2:-1000}
BLOCK_SIZE=$((FILE_SIZE_MB * 1024 * 1024 / BLOCK_COUNT))

# Временные файлы для тестирования
FILE1="/tmp/test_file1.dat"
FILE2="/tmp/test_file2.dat"
LOG_FILE="io_competition.log"

# Функция очистки
cleanup() {
    echo "Очистка временных файлов..."
    rm -f "$FILE1" "$FILE2"
}

# Перехват сигналов для очистки
trap cleanup EXIT INT TERM

# Функция для запуска процесса I/O
run_io_process() {
    local process_num=$1
    local ionice_class=$2
    local ionice_level=$3
    local output_file=$4
    local log_prefix=$5
    
    echo "$(date): $log_prefix запуск с ionice -c $ionice_class -n $ionice_level" | tee -a "$LOG_FILE"
    
    if [ "$ionice_class" = "none" ]; then
        time (dd if=/dev/zero of="$output_file" bs=$BLOCK_SIZE count=$BLOCK_COUNT oflag=dsync status=progress 2>&1 | grep -E "bytes|copied|error" | tee -a "$LOG_FILE")
    else
        time (ionice -c $ionice_class -n $ionice_level dd if=/dev/zero of="$output_file" bs=$BLOCK_SIZE count=$BLOCK_COUNT oflag=dsync status=progress 2>&1 | grep -E "bytes|copied|error" | tee -a "$LOG_FILE")
    fi
    
    local exit_code=$?
    echo "$(date): $log_prefix завершен с кодом $exit_code" | tee -a "$LOG_FILE"
    return $exit_code
}

# Функция для измерения общего времени
measure_execution_time() {
    local start_time end_time duration
    
    start_time=$(date +%s)
    
    # Запуск процессов в фоне
    run_io_process 1 2 7 "$FILE1" "Процесс 1 (idle)" &
    local pid1=$!
    
    run_io_process 2 2 0 "$FILE2" "Процесс 2 (high)" &
    local pid2=$!
    
    # Ожидание завершения обоих процессов
    wait $pid1
    wait $pid2
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    echo "Общее время выполнения: $duration секунд" | tee -a "$LOG_FILE"
}

# Основная функция
main() {
    echo "=== Тест конкурирующих процессов I/O ===" | tee "$LOG_FILE"
    echo "Дата: $(date)" | tee -a "$LOG_FILE"
    echo "Параметры: размер файла ${FILE_SIZE_MB}MB, блоков: $BLOCK_COUNT" | tee -a "$LOG_FILE"
    echo "Лог файл: $LOG_FILE" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    # Очистка перед началом
    rm -f "$FILE1" "$FILE2" "$LOG_FILE"
    
    # Информация о системе
    echo "=== Информация о системе ===" | tee -a "$LOG_FILE"
    lsb_release -a 2>/dev/null | tee -a "$LOG_FILE" || echo "lsb_release не доступен" | tee -a "$LOG_FILE"
    echo "Ядро: $(uname -r)" | tee -a "$LOG_FILE"
    echo "IO Scheduler: $(cat /sys/block/*/queue/scheduler 2>/dev/null | head -1)" | tee -a "$LOG_FILE"
    echo "" | tee -a "$LOG_FILE"
    
    # Тест 1: Оба процесса с одинаковым ionice
    echo "=== ТЕСТ 1: Оба процесса с ionice idle (класс 2, уровень 7) ===" | tee -a "$LOG_FILE"
    measure_execution_time
    
    # Очистка файлов между тестами
    rm -f "$FILE1" "$FILE2"
    sleep 2
    
    # Тест 2: Процессы с разными классами
    echo "" | tee -a "$LOG_FILE"
    echo "=== ТЕСТ 2: Процесс 1 - idle (2/7), Процесс 2 - best-effort (2/0) ===" | tee -a "$LOG_FILE"
    measure_execution_time
    
    # Очистка файлов между тестами
    rm -f "$FILE1" "$FILE2"
    sleep 2
    
    # Тест 3: Один процесс без ionice, другой с высоким приоритетом
    echo "" | tee -a "$LOG_FILE"
    echo "=== ТЕСТ 3: Процесс 1 - без ionice, Процесс 2 - best-effort высокий (2/0) ===" | tee -a "$LOG_FILE"
    
    start_time=$(date +%s)
    
    run_io_process 1 "none" "0" "$FILE1" "Процесс 1 (без ionice)" &
    pid1=$!
    
    run_io_process 2 2 0 "$FILE2" "Процесс 2 (high)" &
    pid2=$!
    
    wait $pid1
    wait $pid2
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    echo "Общее время выполнения: $duration секунд" | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    echo "=== Все тесты завершены ===" | tee -a "$LOG_FILE"
    echo "Подробный лог в файле: $LOG_FILE" | tee -a "$LOG_FILE"
    
    # Вывод статистики
    echo "" | tee -a "$LOG_FILE"
    echo "=== Статистика ===" | tee -a "$LOG_FILE"
    grep "Общее время выполнения:" "$LOG_FILE" | tee -a "$LOG_FILE"
}

# Проверка прав и зависимостей
check_prerequisites() {
    if [ "$EUID" -ne 0 ]; then
        echo "ВНИМАНИЕ: Скрипт запущен без root прав. ionice может не работать корректно."
        echo "Рекомендуется запустить с sudo для полного доступа к ionice."
        echo ""
    fi
    
    if ! command -v ionice &> /dev/null; then
        echo "Ошибка: ionice не установлен. Установите пакет util-linux"
        exit 1
    fi
    
    if ! command -v dd &> /dev/null; then
        echo "Ошибка: dd не установлен"
        exit 1
    fi
}

#
