{%- set packages = {
  'libfprint-2-2': 'libfprint-2-2_1.94.1-1_amd64.deb',
  'libfprint-2-doc': 'libfprint-2-doc_1.94.1-1_all.deb',
  'fprintd': 'fprintd_1.94.0-1_amd64.deb',
  'fprintd-doc': 'fprintd-doc_1.94.0-1_all.deb',
  'gir1.2-fprint-2.0': 'gir1.2-fprint-2.0_1.94.1-1_amd64.deb',
  'libpam-fprintd': 'libpam-fprintd_1.94.0-1_amd64.deb',
} %}

{%- for package, deb in packages.items() %}
fingerprint-reader-deb-{{ package }}-copied:
  file.managed:
    - name: /tmp/{{ deb }}
    - source: salt://framework-laptop/files/fingerprint-reader/prebuilt/{{ deb }}
    - unless: dpkg -s {{ package }}

fingerprint-reader-package-{{ package }}-installed:
  cmd.run:
    - name: apt install /tmp/{{ deb }}
    - unless: dpkg -s {{ package }}

fingerprint-reader-deb-{{ package }}-absent:
  file.absent:
    - name: /tmp/{{ deb }}
    - require:
      - file: fingerprint-reader-deb-{{ package }}-copied
    - onchanges:
      - cmd: fingerprint-reader-package-{{ package }}-installed
{%- endfor %}

fingerprint-reader-service-enabled:
  service.enabled:
    - name: fprintd
    - watch:
      - cmd: fingerprint-reader-package-fprintd-installed

fingerprint-reader-pam-auth-enabled:
  cmd.run:
    - name: pam-auth-update --enable fprintd
    - onchanges:
      - cmd: fingerprint-reader-package-libpam-fprintd-installed
