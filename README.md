# Website of davaz.com

## Setup

TODO


## Test

### Requirements

* xvfb

### Dependencies (rubygems)

* minitest
* selenium (watir-webdriver)

### How to run

#### Test suite

TODO

#### Single feature test

```zsh
% DEBUG=true ruby -I.:test test/feature/test_shop.rb
```

### Tips

#### Install xvfb on Gentoo Linux

The testing on davaz.com uses `xvfb` as __headless__ environment (for selenium)

```zsh
% sudo su
...
# echo 'x11-base/xorg-server xvfb' >> /etc/portage/package.use/xorg-server
# exit

% sudo emerge -av xorg-server
```
