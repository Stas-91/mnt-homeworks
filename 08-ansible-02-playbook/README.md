# Ansible Playbook для установки ClickHouse и Vector

Этот плейбук автоматизирует установку и настройку ClickHouse и Vector на хостах в Docker-контейнере на deb системах.

## Описание
- **ClickHouse**: Устанавливает указанную версию ClickHouse, загружает пакеты `.deb`, настраивает службу и создает базу данных `logs`.
- **Vector**: Устанавливает Vector, настраивает конфигурацию из шаблона `vector.toml.j2` и запускает его как фоновый процесс.

## Требования
- Ansible (версия 2.9+)
- Python на managed nodes
- Доступ к хостам через Docker (настроен в `inventory/prod.yml`)
- Утилиты: `curl`, `apt-transport-https`, `ca-certificates`

## Структура
- `site.yml` — основной плейбук.
- `group_vars/vars.yml` — переменные для ClickHouse и Vector.
- `templates/vector.toml.j2` — шаблон конфигурации Vector.
- `inventory/prod.yml` — инвентарь хостов.

## Переменные
Переменные определены в `group_vars/vars.yml`:
- `ch_ver`: версия ClickHouse (например, `21.3.15.4.altinity+stable`).
- `ch_url`, `ch_path`, `ch_q`: параметры загрузки ClickHouse.
- `clickhouse_packages`: список пакетов ClickHouse.
- `vector_version`: версия Vector (например, `0.45.0-1`).
- `vector_url`: URL для загрузки Vector.

## Использование
1. Настройте инвентарь в `inventory/prod.yml`.
2. Убедитесь, что переменные в `group_vars/vars.yml` актуальны.
3. Запустите плейбук:
   ```bash
   ansible-playbook -i inventory/prod.yml site.yml