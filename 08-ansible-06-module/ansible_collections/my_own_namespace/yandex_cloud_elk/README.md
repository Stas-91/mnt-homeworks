# Yandex Cloud ELK Collection

The `my_own_namespace.yandex_cloud_elk` collection provides a custom Ansible module and role for creating text files on remote hosts. It simplifies file creation tasks with configurable parameters.

## Overview

This collection includes:
- **Module**: `my_test` - Creates a text file at a specified path with specified content.
- **Role**: `create_text_file` - Uses the `my_test` module to create a text file with configurable defaults.

## Requirements

- Ansible 2.9 or later
- Python 3.6 or later on the target host

## Installation

1. **Local Usage**:
   - Place the collection in `ansible_collections/my_own_namespace/yandex_cloud_elk`.
   - Configure `ansible.cfg`:
     ```
     [defaults]
     collections_path = ./ansible_collections
     ```

2. **Install via `ansible-galaxy`**:
   - Build the collection:
     ```
     cd ansible_collections/my_own_namespace/yandex_cloud_elk
     ansible-galaxy collection build
     ```
   - Install the collection:
     ```
     ansible-galaxy collection install my_own_namespace-yandex_cloud_elk-1.0.0.tar.gz
     ```

## Collection Structure

```
ansible_collections/
└── my_own_namespace/
    └── yandex_cloud_elk/
        ├── docs/
        ├── galaxy.yml
        ├── meta/
        │   └── runtime.yml
        ├── plugins/
        │   └── modules/
        │       └── my_test.py
        ├── roles/
        │   └── create_text_file/
        │       ├── defaults/
        │       │   └── main.yml
        │       └── tasks/
        │           └── main.yml
        └── README.md
```

- `galaxy.yml`: Collection metadata.
- `meta/runtime.yml`: Specifies minimum Ansible version.
- `plugins/modules/my_test.py`: Custom module for creating text files.
- `roles/create_text_file/`: Role wrapping the `my_test` module.
- `docs/`: Placeholder for additional documentation.
- `README.md`: This documentation.

## Module: `my_test`

### Description
Creates a text file on a remote host at the specified path with the specified content. If the file exists with the same content, no changes are made.

### Parameters
| Parameter | Description | Type | Required | Default |
|-----------|-------------|------|----------|---------|
| `path`    | Path where the file should be created | `str` | Yes | None |
| `content` | Content to write to the file | `str` | Yes | None |

### Return Values
| Name | Description | Type | Returned | Sample |
|------|-------------|------|----------|--------|
| `path` | Path of the created file | `str` | Always | `/tmp/testfile.txt` |
| `content` | Content written to the file | `str` | Always | `Hello, this is a test file!` |

### Example
```yaml
- name: Create a text file
  my_own_namespace.yandex_cloud_elk.my_test:
    path: /tmp/testfile.txt
    content: Hello, this is a test file!
```

## Role: `create_text_file`

### Description
Uses the `my_test` module to create a text file on a remote host. Provides default values for `path` and `content`, which can be overridden.

### Default Variables
Defined in `roles/create_text_file/defaults/main.yml`:

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `my_test_path` | Path where the file will be created | `/tmp/default_testfile.txt` |
| `my_test_content` | Content to write to the file | `This is the default content from the role.` |

### Example
With custom parameters:
```yaml
- hosts: all
  roles:
    - role: my_own_namespace.yandex_cloud_elk.create_text_file
      my_test_path: /tmp/testfile.txt
      my_test_content: Hello, this is a test file from the role!
```

With default parameters:
```yaml
- hosts: all
  roles:
    - role: my_own_namespace.yandex_cloud_elk.create_text_file
```

## Usage Example

Playbook (`test_role.yml`):
```yaml
---
- hosts: all
  roles:
    - role: my_own_namespace.yandex_cloud_elk.create_text_file
      my_test_path: /tmp/testfile.txt
      my_test_content: Hello, this is a test file from the role!
```

Run the playbook:
```
ansible-playbook test_role.yml -i inventory.yml
```

This creates `/tmp/testfile.txt` with the content `Hello, this is a test file from the role!`.

## Inventory Setup

For local testing, use `inventory.yml`:
```yaml
all:
  hosts:
    localhost:
      ansible_connection: local
```

## Configuration

Ensure `ansible.cfg` includes:
```
[defaults]
collections_path = ./ansible_collections
```

## Troubleshooting

- **Error: `couldn't resolve module/action`**:
  - Verify `my_test.py` is in `ansible_collections/my_own_namespace/yandex_cloud_elk/plugins/modules/`.
  - Check `ansible.cfg` for correct `collections_path`.

- **Error: `role not found`**:
  - Ensure role is in `ansible_collections/my_own_namespace/yandex_cloud_elk/roles/create_text_file/`.
  - Use role name `create_text_file` in playbook.

- **Deprecation Warning for `collections_paths`**:
  - Use `collections_path` in `ansible.cfg`.

- **Debugging**:
  - Run with verbose output:
    ```
    ansible-playbook test_role.yml -i inventory.yml -v
    ```
  - Check module documentation:
    ```
    ansible-doc my_own_namespace.yandex_cloud_elk.my_test
    ```

## Contributing

Contributions are welcome! Submit pull requests or issues to the repository (if applicable).

## License

GNU General Public License v3.0 or later. See `COPYING` or [https://www.gnu.org/licenses/gpl-3.0.txt](https://www.gnu.org/licenses/gpl-3.0.txt).

## Author

- Stanislav Pomelnikov (@Stas-91)  