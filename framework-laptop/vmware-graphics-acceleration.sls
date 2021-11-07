{% if "desktop_user" in pillar %}

{% set desktop_user = pillar["desktop_user"]["name"] %}
{% set vmware_preferences = "/home/" ~ desktop_user ~ "/.vmware/preferences" %}


# Only apply if VMware preferences are found.
{% if salt['file.file_exists' ](vmware_preferences) %}

vmware-graphics-acceleration-preferences:
  file.append:
    - name: {{ vmware_preferences }}
    - text: 'mks.gl.allowBlacklistedDrivers = "TRUE"'

{% endif %}

{% endif %}