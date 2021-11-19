# Only apply when AX210 is found.
{% set ax210_vendor_device = '8086:2725' %}
{% if ax210_vendor_device in salt['cmd.run' ]("lspci -n") %}
# Only apply on Linux 5.11. Newer kernels seem to be working
# better or require different workarounds like firmware upgrades.
{% if salt['grains.get' ]("kernelrelease").startswith("5.11") %}

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

# Disable AX since that seems to be causing errors for some.
intel_ax210_workaround_modprobe_conf_installed:
  file.managed:
    - name: /etc/modprobe.d/intel-ax210-workaround.conf
    - source: salt://framework-laptop/files/intel-ax210-workaround.conf

intel_ax210_workaround_initramfs_updated:
  cmd.run:
    - name: update-initramfs -u
    - onchanges:
      - file: intel_ax210_workaround_modprobe_conf_installed

{% endif %}
{% endif %}
