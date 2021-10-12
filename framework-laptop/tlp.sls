tlp_package_installed:
  pkg.installed:
    - name: tlp

tlp_service_running:
  service.running:
    - name: tlp
    - enable: True
    - watch:
      - pkg: tlp_package_installed
