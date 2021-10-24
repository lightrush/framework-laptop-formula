{% from "framework-laptop/map.jinja" import framework with context %}

hpet-disable-grub-config:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} hpet=.*"$\n'
{% if framework.hpet.disable %}
    - repl: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} hpet=disable"'
{% else %}
    - repl: ''
{% endif %}
    - append_if_not_found: True

hpet-disable-grub-updated:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: hpet-disable-grub-config
