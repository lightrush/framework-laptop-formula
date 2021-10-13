# Salt (SaltStack) formula for setting up Ubuntu on the Framework Laptop

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


### Notes on hibernate/hybrid suspend

The `hibernate` state would setup hybrid suspend which means your computer will write your RAM's contents **every time you close the lid**. This obviously ensures no data is lost, but also wears out your SSD. It may or may not be what you want. Use your own judgement as to whether you use it as-is or modify the behaviour.
