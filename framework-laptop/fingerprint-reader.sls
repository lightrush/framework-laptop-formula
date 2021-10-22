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

fingerprint-reader-service-enabled1:
  service.enabled:
    - name: fprintd
    - retry:
      - attempts: 3
      - interval: 5
    - onchanges:
      - pkg: fingerprint-reader-pkgs-installed

fingerprint-reader-pam-auth-enabled1:
  cmd.run:
    - name: pam-auth-update --enable fprintd
    - onchanges:
      - pkg: fingerprint-reader-pkgs-installed

fingerprint-reader-delete-device-prints-util-installed:
  file.managed:
    - name: /usr/local/bin/libfprint_delete_device_prints.py
    - source: salt://framework-laptop/files/fingerprint-reader/libfprint_delete_device_prints.py
    - mode: 755
    - require:
      - pkg: fingerprint-reader-pkgs-installed
  
fingerprint-reader-device-prints-delted:
  cmd.run:
    - name: /usr/local/bin/libfprint_delete_device_prints.py -d
    - require:
      - file: fingerprint-reader-delete-device-prints-util-installed
    - onchanges:
      - pkg: fingerprint-reader-pkgs-installed
