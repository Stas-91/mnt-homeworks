terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

# Указываем провайдер Yandex Cloud с переменными
provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = "ru-central1-a"
}

# Определяем переменные
variable "yc_token" {
  description = "OAuth token for Yandex Cloud"
  type        = string
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "Yandex Cloud ID"
  type        = string
}

variable "yc_folder_id" {
  description = "Yandex Cloud Folder ID"
  type        = string
}

# Создаем облачную сеть
resource "yandex_vpc_network" "network" {
  name = "my-network"
}

# Создаем подсеть
resource "yandex_vpc_subnet" "subnet" {
  name           = "my-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

# Определяем карту для ВМ
locals {
  vms = {
    "clickhouse" = { name = "clickhouse" },
    "vector" = { name = "vector" },
    "lighthouse" = { name = "lighthouse" }
  }
}

# Создаем ВМ с использованием for_each
resource "yandex_compute_instance" "vm" {
  for_each = local.vms

  name        = each.value.name
  platform_id = "standard-v3"
  zone        = "ru-central1-a"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8pfd17g205ujpmpb0a"
      size     = 20
    }
  }

  scheduling_policy {
    preemptible = true
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}

# Выводим публичные IP-адреса созданных ВМ
output "vm_ips" {
  value = { for k, v in yandex_compute_instance.vm : k => v.network_interface.0.nat_ip_address }
}

# Генерация инвентаря Ansible без лишних отступов
resource "local_file" "inventory" {
  content = <<DOC
---
clickhouse:
  hosts:
    clickhouse_node:
      ansible_host: ${yandex_compute_instance.vm["clickhouse"].network_interface.0.nat_ip_address}
lighthouse:
  hosts:
    lighthouse_node:
      ansible_host: ${yandex_compute_instance.vm["lighthouse"].network_interface.0.nat_ip_address}
vector:
  hosts:
    vector_node:
      ansible_host: ${yandex_compute_instance.vm["vector"].network_interface.0.nat_ip_address}
DOC
  filename = "inventory/prod.yml"
  depends_on = [yandex_compute_instance.vm]
}
