
---

### 2. `roles/lighthouse/README.md`

```markdown
# Роль Ansible: lighthouse

Эта роль разворачивает и настраивает Lighthouse — веб-приложение, работающее с Nginx — на хостах с Ubuntu. Она включает установку зависимостей, клонирование репозитория, настройку Nginx и запуск сервиса.

## Назначение

Роль автоматизирует установку и настройку Lighthouse, включая:
- Установку Nginx и Git.
- Клонирование репозитория Lighthouse с GitHub.
- Настройку конфигурации Nginx.
- Активацию сайта и запуск сервиса.

## Задачи

- Устанавливает пакеты `nginx` и `git`.
- Клонирует репозиторий Lighthouse в `/var/www/lighthouse`.
- Разворачивает конфигурацию Nginx из шаблона `lighthouse-nginx.conf.j2`.
- Создаёт символическую ссылку для активации сайта в `/etc/nginx/sites-enabled/`.
- Запускает и включает сервис Nginx.

## Обработчики

- `Restart Nginx`: Перезапускает сервис Nginx при изменении конфигурации.

## Переменные

Переменные определены в `defaults/main.yml`:

| Переменная          | Описание                          | Значение по умолчанию                     |
|---------------------|-----------------------------------|-------------------------------------------|
| `lighthouse_repo`   | URL репозитория Lighthouse        | `https://github.com/VKCOM/lighthouse.git` |
| `lighthouse_branch` | Ветка репозитория                 | `master`                                  |

## Шаблоны

- `lighthouse-nginx.conf.j2`: Шаблон конфигурации Nginx, размещён в `templates/`.

## Зависимости

- **Система**: Ubuntu (протестировано на 20.04/22.04).
- **Интернет**: Требуется доступ к GitHub и репозиториям пакетов Ubuntu.
- **Права**: Роль выполняется с `become: true` (root-права).

## Использование

Роль применяется через плейбук. Пример плейбука:

```yaml
---
- name: Deploy Lighthouse Infrastructure
  hosts: lighthouse_node
  become: true
  roles:
    - lighthouse