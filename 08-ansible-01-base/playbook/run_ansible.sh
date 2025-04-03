#!/bin/bash

# Указываем имена контейнеров и образы
CONTAINERS=(
  "centos7:my-centos7-ansible"
  "ubuntu:my-ubuntu-ansible"
  "fedora:pycontribs/fedora"
)

# Путь к inventory и плейбуку
INVENTORY="inventory/prod.yml"
PLAYBOOK="site.yml"
VAULT_PASS="netology"

# Функция для вывода сообщений
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Проверка наличия Docker
if ! command -v docker &> /dev/null; then
  log "Ошибка: Docker не установлен. Установите Docker и попробуйте снова."
  exit 1
fi

# Проверка наличия Ansible
if ! command -v ansible-playbook &> /dev/null; then
  log "Ошибка: Ansible не установлен. Установите Ansible и попробуйте снова."
  exit 1
fi

# Проверка существования образов
for container in "${CONTAINERS[@]}"; do
  IMAGE=$(echo "$container" | cut -d':' -f2)
  if ! docker image inspect "$IMAGE" &> /dev/null; then
    log "Ошибка: Образ $IMAGE не найден. Убедитесь, что он создан или доступен."
    exit 1
  fi
done

# Запуск контейнеров
log "Запуск контейнеров..."
for container in "${CONTAINERS[@]}"; do
  NAME=$(echo "$container" | cut -d':' -f1)
  IMAGE=$(echo "$container" | cut -d':' -f2)
  log "Запускаю контейнер $NAME из образа $IMAGE..."
  docker run -d --name "$NAME" --network host "$IMAGE" /bin/sh -c "while true; do sleep 3600; done"
  if [ $? -eq 0 ]; then
    log "Контейнер $NAME успешно запущен."
  else
    log "Ошибка при запуске контейнера $NAME."
    exit 1
  fi
done

# Запуск Ansible-плейбука с Vault-паролем
log "Запуск Ansible-плейбука..."
echo "$VAULT_PASS" | ansible-playbook -i "$INVENTORY" "$PLAYBOOK" --ask-vault-pass
ANSIBLE_EXIT_CODE=$?

if [ $ANSIBLE_EXIT_CODE -eq 0 ]; then
  log "Плейбук успешно выполнен."
else
  log "Ошибка при выполнении плейбука. Код завершения: $ANSIBLE_EXIT_CODE"
fi

# Остановка и удаление контейнеров
log "Остановка и удаление контейнеров..."
for container in "${CONTAINERS[@]}"; do
  NAME=$(echo "$container" | cut -d':' -f1)
  log "Останавливаю контейнер $NAME..."
  docker stop "$NAME" &> /dev/null
  log "Удаляю контейнер $NAME..."
  docker rm "$NAME" &> /dev/null
  if [ $? -eq 0 ]; then
    log "Контейнер $NAME успешно удалён."
  else
    log "Ошибка при удалении контейнера $NAME."
  fi
done

log "Скрипт завершён."
exit $ANSIBLE_EXIT_CODE
