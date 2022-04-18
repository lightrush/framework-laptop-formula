# Automated post-install setup of Ubuntu 20.04 and 22.04 on the Framework Laptop

## CAUTION
This has been tested on Ubuntu 20.04.3, 20.04.4 and 22.04 Beta (Linux 5.11, Linux 5.13 and Linux 5.15), on Frameworks with i5, i7 and non-vPro AX210 by a good number of users. It may or may not work on anything that it wasn’t tested on. Work has been done to make it safe for other versions, but testing outside of 20.04 and 22.04 is out of scope. Use your own judgement.


## CHANGELOG
<details>
<summary>Click to see more...</summary>

- Add a workaround for a kernel quirk that should improve idle power consumtion by
about 2-3W after resuming from suspend, when using the `s2idle` sleep mode.
- Add support for Ubuntu 22.04.
- Update kernel before applying AX210.
- Disable PSR on Linux 5.13 in order to avoid screen tearing.
- Updated TL;DR command to handle Linux 5.13 and check for AX210.
- Remove fingerprint reader prebuilt packages if updated fprintd is found.
- Remove AX210 workaround after upgrade to Linux 5.13.
- Increase the number of retries fingerprint auth allows.
- Disable AX on AX210 when running kernel 5.11.
- Only apply AX210 workaround if it's found on the system.
- Document `defaults.yaml` usage.
- Enable graphics acceleration in VMware Workstation Player.
- Workarounds relevant to Ubuntu 20.04 are only applied on 20.04. Applying the formula on 21.04 or above would skip those. This has not been tested on non-20.04.
- `hibernate` was tested on Manjaro 21.1.6. It works and can be used.
...

</details>


## Upgrading from Ubuntu 20.04 to 22.04

1. Perform the upgrade.
2. Grab the latest version of this Salt formula and re-run it after upgading by following the instructions below.


## ATTENTION: In case of broken WiFi on Intel AX210
<details>
<summary>Click to see more...</summary>

If you've already applied this formula and your WiFi suddenly stopped working around mid-January 2022, without explanation, chances that your system got upgraded to Linux 5.13. The AX210 workaround used for Linux 5.11 breaks WiFi on 5.13. In order to get your WiFi working, execute the following:

```bash
sudo systemctl disable intel-ax210-workaround.service
sudo mv /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm.renamed-by-salt /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm
sudo rmmod iwlmvm
sudo rmmod iwlwifi
sudo modprobe iwlwifi
```

Following that, pull the latest formula and execute it again in order to remove the workaround completely. Executing the command from the TL;DR in a clean location should also do the trick.

If this is your first rodeo and your WiFi isn't working after fresh Ubuntu 20.04.3 install, get it running by doing this:
```bash
sudo mv -f /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm /lib/firmware/iwlwifi-ty-a0-gf-a0.pnvm.renamed-by-salt
sudo rmmod iwlmvm
sudo rmmod iwlwifi
sudo modprobe iwlwifi
```

</details>


## [TL;DR, but ideally read the rest if this is your first time](https://github.com/lightrush/framework-laptop-formula/blob/main/README.md#faq)

In order to setup Ubuntu 20.04 or 22.04 with working WiFi, fingerprint
reader etc., connect to the internet, then run the following:
```bash
wget -O /tmp/framework-laptop-tldr.sh https://raw.githubusercontent.com/lightrush/framework-laptop-formula/main/framework-laptop-tldr.sh && bash /tmp/framework-laptop-tldr.sh
```

If you also want [**hibernate**](https://github.com/lightrush/framework-laptop-formula/blob/main/README.md#hibernate), you can run the snippet below. By default it enables **suspend-then-hibernate** with 120 minutes delay. That can changed in [`defaults.yaml`](https://github.com/lightrush/framework-laptop-formula/blob/main/README.md#override-default-values-in-defaultsyaml).
```bash
sudo salt-call -l error --local --file-root="$(pwd)/framework-laptop-formula-main" state.apply framework-laptop.hibernate && sudo salt-call -l error --local --file-root="$(pwd)/framework-laptop-formula-main" state.apply framework-laptop.hibernate
```
**NB: You have to disable Secure Boot for hibernate to function.**

Now reboot your Framework.

Afterwards, you should have:

- 1 second GRUB menu timeout instead of 30 in case you use /boot on LVM
- Intel HD audio mic TRRS jack workaround
- Intel AX210 persistent workaround (doesn’t break on update of linux-firmware)
- Suspend to RAM
- TLP installed and enabled on Ubuntu 20.04.
- Touchpad suspend workarond
- Working fingerprint reader
- Hibernate, if you opted to use it
- No additional power draw after resume from suspend when usind `s2idle`

For more features like 2/3-finger clicking or changing defaults, [read the rest.](https://github.com/lightrush/framework-laptop-formula/blob/main/README.md#faq)
