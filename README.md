# Salt formula for setting up Ubuntu on the Framework Laptop

## Install Salt

```
wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltproject.io && sudo sh /tmp/bootstrap-salt.sh
```


## Run the Framework Laptop formula

From the root directory of the formula, where this README.md is, run:
```
salt-call --local --file-root="$(pwd)" state.apply framework-laptop
```
