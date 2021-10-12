# Salt formula for setting up Ubuntu on the Framework Laptop

## Install Salt

```
wget -O /tmp/bootstrap-salt.sh https://bootstrap.saltproject.io && sudo sh /tmp/bootstrap-salt.sh
```


## Get the source

Clone this formula or download it and extract it somewhere.


## Run the complete Framework Laptop formula

From the root directory of the formula, where this README.md is, run:
```
salt-call --local --file-root="$(pwd)" state.apply framework-laptop
```


## Run an individual state

From the root directory of the formula, where this README.md is, run:
```
salt-call --local --file-root="$(pwd)" state.apply framework-laptop.[STATE NAME]
```

Example:
```
salt-call --local --file-root="$(pwd)" state.apply framework-laptop.hibernate
```


## Notes on hibernate/hybrid suspend

The `hibernate` state would setup hybrid suspend which means your computer will write your RAM's contents **every time you close the lid**. This obviously ensures no data is lost, but also wears out your SSD. It may or may not be what you want. Use your own judgement as to whether you use it as-is or modify the behaviour.
