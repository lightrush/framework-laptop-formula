intel_audio_workaround_modprobe_conf_installed:
  file.managed:
    - name: /etc/modprobe.d/intel-audio-workaround.conf
    - source: salt://framework-laptop/files/intel-audio-workaround.conf
    # Speculatively assume that the new mainboards without Realtek audio CODEC
    # won't load `snd_hda_codec_realtek` and only apply workaround if it's loaded.
    - unless: "! lsmod | grep -q snd_hda_codec_realtek"

intel_audio_workaround_initramfs_updated:
  cmd.run:
    - name: update-initramfs -u
    - onchanges:
      - file: intel_audio_workaround_modprobe_conf_installed
