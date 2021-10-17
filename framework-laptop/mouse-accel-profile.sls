{% set desktop_user = pillar["desktop_user"]["name"] %}
{% set gsettings_key_mouse_path = "org.gnome.desktop.peripherals.mouse" %}
{% set gsettings_key_mouse_accel_key = "accel-profile" %}

# This will remove mouse acceleration.
{% set gsettings_key_mouse_accel_value = "flat" %}


mouse-accel-profile-setting:
  cmd.run:
    - name: gsettings set {{ gsettings_key_mouse_path }} {{ gsettings_key_mouse_accel_key }} '{{ gsettings_key_mouse_accel_value }}'
    - runas: {{ desktop_user }}
    - unless: \[ "$(gsettings get {{ gsettings_key_mouse_path }} {{ gsettings_key_mouse_accel_key }})" == "'{{ gsettings_key_mouse_accel_value }}'" \]
