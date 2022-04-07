{% from "framework-laptop/map.jinja" import framework with context %}

hpet-disable-grub-old-config-line:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} hpet=.*"$'
    - repl: ''

hpet-disable-grub-old-config-default:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^(.*)(hpet=\w+)([\s|"].*)$'
    - repl: '\g<1>\g<3>'
    - require:
      - file: hpet-disable-grub-old-config-line

{% if framework.hpet.disable %}
hpet-disable-grub-config:
  file.managed:
    - name: /etc/default/grub.d/hpet-disable.cfg
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} hpet=disable"'
{% else %}
hpet-disable-grub-config:
  file.absent:
    - name: /etc/default/grub.d/hpet-disable.cfg
{% endif %}

hpet-disable-grub-updated:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: hpet-disable-grub-config
      - file: hpet-disable-grub-old-config-default
      - file: hpet-disable-grub-old-config-line
