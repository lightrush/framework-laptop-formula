{% set xe_vendor_device = '8086:9a49' %}
{% if xe_vendor_device in salt['cmd.run' ]("lspci -n") %}

{% do salt['pkg.refresh_db']() %}
{% set linux_generic = salt['pkg.latest_version']("linux-generic-hwe-20.04") or salt['pkg.version']("linux-generic-hwe-20.04") %}

# Update kernel to latest. This should give us Linux 5.13
{% if linux_generic %}
intel_xe_tearing_workaround_linux_generic_latest:
  pkg.latest:
    - name: linux-generic-hwe-20.04
    - refresh: True
{% endif %}

# Only apply on Linux 5.13 for now.
{% if linux_generic.startswith("5.13") %}

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
