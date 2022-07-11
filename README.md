# Automated post-install setup of Ubuntu 20.04 and 22.04 on the Framework Laptop

## CAUTION
This has been tested on Ubuntu 20.04.3, 20.04.4 and 22.04 Beta (Linux 5.11, Linux 5.13 and Linux 5.15), on Frameworks with i5, i7 and non-vPro AX210 by a good number of users. It may or may not work on anything that it wasn’t tested on. Work has been done to make it safe for other versions, but testing outside of 20.04 and 22.04 is out of scope. Use your own judgement.


## CHANGELOG
<details>
<summary>Click to see more...</summary>

- Silence spurious errors on 22.04 due to Python packaging.
- Fix hibernate swap removal in certain cases.
- Simplify hibernate by adding it as an option to the tldr script.
- Install HiRes codecs (aptX, LDAC) for PulseAudio to use with Bluetooth devices.
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


## TL;DR

### Ideally, [read the rest](https://github.com/lightrush/framework-laptop-formula/blob/main/README.md#faq) if this is your first time

In order to setup Ubuntu 20.04 or 22.04 with most common config and workarounds needed for the Framework Laptop, connect to the internet, then run the following:
```bash
wget -O /tmp/framework-laptop-tldr.sh https://raw.githubusercontent.com/lightrush/framework-laptop-formula/main/framework-laptop-tldr.sh && bash /tmp/framework-laptop-tldr.sh
```

If you also want [**hibernate**](https://github.com/lightrush/framework-laptop-formula/blob/main/README.md#hibernate), run the following instead or after:
```bash
wget -O /tmp/framework-laptop-tldr.sh https://raw.githubusercontent.com/lightrush/framework-laptop-formula/main/framework-laptop-tldr.sh && bash /tmp/framework-laptop-tldr.sh --enable-hibernate
```

By default it enables **suspend-then-hibernate** with 120 minutes delay. That can be changed in [`defaults.yaml`](https://github.com/lightrush/framework-laptop-formula/blob/main/README.md#override-default-values-in-defaultsyaml). The hibernate function also creates a swapfile that's as large as your RAM size plus 1GB.

**NB: You have to disable Secure Boot for hibernate to function.**

Now reboot your Framework.

Afterwards, you should have:

- 1 second GRUB menu timeout instead of 30 in case you use /boot on LVM
- Intel HD audio mic TRRS jack workaround
- Intel AX210 persistent workaround (doesn’t break on update of linux-firmware) (only on Ubuntu 20.04.3)
- Suspend to RAM
- TLP installed and enabled (only on Ubuntu 20.04)
- Touchpad suspend workarond
- Working fingerprint reader
- Hibernate, if you opted to use it
- No additional power draw after resume from suspend when usind `s2idle`
- HiRes codecs (LDAC, aptX) for Bluetooth devices

For more features like 2/3-finger clicking or changing defaults, [read the rest.](https://github.com/lightrush/framework-laptop-formula/blob/main/README.md#faq)


## Updates

This Salt formula is designed to be idempotent. That is, it can be re-run over and over without causing unexpected problems. In fact that's the intended path for using newer versions. Simply download the latest one and re-run it. For examle when some workaround is no longer needed, running the latest version of the formula should remove it automatically. When some new was added that you want - re-download and re-run it.


## Spurious errors on Ubuntu 22.04

If you see errors similar to this:
```
[ERROR   ] Failed to import module pip, this is due most likely to a syntax error:
...
```
Fear not as they are benign. They're caused by a known Salt-related bug that doesn't affect the functionality of this code.


## FAQ

### What is this?

This is a piece of software in the form of a [Salt (SaltStack)](#what-is-saltstack) formula for performing post-install setup of Ubuntu 20.04 (for now) on the Framework Laptop. It configures the basic things that need configuring. Things like getting the Intel AX210 WiFi to work persistently, getting the fingerprint reader working, enabling better powersaving, etc. It eliminates the need to hunt down the documentation for each configuration or workaround and apply it manually.

### Why?
Because the number of Framework Laptops that will need Ubuntu 20.04 setup will be growing over time and I don't want to manually implement all the config and workarounds on each and every one. Maybe this could make someone else’s life easier as well.

### What is SaltStack?

Here's a brief bulrb for people unfamiliar with SaltStack explaining what it is.

SaltStack (Salt for short) is a configuration management system used across extremely large cloud deployments to personal machines and anywhere in-between. It defines a language and a set of built-in APIs that allow to describe configuration as code. At the very basic  level it does what one could do with Bash scripts with less typing and fewer errors. Its utility grows upwards from there. It allows for code reuse, better maintainability, modularity, config dependencies and a lot more that we don't need to go into for this short blurb.


### Why Salt?

In short, because it's easier and more maintainable than a bunch of Bash scripts. For example if we want to install the TLP package on Ubuntu, with Bash we'd have to write this somewhere in our scripts:

```bash
sudo apt install -y tlp
```

That's easy enough. But what if we want to also support Fedora? We'd now have to differentiate between distributions and use the correct package manager call:

```bash
LINUX_DISTRIBUTION=${get_linux_distribution} # Here we casually outsource the job of determining the distribution to another function.
case "$LINUX_DISTRIBUTION" in
        fedora)
            yum install --yes tlp
            ;;

        ubuntu)
            apt install -y tlp
            ;;

        *)
            echo Unsupported distribution
            exit 1
esac
```

We went from a one-liner to a paragraph. And that would only grow with any other distribution handling. And with any other function which has different invocation across multiple distributions.

If we were to do this with Salt, we would use its built-in API for package management and say:

```yaml
# The first line is an arbitrary ID for our own use.
tlp_package_installed:
  pkg.installed: # Name of built-in function used.
    - name: tlp  # An arg to the pkg.installed function passing the name of the package we want installed.
```

That's it. This will work on most popular distributions and derivatives without any further work on our end. Salt is by no means the only tool capable of doing this. Ansible and Puppet are the other two (more) popular options but I know Salt best. :D

And that's why we use Salt.


### What's a Salt formula?

In its most basic, a Salt formula is a self-contained module of Salt code that can achieve some well defined task, is usually configurable and reusable within other Salt code. That's Salt's terminology, not mine so that's that. This formula is intended to do the things needed to get Ubuntu working well on the Framework Laptop.


### Can I uninstall Salt after applying the formula?

Yes. The changes will persist.


### What was this tested on?

This was tested on the Framework with both the i5 and i7 CPUs, with non-vPro wifi modules.
The following table describes the available states, and which distributions they have been tested with.
If you're using it on something else, it may or may not work, use your own discretion. If you verify any of these states, please open a pull request updating the following table.

|                             | Ubuntu 20.04 | Manjaro 21.1.6                                                       |
|-----------------------------|:------------:|:--------------------------------------------------------------------:|
| fingerprint-reader          | yes          |                                                                      |
| framework-sec-trim-enable   | yes          |                                                                      |
| grub-decrease-menu-timeout  | yes          |                                                                      |
| hibernate                   | yes          | [yes](https://github.com/lightrush/framework-laptop-formula/pull/12) |
| intel-audio-workaround      | yes          |                                                                      |
| intel-ax210-workaround      | yes          |                                                                      |
| mem-sleep-default           | yes          |                                                                      |
| mouse-accel-profile         | yes          |                                                                      |
| tlp                         | yes          |                                                                      |
| touchpad-click-method       | yes          |                                                                      |
| touchpad-suspend-workaround | yes          |                                                                      |
| vmware-graphics-acceleration | yes          |                                                                      |

### How do I use this?

[Read on.](#usage)


## Usage

### Make sure your installation is up-to-date

Upgrade your Ubuntu packages via the `Software Updater` or by doing:

```bash
sudo apt-get -y update && sudo apt-get -y upgrade && sudo apt-get -y dist-upgrade
```


### Install Salt

```bash
if ! sudo apt-get -y install salt-common ; then wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltproject.io && sudo sh /tmp/bootstrap-salt.sh ; fi
```


### Get the source

Clone this formula or download it and extract it somewhere.


### Apply the complete Framework Laptop formula

From the root directory of the formula, where this README.md is, run:
```bash
sudo salt-call -l quiet --local --file-root="$(pwd)" state.apply framework-laptop
```

Reboot your computer after applying.


### Apply an individual state

From the root directory of the formula, where this README.md is, run:
```bash
sudo salt-call -l quiet --local --file-root="$(pwd)" state.apply framework-laptop.[STATE NAME]
```

Example:
```bash
sudo salt-call -l quiet --local --file-root="$(pwd)" state.apply framework-laptop.hibernate
```


### Override default values in `defaults.yaml`

Some states can be customized by changing the values of their parameters. The default values are defined in `defaults.yaml`. Each available parameter is documented in-line in that file. Editing `defaults.yaml` is the easiest way to change the behaviour of the formula. Thus `defaults.yaml` is the primary "user interface" for tuning the formula. The values set there can also be overriden at the command line or in pillar.


### Override default values on the command line

Some states are parametrized and have default values for those parameters specified
in `defaults.yaml`. Those values can be overriden in various ways. One is via the
command line, by specifying override values in pillar, like so:
```bash
sudo salt-call -l quiet --local --file-root="$(pwd)" state.apply framework-laptop.mem-sleep-default \
    pillar='{"framework-laptop":{"mem_sleep_default": "s2idle"}}'
```


### Apply user-specific states

Some states modify user-specific config like touchpad and mouse settings. For those we have to specify the user this config should be applied to. To apply those to the current user you can do:
```bash
sudo salt-call -l quiet --local --file-root="$(pwd)" state.apply framework-laptop.touchpad-click-method pillar="{ 'desktop_user': { 'name': '"${USER}"' }}"
```

To apply config for user `different_user`:
```bash
sudo salt-call -l quiet --local --file-root="$(pwd)" state.apply framework-laptop.touchpad-click-method pillar="{ 'desktop_user': { 'name': '"different_user"' }}"
```

If you try to apply a user-specific state without specifying a `desktop_user` as shown above, you'd get an error.


## Available states

### `fingerprint-reader`

The `fingerprint-reader` state installs the needed packages for the Frameworks's fingerprint reader from a collection of prebuilt deb files provided by the community. You can add your fingerprint using `Settings > Users > Fingerprint Login` after applying this state. Rebooting may be required after enabling fingerprint authentication.


### `framework-sec-trim-enable`

The `framework-sec-trim-enable` state adds the necessary `unmap` attribute to your Storage Expansion Card (SEC) via a udev rule. This allows the SEC SSD to be trimmed by the normal `fstrim.service` to help it maintain performance and endurance.


### `grub-decrease-menu-timeout`

The `grub-decrease-menu-timeout` state changes the timeout for the GRUB boot menu to 1 second. As the time of this writing, `/etc/grub.d/00_header` forces `GRUB_RECORDFAIL_TIMEOUT` when running on UEFI systems which the Framework Laptop generally is. The default value for this timeout is 30 seconds which is rather much, however disabling it altogether prevents us from being able to access GRUB as hotkeys do not work in UEFI mode [in certain cases](https://bugs.launchpad.net/ubuntu/+source/grub2/+bug/1800722). Hence the maintainers forcing `GRUB_RECORDFAIL_TIMEOUT` on UEFI. 1 second is short enough to allow access in emergency but does not impact the boot time too much.


### `hibernate`

The `hibernate` state would setup `/swapfile` with size as much as your RAM + 1GB. It would then add it to GRUB and update the GRUB config. Finaly, the state would configure systemd to do suspend-then-hibernate with 2 hours delay. This is a decent decent default and simmilar to the behaviour under Windows. Since the suspend period is limited to 2 hours, the officially supported suspend method - `s2idle` - can be used which suspends and resumes instantly but consumes ~3%/hr. If you wish to use hibernate, [apply it individually.](#apply-an-individual-state) Note that the `hibernate` state **has to be applied twice** if the `/swapfile` wasn't setup or it was too small and was recreated. The first application sets up `/swapfile`. The second adds the relevant kernel resume arguments. Applying it more than twice has no further effect past the first two applications.

NB: You may need to disable Secure Boot for hibernate to function.


### `intel-audio-workaround`

The `intel-audio-workaround` state applies a recommended workaround that enables mic through the Framework's TRRS jack. This was recommended [here.](https://community.frame.work/t/ubuntu-21-04-on-the-framework-laptop/2722?u=lightrush)


### `intel-ax210-workaround`

The `intel-ax210-workaround` state rolls the workaround needed for Intel AX210 on Ubuntu 20.04.3+ (Linux 5.11) into a service that re-applies the workaround on every boot. This is needed because an update to the `linux-firmware` package would remove manually applied workaround leaving you with dead WiFi after the following boot.


### `mem-sleep-default`

The `mem-sleep-default` state configures the default mem sleep type to `deep` which causes suspend to RAM instead the default, suspend to idle. That lowers the power consumption during suspend from ~3.5% to ~1.5%.


### `mouse-accel-profile`

The `mouse-accel-profile` state disables acceleration for mice in GNOME. This is a user-specific state and it is more of a personal preference than something needed by every Framework running Ubuntu 20.04. For that reason it's not included in the default formula. If you wish to use it, [apply it individually as described here.](#apply-user-specific-states)


### `tlp`

The `tlp` state installs the `tlp` package and enables the `tlp.service`. The TLP package and service apply power saving config on boot as well as adjust power settings when switching between AC and battery. It lowers the battery power consumption by a significant amount. To give you an idea, as I'm typing this, enabling TLP brings down the pwoer consumption from ~8.7W to ~6.3W. That's power saving of ~28%.


### `touchpad-click-method`

The `touchpad-click-method` state enables 2 and 3-finger clicks for the touchpad in GNOME. A 2-finger click does right mouse click and 3-finger click does middle mouse click. This is a user-specific state and it is more of a personal preference than something needed by every Framework running Ubuntu 20.04. For that reason it's not included in the default formula. If you wish to use it, [apply it individually as described here.](#apply-user-specific-states)


### `touchpad-suspend-workaround`

The `touchpad-suspend-workaround` state applies a workaround for the occasional touchpad (driver?) malfunction after suspend. It adds a hook to the systemd's sleep system which unloads the `i2c_hid` kernel module prior to suspend and loads it back on resume. Alternatively you could disable PS2 emulation from the BIOS, however that would would leave you without touchpad in operating systems that do not understand HID like Windows Setup.


### `vmware-graphics-acceleration`

The `vmware-graphics-acceleration` state enables 3D acceleration in VMware Workstation (Player) if its config file was found in the user's directory specified by `desktop_user`, [see](#apply-user-specific-states). The state is a no-op in case a config file wasn't found or `desktop_user` was not defined.


### `post-resume-power-draw-workaround`

The `post-resume-power-draw-workaround` state applies a workaround for increased power draw
after resuming from suspend, when using the `s2idle` sleep mode. This workaround should reduce
post-suspend idle power usage by about 2-3W.


### `pulseaudio-bt-hires-codecs`

The `pulseaudio-bt-hires-codecs` state installs HiRes codecs such as LDAC and aptX for PulseAudio to use with higher-end Bluetooth audio devices. Tested with FiiO BTR3K and verified it uses aptX once the state is applied.


## Credits

Framework DIY Linux community. Lots of things. https://community.frame.work/c/framework-laptop/linux/91

Henry Luengas. Python utility for deleting fingerprints from reader. https://github.com/hluengas/framework_scripts
