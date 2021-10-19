# Salt (SaltStack) formula for setting up Ubuntu 20.04 (for now) on the Framework Laptop

## FAQ

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

In its most basic, a Salt formula is a self-contained module of Salt code that can achieve some well defined task, is usually configurable and reusable within other Salt code. That's Salt's terminology, not mine so that's that. This formula is intended to do the things needed to have Ubuntu to work well on the Framework Laptop.


### What was this tested on?

This has only been tested on an Framework with non-vPro AX210 with Ubuntu 20.04.3. This is what I have and I'm writing it to get that working. If you're using it on something else, it may or may not work, use your own discretion. 


## Usage

### Install Salt

```
wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltproject.io && sudo sh /tmp/bootstrap-salt.sh
```


### Get the source

Clone this formula or download it and extract it somewhere.


### Apply the complete Framework Laptop formula

From the root directory of the formula, where this README.md is, run:
```
salt-call --local --file-root="$(pwd)" state.apply framework-laptop
```


### Apply an individual state

From the root directory of the formula, where this README.md is, run:
```
salt-call --local --file-root="$(pwd)" state.apply framework-laptop.[STATE NAME]
```

Example:
```
salt-call --local --file-root="$(pwd)" state.apply framework-laptop.hibernate
```


### Apply user-specific states

Some states modify user-specific config like touchpad and mouse settings. For those we have to specify the user this config should be applied to. To apply those to the current user you can do:
```
sudo salt-call --local --file-root="$(pwd)" state.apply framework-laptop.touchpad-click-method pillar="{ 'desktop_user': { 'name': '"${USER}"' }}"
```

To apply config for user `different_user`:
```
sudo salt-call --local --file-root="$(pwd)" state.apply framework-laptop.touchpad-click-method pillar="{ 'desktop_user': { 'name': '"different_user"' }}"
```

If you try to apply a user-specific state without specifying a `desktop_user` as shown above, you'd get an error.


## Available states

### `framework-sec-trim-enable`

The `framework-sec-trim-enable` state adds the necessary `unmap` attribute to your Storage Expansion Card (SEC) via a udev rule. This allows the SEC SSD to be trimmed by the normal `fstrim.service` to help it maintain performance and endurance.


### `grub-decrease-menu-timeout`

The `grub-decrease-menu-timeout` state changes the timeout for the GRUB boot menu to 1 second. As the time of this writing, `/etc/grub.d/00_header` forces `GRUB_RECORDFAIL_TIMEOUT` when running on UEFI systems which the Framework Laptop generally is. The default value for this timeout is 30 seconds which is rather much, however disabling it altogether prevents us from being able to access GRUB as hotkeys do not work in UEFI mode for some reason. Hence the maintainers forcing `GRUB_RECORDFAIL_TIMEOUT` on UEFI. 1 second is short enough to allow access in emergency but does not impact the boot time too much.


### `hibernate`

The `hibernate` state would setup `/swapfile` with size as much as your RAM + 1GB. It would then add it to GRUB and update the GRUB config. Finaly, the state would configure systemd to do hybrid suspend. That is suspend to S3 **and** hibernate. This behaviour guarantees no loss of data if you forget your laptop suspended and its battery runs out. It will also wear your SSD every time you suspend, whereas normal suspend wouldn't. Personally I consider that a decent tradeoff. Currently this is not parametrized so you'd have to modify the state if you wish to change the type of suspend. This state may not be what most people want which is why it isn't applied by default. If you wish to use it, [apply it individually.](#apply-an-individual-state) Note that the `hibernate` state has to be applied twice if the `/swapfile` wasn't setup or it was too small and was recreated. The first application sets up `/swapfile`. The second adds the relevant kernel resume arguments.


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

The `touchpad-suspend-workaround` state applies a workaround for the occasional touchpad (driver?) malfunction after suspend. It adds a hook to the systemd's sleep system which unloads the `i2c_hid` kernel module prior to suspend and loads it back on resume. This is new and I haven't confirmed if it resolves the issue but so far I haven't encountered it after adding it.
