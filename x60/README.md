# Coreboot on x60

This guide assumes you are flashing coreboot using the CH341A programmer, like [this
one](https://www.amazon.com/gp/product/B01J3O1KSY).

## Preparation

### Tools Needed

- [CH341A Programmer](https://www.amazon.com/gp/product/B01J3O1KSY).
- [Pomona 5250 8 Pin Soic Clip](https://www.amazon.com/gp/product/B00DDE7N3C)
- [Female to Female Jumper Wires](https://www.amazon.com/gp/product/B01IB7UOFE)
- [Screwdrivers](https://www.amazon.com/Wiha-26197-Precision-Phillips-Screwdriver/dp/B01L46TEN2/)

## Flashing Steps

1. Ensure CH341A provides 3.3v service
2. 

## Build Flashrom

```
$ make flashrom
```

## Resetting Hardware Clock

```

$ hwclock --directisa -w
```
