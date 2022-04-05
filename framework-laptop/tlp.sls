{% if salt['grains.get' ]("oscodename") == "focal" %}

# TLP is only needed on focal. On jammy and presumably above,
# we have power-profiles-daemon that does most of the work of
# TLP so for now we leave that in place and don't mess with it.

tlp_package_installed:
  pkg.installed:
    - name: tlp
    - refresh: True
    - retry: True

tlp_service_running:
  service.running:
    - name: tlp
    - enable: True
    - watch:
      - pkg: tlp_package_installed

{% else %}

# In case we ended up with TLP after an upgrade stop and purge.

tlp_service_dead:
  service.dead:
    - name: tlp
    - enable: False

tlp_package_purged:
  pkg.purged:
    - name: tlp
    - watch:
      - service: tlp_service_dead

{% endif %}
