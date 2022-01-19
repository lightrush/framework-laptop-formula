{% from "framework-laptop/map.jinja" import framework with context %}

{% set fprintd_prebuilt_vertion = "1:1.94.0-1" %}
{% set fprintd_versions = salt['pkg.list_repo_pkgs' ]("fprintd")["fprintd"] %}
{% set fprintd_version_good = "1.90.9-1~ubuntu20.04.1" %}

{% do fprintd_versions.remove(fprintd_prebuilt_vertion) if fprintd_prebuilt_vertion in fprintd_versions %}

{% set fprintd_version = fprintd_versions[0] %}
{% set fprintd_needs_prebuilt = (salt['pkg.version_cmp' ](fprintd_version, fprintd_version_good) == -1) %}

{% if fprintd_needs_prebuilt %}
fingerprint-reader-libfprint-old-purged:
  pkg.purged:
    - name: libfprint-2-tod1

fingerprint-reader-prereqs-installed:
  pkg.installed:
    - name: gir1.2-gusb-1.0
    - refresh: True
    - retry: True

fingerprint-reader-pkgs-installed:
  pkg.installed:
    - sources:
      - libfprint-2-2: salt://framework-laptop/files/fingerprint-reader/prebuilt/libfprint-2-2_1.94.1-1_amd64.deb
      - libfprint-2-doc: salt://framework-laptop/files/fingerprint-reader/prebuilt/libfprint-2-doc_1.94.1-1_all.deb
      - fprintd: salt://framework-laptop/files/fingerprint-reader/prebuilt/fprintd_1.94.0-1_amd64.deb
      - fprintd-doc: salt://framework-laptop/files/fingerprint-reader/prebuilt/fprintd-doc_1.94.0-1_all.deb
      - gir1.2-fprint-2.0: salt://framework-laptop/files/fingerprint-reader/prebuilt/gir1.2-fprint-2.0_1.94.1-1_amd64.deb
      - libpam-fprintd: salt://framework-laptop/files/fingerprint-reader/prebuilt/libpam-fprintd_1.94.0-1_amd64.deb
    - refresh: True
    - require:
      - pkg: fingerprint-reader-prereqs-installed

{% else %}
fingerprint-reader-pkgs-prebuilt-purged:
  pkg.purged:
    - pkgs:
      - libfprint-2-2: 1.94.1-1
      - libfprint-2-doc: 1.94.1-1
      - fprintd: 1.94.0-1
      - fprintd-doc: 1.94.0-1
      - gir1.2-fprint-2.0: 1.94.1-1
      - libpam-fprintd: 1.94.0-1

fingerprint-reader-pkgs-installed:
  pkg.latest:
    - pkgs:
      - libfprint-2-2
      - libfprint-2-doc
      - libfprint-2-tod1
      - fprintd
      - fprintd-doc
      - gir1.2-fprint-2.0
      - libpam-fprintd
    - refresh: True
    - retry: True
    - require:
      - pkg: fingerprint-reader-pkgs-prebuilt-purged

{% endif %}

fingerprint-reader-service-enabled:
  service.enabled:
    - name: fprintd
    - retry: True
    - require:
      - pkg: fingerprint-reader-pkgs-installed

fingerprint-reader-pam-auth-enabled:
  cmd.run:
    - name: pam-auth-update --enable fprintd
    - require:
      - pkg: fingerprint-reader-pkgs-installed
    - unless: grep '^auth.*pam_fprintd.so.*$' /etc/pam.d/common-auth

fingerprint-reader-delete-device-prints-util-installed:
  file.managed:
    - name: /usr/local/bin/libfprint_delete_device_prints.py
    - source: salt://framework-laptop/files/fingerprint-reader/libfprint_delete_device_prints.py
    - mode: 755
    - require:
      - pkg: fingerprint-reader-pkgs-installed

{% if framework.fingerprint_reader.delete_prints %}
fingerprint-reader-device-prints-deleted:
  cmd.run:
    - name: /usr/local/bin/libfprint_delete_device_prints.py -d
    - onchanges:
      - file: fingerprint-reader-delete-device-prints-util-installed
{% endif %}

fingerprint-reader-pam-config:
  file.replace:
    - name: /etc/pam.d/common-auth
    - pattern: '^(auth.*pam_fprintd.so.*max_tries=)(\d+)(\s+.*)$'
    - repl: '\g<1>{{ framework.fingerprint_reader.max_tries }}\g<3>'
    - require:
      - cmd: fingerprint-reader-pam-auth-enabled
