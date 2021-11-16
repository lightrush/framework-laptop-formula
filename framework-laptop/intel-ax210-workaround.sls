{% set ax210_vendor_device = '8086:2725' %}
{% if ax210_vendor_device in salt['cmd.run' ]("lspci -n") %}

intel_ax210_workaround_service_installed:
  file.managed:
    - name: /etc/systemd/system/intel-ax210-workaround.service
    - source: salt://framework-laptop/files/intel-ax210-workaround.service

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: intel_ax210_workaround_service_installed

intel_ax210_workaround_service_running:
  service.running:
    - name: intel-ax210-workaround
    - enable: True
    - watch:
      - module: intel_ax210_workaround_service_installed

intel_ax210_workaround_wait_for_network:
  cmd.run:
    - name: /bin/bash -c 'while ! nslookup google.com 8.8.8.8 &> /dev/null ; do echo No internet connection. Waiting... ; sleep 10 ; done'
    - unless: nslookup google.com 8.8.8.8
    - onchanges:
      - service: intel_ax210_workaround_service_running

{% endif %}