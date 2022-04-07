# Only apply when AX210 is found.
{% set ax210_vendor_device = '8086:2725' %}
{% if ax210_vendor_device in salt['cmd.run']("lspci -n") %}

{% do salt['pkg.refresh_db']() %}
{% set linux_generic = salt['pkg.latest_version']("linux-generic-hwe-20.04") or salt['pkg.version']("linux-generic-hwe-20.04") %}

# Update kernel to latest. This should give us Linux 5.13
{% if linux_generic %}
intel_ax210_workaround_linux_generic_latest:
  pkg.latest:
    - name: linux-generic-hwe-20.04
    - refresh: True
{% endif %}

{% set linux_version = linux_generic %}

# Only apply on Linux 5.11. Newer kernels seem to be working
# better or require different workarounds like firmware upgrades.
# We should have Linux 5.13 installed at this point but for now assume
# some systems might be somehow back in time.
{% if linux_version.startswith("5.11") %}

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

{% else %}

intel_ax210_workaround_service_dead:
  service.dead:
    - name: intel-ax210-workaround
    - enable: False

intel_ax210_workaround_service_removed:
  file.absent:
    - name: /etc/systemd/system/intel-ax210-workaround.service
    - require:
      - service: intel_ax210_workaround_service_dead

  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: intel_ax210_workaround_service_removed

intel_ax210_workaround_firmware_restored:
  cmd.run:
    - name: /bin/sh -c "mv -f /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm.renamed-by-salt /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm ; rmmod iwlmvm ; rmmod iwlwifi ; modprobe iwlwifi"
    - unless: '[ ! -f /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm.renamed-by-salt ]'
    - require:
      - service: intel_ax210_workaround_service_dead
      
intel_ax210_workaround_firmware_reinstalled:
  pkg.installed:
    - name: linux-firmware
    - reinstall: True
    - unless: '[ -f /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm ]'
    - require:
      - service: intel_ax210_workaround_service_dead

intel_ax210_workaround_modprobe_conf_removed:
  file.absent:
    - name: /etc/modprobe.d/intel-ax210-workaround.conf

intel_ax210_workaround_initramfs_updated:
  cmd.run:
    - name: update-initramfs -u
    - onchanges:
      - file: intel_ax210_workaround_modprobe_conf_removed

{% endif %}
{% endif %}
