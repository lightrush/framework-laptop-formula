mem_sleep_default_grub_config:
  file.append:
    - name: /etc/default/grub
    - text: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} mem_sleep_default=deep"'

mem_sleep_default_grub_update:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: mem_sleep_default_grub_config
