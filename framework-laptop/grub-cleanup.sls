# Cleanup duplicate GRUB_CMDLINE_LINUX_DEFAULT entries introduced during
# upgrade to from focal to jammy.

grub-cleanup:
  cmd.run:
    - name: sed -i "$(for line in $(grep -Pn '^GRUB_CMDLINE_LINUX_DEFAULT=.*$' /etc/default/grub | cut -d':' -f1 | tail -n +2); do echo -n ${line}d '; ' ; done)" /etc/default/grub
    - unless: "[ $(grep -Pn '^GRUB_CMDLINE_LINUX_DEFAULT=.*$' /etc/default/grub | cut -d':' -f1 | wc -l) = 1 ]"
