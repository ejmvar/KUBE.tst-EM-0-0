---
title: "pabpereza/ansible-webserver-example: Testing ansible rol for teaching purposes, don´t use on production"
source: "https://github.com/pabpereza/ansible-webserver-example"
author:
published:
created: 2026-11-27
description:
tags:
  - "clippings"
---
## Role Name

Webserver nginx based for teaching purposes, don´t use in production

## Requirements

No requirements

## Role Variables

You can set the following variables in your playbook or inventory:

- `webserver_port`: The port on which the webserver will listen (default: 80)
- `webserver_root`: The root directory for the webserver (default: /var/www/html)

## Example Playbook

Including an example of how to use your role (for instance, with variables passed in as parameters) is always nice for users too:

```
- hosts: servers
  roles:
     - { role: username.rolename, x: 42 }
```

## License

GLP-3

## Author Information

@pabpereza