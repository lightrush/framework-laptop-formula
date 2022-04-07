{% from "framework-laptop/map.jinja" import framework with context %}


{% if framework.salt.masterless %}
{% if salt['pkg.version']("salt-minion") %}
salt-masterless-file-client-local:
  file.replace:
    - name: /etc/salt/minion
    - pattern: '^file_client.*$'
    - repl: 'file_client: local'
    - append_if_not_found: True
    - onlyif: ls /etc/salt/minion

salt-masterless-master-type-disable:
  file.replace:
    - name: /etc/salt/minion
    - pattern: '^master_type.*$'
    - repl: 'master_type: disable'
    - append_if_not_found: True
    - onlyif: ls /etc/salt/minion

salt-masterless-service-running:
  service.dead:
    - name: salt-minion
    - enable: False
{% endif %}
{% endif %}
