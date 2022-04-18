{% from "framework-laptop/map.jinja" import framework with context %}

# An NVME quirk in the kernel seems to be causing an extra ~2.5W of power
# draw at idle. More detail here - https://community.frame.work/t/linux-battery-life-tuning/6665/156.

post_resume_power_draw_workaround_grub_config_file:
  file.managed:
    - name: /etc/default/grub.d/post-resume-power-draw-workaround.cfg
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} nvme.noacpi=1"'

post_resume_power_draw_workaround_grub_update:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: post_resume_power_draw_workaround_grub_config_file
