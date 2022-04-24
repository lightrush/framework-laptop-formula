
{% set gstreamer_plugins_bad_versions = salt['pkg.list_repo_pkgs' ]("gstreamer1.0-plugins-bad")["gstreamer1.0-plugins-bad"] %}
{% set gstreamer_plugins_bad_version_good = "1.20" %}
{% set gstreamer_plugins_bad_version = gstreamer_plugins_bad_versions[0] %}
{% set should_install_plugins = (salt['pkg.version_cmp' ](gstreamer_plugins_bad_version, gstreamer_plugins_bad_version_good) > -1) %}

{% if should_install_plugins %}
pulseaudio-bt-hires-codecs-pkgs-installed:
  pkg.latest:
    - pkgs:
      - gstreamer1.0-plugins-bad
    - refresh: True
    - retry: True
{% endif %}
