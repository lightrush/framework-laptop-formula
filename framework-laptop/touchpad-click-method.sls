{% set desktop_user = pillar["desktop_user"]["name"] %}
{% set gsettings_key_touchpad_path = "org.gnome.desktop.peripherals.touchpad" %}
{% set gsettings_key_touchpad_click_method_key = "click-method" %}

# This will set the touchpad behaviour to two/three-finger click
# doing right/middle mouse click. This setting can also be
# accessed via GUI in the GNOME Tweaks tool.
{% set gsettings_key_touchpad_click_method_value = "fingers" %}


touchpad-click-method-setting:
  cmd.run:
    - name: gsettings set {{ gsettings_key_touchpad_path }} {{ gsettings_key_touchpad_click_method_key }} '{{ gsettings_key_touchpad_click_method_value }}'
    - runas: {{ desktop_user }}
    - unless: \[ "$(gsettings get {{ gsettings_key_touchpad_path }} {{ gsettings_key_touchpad_click_method_key }})" == "'{{ gsettings_key_touchpad_click_method_value }}'" \]
