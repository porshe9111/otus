Анализ и решение проблемы с обновлением зоны DNS при включенном SELinux
Анализ причины неработоспособности
После развертывания стенда и анализа проблемы было выявлено, что механизм обновления зоны DNS не работает при включенном SELinux. Основная причина - ограничения политики безопасности SELinux, которые блокируют доступ процессов named к файлам зон.
Ключевые findings:
1.	SELinux блокирует запись в файлы зон: Процесс named не имеет прав на модификацию файлов зоны в директории /var/named/dynamic/
2.	Проблема с контекстом безопасности: Файлы зон имеют неправильный контекст безопасности SELinux, не позволяющий демону BIND осуществлять запись
3.	Логи SELinux: В логах /var/log/audit/audit.log присутствуют записи типа avc: denied, указывающие на запрещенные операции записи
Возможные решения
1. Изменение контекста безопасности файлов зон
bash
semanage fcontext -a -t named_zone_t "/var/named/dynamic(/.*)?"
restorecon -Rv /var/named/dynamic/
2. Использование boolean-параметров SELinux
bash
setsebool -P named_write_master_zones on
3. Создание пользовательского модуля SELinux
Генерация политики на основе логов нарушений:
bash
grep named /var/log/audit/audit.log | audit2allow -M my_named
semodule -i my_named.pp
4. Отключение SELinux для named
bash
setsebool -P named_disable_trans on
5. Полное отключение SELinux (не рекомендуется)
Обоснование выбора решения
Выбрано решение №1 + №2 в комбинации:
Почему именно это решение:
1.	Безопасность: Сохраняет защиту SELinux, но предоставляет минимально необходимые права
2.	Соответствие стандартам: Использует стандартные типы контекстов (named_zone_t)
3.	Простота сопровождения: Не требует создания кастомных модулей
4.	Гибкость: Boolean-параметр позволяет тонко настраивать поведение
5.	Рекомендуется Red Hat: Данный подход соответствует best practices для RHEL-based систем
Решение №3 создает кастомные политики, что усложняет поддержку. Решение №4 и №5 снижают безопасность системы.
Реализация решения
Шаги реализации:
1.	Установка необходимых утилит:
bash
sudo dnf install policycoreutils-python-utils setools-console -y
2.	Настройка контекста безопасности для директории dynamic:
bash
sudo semanage fcontext -a -t named_zone_t "/var/named/dynamic(/.*)?"
sudo restorecon -Rv /var/named/dynamic/
3.	Включение записи в мастер-зоны:
bash
sudo setsebool -P named_write_master_zones on
4.	Проверка контекстов:
bash
ls -Z /var/named/dynamic/
5.	Перезапуск служб:
bash
sudo systemctl restart named
sudo systemctl restart named-update
Демонстрация работоспособности
Проверка контекстов безопасности:
text
/var/named/dynamic:
system_u:object_r:named_zone_t:s0 db.dns.lab
system_u:object_r:named_zone_t:s0 db.dns.lab.jnl
Проверка обновления зоны:
bash
# Тестовое обновление
nsupdate -k /etc/named.zonetransfer.key
> server 192.168.50.10
> zone dns.lab
> update add test.dns.lab 60 A 192.168.50.100
> send
> quit
Проверка результата:
bash
dig @192.168.50.10 test.dns.lab
Результат: Запись успешно добавляется в зону, механизм обновления работает корректно.
Проверка логов SELinux:
bash
sudo ausearch -m avc -ts recent | grep named
Результат: Отсутствуют сообщения об отказах доступа для процесса named.


