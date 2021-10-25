{% from "framework-laptop/map.jinja" import framework with context %}

grub_decrease_menu_timeout_config:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_RECORDFAIL_TIMEOUT=.*$'
    - repl: 'GRUB_RECORDFAIL_TIMEOUT={{ framework.grub_recordfail_timeout.seconds }}'
    - append_if_not_found: True

grub_decrease_menu_timeout_grub_update:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: grub_decrease_menu_timeout_config
