
{% set swapfile = "/swapfile" %}
{% set swapfile_exists = salt['file.file_exists'](swapfile) %}
{% set mem_size = salt['cmd.shell']("echo $(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024 * 1024)))") %}

{% if swapfile_exists %}
{% set swap_size = salt['cmd.shell']("echo $((($(swapon -s | grep '/swapfile ' | tr -s '[:blank:]' ',' | cut -d ',' -f 3) / 1024 + 1) / 1024))") %}
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

{% set swap_size = mem_size | int + 1 %}

{% if swapfile_exists %}
{% set resume_offset = salt['cmd.shell']("filefrag -v " ~ swapfile ~ " | grep '^ *0:'  | tr -s '[:blank:]' ',' | cut -d',' -f5 | tr -d '.'") %}
{% set resume_uud = salt['cmd.shell']("findmnt -no UUID -T " ~ swapfile) %}
{% endif %}

hibernate_create_swap_file:
  cmd.run:
    - name: fallocate -l {{swap_size}}G {{swapfile}}
    - unless: '[[ -f {{swapfile}} ]]'

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
hibernate_grub_resume:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} resume=UUID=.* resume_offset=.*"$'
    - repl: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} resume=UUID={{resume_uud}} resume_offset={{resume_offset}}"'
    - append_if_not_found: True
    - require:
      - cmd: hibernate_swap_on

hibernate_update_grub:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: hibernate_grub_resume

hibernate_suspend_mode:
  file.replace:
    - name: /etc/systemd/sleep.conf
    - pattern: '^SuspendMode=.*'
    - repl: 'SuspendMode=suspend'
    - append_if_not_found: True
    - require:
      - file: hibernate_grub_resume
      - cmd: hibernate_update_grub

hibernate_suspend_state:
  file.replace:
    - name: /etc/systemd/sleep.conf
    - pattern: '^SuspendState=.*'
    - repl: SuspendState=disk
    - append_if_not_found: True
    - require:
      - file: hibernate_grub_resume
      - cmd: hibernate_update_grub

{% endif %}
