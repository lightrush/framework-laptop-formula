# Only apply when AX210 is found.
{% set xe_vendor_device = '8086:9a49' %}
{% if xe_vendor_device in salt['cmd.run' ]("lspci -n") %}

# Only apply on Linux 5.13 for now.
{% if salt['grains.get' ]("kernelrelease").startswith("5.13") %}

intel_xe_tearing_workaround_grub_config:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} i915.enable_psr=.*"$'
    - repl: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} i915.enable_psr=0"'
    - append_if_not_found: True

{% else %}

intel_xe_tearing_workaround_grub_config:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} i915.enable_psr=.*"$'
    - repl: ''

{% endif %}

intel_xe_tearing_workaround_grub_update:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: intel_xe_tearing_workaround_grub_config

{% endif %}
