{% set xe_vendor_device = '8086:9a49' %}
{% if xe_vendor_device in salt['cmd.run' ]("lspci -n") %}

# Clean up old-style config.

intel_xe_tearing_workaround_grub_old_config_line:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^GRUB_CMDLINE_LINUX_DEFAULT="\${GRUB_CMDLINE_LINUX_DEFAULT} i915.enable_psr=.*"$'
    - repl: ''

intel_xe_tearing_workaround_grub_old_config:
  file.replace:
    - name: /etc/default/grub
    - pattern: '^(GRUB_CMDLINE_LINUX_DEFAULT.*)(i915\.enable_psr=\d)(.*)$'
    - repl: '\g<1>\g<3>'
    - require:
      - file: intel_xe_tearing_workaround_grub_old_config_line

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
  file.managed:
    - name: /etc/default/grub.d/intel-xe-tearing-workaround.cfg
    - contents: 'GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} i915.enable_psr=0"'

{% else %}

intel_xe_tearing_workaround_grub_config:
  file.absent:
    - name: /etc/default/grub.d/intel-xe-tearing-workaround.cfg

{% endif %}

intel_xe_tearing_workaround_grub_update:
  cmd.run:
    - name: update-grub
    - onchanges:
      - file: intel_xe_tearing_workaround_grub_config
      - file: intel_xe_tearing_workaround_grub_old_config_line
      - file: intel_xe_tearing_workaround_grub_old_config

{% endif %}
