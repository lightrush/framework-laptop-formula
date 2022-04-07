{% from "framework-laptop/map.jinja" import framework with context %}

# Clean up old config style.

mem_sleep_default_grub_config_removed:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} mem_sleep_default=.*"$'
    - repl: ''

mem_sleep_default_grub_config_removed_default:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^(GRUB_CMDLINE_LINUX_DEFAULT.*)(mem_sleep_default=\w+)([\s|"].*)$'
    - repl: '\g<1>\g<3>'
    - require:
      - file: mem_sleep_default_grub_config_removed

mem_sleep_default_grub_config_file:
  file.managed:
    - name: /etc/default/grub.d/mem-sleep-default.cfg
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} mem_sleep_default={{ framework.mem_sleep_default.value }}"'

mem_sleep_default_grub_update:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: mem_sleep_default_grub_config_file
      - file: mem_sleep_default_grub_config_removed
      - file: mem_sleep_default_grub_config_removed_default
