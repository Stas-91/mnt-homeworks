#!/usr/bin/python

# Copyright: (c) 2025, Stanislav Pomelnikov <mail.email@example.org>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)
from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_test

short_description: Creates a text file on the remote host

version_added: "1.0.0"

description: This module creates a text file on the remote host at the specified path with the specified content.

options:
    path:
        description: The path where the file should be created on the remote host.
        required: true
        type: str
    content:
        description: The content to write to the file.
        required: true
        type: str

author:
    - Stanislav Pomelnikov (@Stas-91)
'''

EXAMPLES = r'''
# Create a file with content
- name: Create a text file
  my_own_namespace.yandex_cloud_elk.my_test:
    path: /tmp/testfile.txt
    content: Hello, this is a test file!
'''

RETURN = r'''
path:
    description: The path of the created file.
    type: str
    returned: always
    sample: '/tmp/testfile.txt'
content:
    description: The content written to the file.
    type: str
    returned: always
    sample: 'Hello, this is a test file!'
'''

from ansible.module_utils.basic import AnsibleModule
import os

def run_module():
    # Define available arguments/parameters a user can pass to the module
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True)
    )

    # Seed the result dict in the object
    result = dict(
        changed=False,
        path='',
        content=''
    )

    # Instantiate the AnsibleModule object
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # Assign parameters to variables
    file_path = module.params['path']
    file_content = module.params['content']

    # Store parameters in result
    result['path'] = file_path
    result['content'] = file_content

    # If in check mode, return the current state without modifications
    if module.check_mode:
        module.exit_json(**result)

    try:
        # Check if file exists and has the same content
        if os.path.exists(file_path):
            with open(file_path, 'r') as f:
                existing_content = f.read()
            if existing_content == file_content:
                module.exit_json(**result)

        # Write the content to the file
        with open(file_path, 'w') as f:
            f.write(file_content)

        # Mark as changed since we created or modified the file
        result['changed'] = True

    except Exception as e:
        module.fail_json(msg=f"Failed to create file: {str(e)}", **result)

    # Exit with success
    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()