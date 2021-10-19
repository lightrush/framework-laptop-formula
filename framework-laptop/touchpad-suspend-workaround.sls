touchpad-suspend-workaround:
  file.managed:
    - name: /lib/systemd/system-sleep/touchpad-suspend-workaround
    - source: salt://framework-laptop/files/touchpad-suspend-workaround
    - mode: 755
    - user: root
    - group: root
