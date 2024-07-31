{% from "framework-laptop/map.jinja" import framework with context %}

{% set swapfile = "/swapfile" %}
{% set swapfile_exists = salt['file.file_exists'](swapfile) %}
{% set mem_size = salt['cmd.shell']("echo $(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024 * 1024)))") | int %}

{% if swapfile_exists %}
{% set swap_size = salt['cmd.shell']("echo $((($(swapon -s | grep '/swapfile ' | tr -s '[:blank:]' ',' | cut -d ',' -f 3) / 1024 + 1) / 1024))") | int %}
{% if swap_size <= mem_size %}
hibernate_swap_off:
  cmd.run:
    - name: swapoff {{ swapfile }}

hibernate_kill_swap:
  file.absent:
    - name: {{ swapfile }}

{% set swapfile_exists = false %}
{% endif %}
{% endif %}

{% set swap_size = mem_size + 1 %}

{% if swapfile_exists %}
{% set resume_offset = salt['cmd.shell']("filefrag -v " ~ swapfile ~ " | grep '^ *0:'  | tr -s '[:blank:]' ',' | cut -d',' -f5 | tr -d '.'") %}
{% set resume_uud = salt['cmd.shell']("findmnt -no UUID -T " ~ swapfile) %}
{% endif %}

hibernate_create_swap_file:
  cmd.run:
    - name: fallocate -l {{swap_size}}G {{swapfile}}
    - unless: '[ -f {{swapfile}} ]'

hibernate_chmod_swap:
  file.managed:
    - name: {{swapfile}}
    - mode: 0600
    - require:
      - cmd: hibernate_create_swap_file

hibernate_make_swap:
  cmd.run:
    - name: mkswap {{swapfile}}
    - require:
      - file: hibernate_chmod_swap
    - onchanges:
      - cmd: hibernate_create_swap_file

hibernate_swap_on:
  cmd.run:
    - name: swapon {{swapfile}}
    - unless: "swapon -s | grep -q '{{swapfile}} '"
    - require:
      - cmd: hibernate_make_swap
      - file: hibernate_chmod_swap

hibernate_swap_fstab:
  file.append:
    - name: /etc/fstab
    - unless: grep -q '{{swapfile}} ' /etc/fstab
    - text: '{{swapfile}}  none  swap  sw  0  0'
    - require:
      - cmd: hibernate_create_swap_file
      - cmd: hibernate_swap_on

{% if swapfile_exists %}

# Cleanup old-style config.

hibernate_grub_resume_old_config_line:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} resume=UUID=.* resume_offset=.*"$'
    - repl: ''

hibernate_grub_resume_old_config:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^(.*)(resume=UUID=[-|\w]+)([\s|"].*)$'
    - repl: '\g<1>\g<3>'
    - require:
      - file: hibernate_grub_resume_old_config_line

hibernate_grub_resume_offset_old_config:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^(.*)(resume_offset=\w+)([\s|"].*)$'
    - repl: '\g<1>\g<3>'
    - require:
      - file: hibernate_grub_resume_old_config_line

# Now do the config

hibernate_grub_resume:
  file.managed:
    - name: /etc/default/grub.d/hibernate.cfg
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} resume=UUID={{resume_uud}} resume_offset={{resume_offset}}"'
    - require:
      - cmd: hibernate_swap_on

hibernate_update_grub:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: hibernate_grub_resume
      - file: hibernate_grub_resume_offset_old_config
      - file: hibernate_grub_resume_old_config
      - file: hibernate_grub_resume_old_config_line

{% if salt['grains.get' ]("osmajorrelease") | int >= 24 %}

hibernate_polkit_localauthority_installed:
  pkg.installed:
    - name: polkitd-pkla
    - refresh: True
    - retry: True

{% set majmin = (salt['cmd.shell']('lsblk -o "MAJ:MIN","MOUNTPOINTS" -J| python3 -c "import json,sys;majmin = [x for x in json.load(sys.stdin)[\'blockdevices\'] if \'/\' in x[\'mountpoints\']][0][\'maj:min\'].split(\':\');print(json.dumps(majmin))"') | load_json) %}

hibernate_tmpfiles_resume:
  file.managed:
    - name: /etc/tmpfiles.d/hibernation_resume.conf
    - source: salt://framework-laptop/files/hibernation_resume.conf
    - template: jinja
    - context:
      major: {{ majmin[0] }}
      minor: {{ majmin[1] }}

{% endif %}

hibernate_polkit_enabled:
  file.managed:
    - name: /etc/polkit-1/localauthority/50-local.d/com.ubuntu.enable-hibernate.pkla
    - source: salt://framework-laptop/files/com.ubuntu.enable-hibernate.pkla

{% if framework.hibernate.mode == 'hybrid_sleep' %}

{% set suspend_state = "disk" %}
{% set handle_suspend_key = "suspend" %}
{% set handle_lid_switch = "suspend" %}
{% set handle_lid_switch_external_power = "suspend" %}

{% elif framework.hibernate.mode == 'suspend_then_hibernate' %}

{% set suspend_state = "mem standby freeze" %}
{% set handle_suspend_key = "suspend-then-hibernate" %}
{% set handle_lid_switch = "suspend-then-hibernate" %}
{% set handle_lid_switch_external_power = "suspend-then-hibernate" %}

hibernate-hibernate-delay-sec:
  file.replace:
    - name: /etc/systemd/sleep.conf
    - pattern: '^HibernateDelaySec=.*'
    - repl: HibernateDelaySec={{ framework.hibernate.suspend_then_hibernate.hibernate_delay_sec }}
    - append_if_not_found: True
    - require:
      - file: hibernate_grub_resume
      - cmd: hibernate_update_grub

{% elif framework.hibernate.mode == 'hibernate' %}

# Reset everything to default in case we've touched it before.
{% set suspend_state = "mem standby freeze" %}
{% set handle_suspend_key = "suspend" %}
{% set handle_lid_switch = "suspend" %}
{% set handle_lid_switch_external_power = "suspend" %}

{% endif %}

hibernate-suspend-mode:
  file.replace:
    - name: /etc/systemd/sleep.conf
    - pattern: '^SuspendMode=.*'
    - repl: SuspendMode=suspend
    - append_if_not_found: True
    - require:
      - file: hibernate_grub_resume
      - cmd: hibernate_update_grub

hibernate-suspend-state:
  file.replace:
    - name: /etc/systemd/sleep.conf
    - pattern: '^SuspendState=.*'
    - repl: SuspendState={{ suspend_state }}
    - append_if_not_found: True
    - require:
      - file: hibernate_grub_resume
      - cmd: hibernate_update_grub

hibernate-handle-suspend-key:
  file.replace:
    - name: /etc/systemd/logind.conf
    - pattern: '^HandleSuspendKey=.*'
    - repl: HandleSuspendKey={{ handle_suspend_key }}
    - append_if_not_found: True
    - require:
      - file: hibernate_grub_resume
      - cmd: hibernate_update_grub

hibernate-handle-lid-switch:
  file.replace:
    - name: /etc/systemd/logind.conf
    - pattern: '^HandleLidSwitch=.*'
    - repl: HandleLidSwitch={{ handle_lid_switch }}
    - append_if_not_found: True
    - require:
      - file: hibernate_grub_resume
      - cmd: hibernate_update_grub

hibernate-handle-lid-switch-external-power:
  file.replace:
    - name: /etc/systemd/logind.conf
    - pattern: '^HandleLidSwitchExternalPower=.*'
    - repl: HandleLidSwitchExternalPower={{ handle_lid_switch_external_power }}
    - append_if_not_found: True
    - require:
      - file: hibernate_grub_resume
      - cmd: hibernate_update_grub

{% endif %}
