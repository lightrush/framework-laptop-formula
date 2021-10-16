intel_audio_workaround_modprobe_conf_installed:
  file.managed:
    - name: /etc/modprobe.d/intel-audio-workaround.conf
    - source: salt://framework-laptop/files/intel-audio-workaround.conf

intel_audio_workaround_initramfs_updated:
  cmd.run:
    - name: update-initramfs -u
    - onchanges:
      - file: intel_audio_workaround_modprobe_conf_installed
