#!/bin/sh
set -e

echo "=== Инициализация БД системы ПОТОК ==="

echo "[1/5] Ожидание готовности PostgreSQL..."
i=0
until pg_isready -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -q; do
  i=$((i+1))
  if [ "$i" -gt 30 ]; then
    echo "ОШИБКА: PostgreSQL не ответил за 60 секунд"
    exit 1
  fi
  sleep 2
done
echo "      PostgreSQL готов"

echo "[2/5] Применение схемы..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /init/schema.sql

echo "[3/5] Загрузка демонстрационных данных..."
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -v ON_ERROR_STOP=1 -f /init/seed.sql

echo "[4/5] Проверка наличия таблиц..."
for t in couriers orders order_items status_history app_state; do
  ok=$(psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -tAc "SELECT to_regclass('public.$t') IS NOT NULL;")
  if [ "$ok" != "t" ]; then
    echo "ОШИБКА: таблица $t не найдена"
    exit 1
  fi
  echo "      $t — OK"
done

echo "[5/5] Распределение заказов по статусам:"
psql -h "$DB_HOST" -U "$DB_USER" -d "$DB_NAME" -c "SELECT status, count(*) FROM orders GROUP BY status ORDER BY status;"

echo "=== Инициализация завершена успешно ==="
exit 0