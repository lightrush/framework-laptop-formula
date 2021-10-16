framework-sec-trim-enable-udev-rule-installed:
  file.managed:
    - name: /etc/udev/rules.d/10-framework-sec-trim.rules
    - source: salt://framework-laptop/files/10-framework-sec-trim.rules
