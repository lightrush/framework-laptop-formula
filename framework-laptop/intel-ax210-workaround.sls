intel_ax210_workaround_service_installed:
  file.managed:
    - name: /etc/systemd/system/intel-ax210-workaround.service
    - source: salt://framework-laptop/files/intel-ax210-workaround.service

  module.run:
    - service.systemctl_reload: []
    - onchanges:
      - file: intel_ax210_workaround_service_installed

intel_ax210_workaround_service_running:
  service.running:
    - name: intel-ax210-workaround
    - enable: True
    - watch:
      - module: intel_ax210_workaround_service_installed
