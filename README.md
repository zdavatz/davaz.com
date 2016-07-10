# Website of davaz.com

## Setup

### Requirements

* Ruby, >= 2.3.1
* PostgreSQL, >= 9.0 (for [yus](https://github.com/zdavatz/yus))
* MySQL, >= 5.6
* ImageMagick
* Apache2
* [mod_ruby](https://github.com/shugo/mod_ruby) (It works with Ruby 1.8.6)
* cronolog (optional)

### Install

```zsh
: Ruby and Rubygems
: check your ruby version
% ruby --version
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-linux]

% echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

% cd /path/to/davaz.com
% bundle install --path .bundle/gems

: JavaScript libraries
: __TODO__
```

### Configureation

Use sample files in `etc` directory.

```zs
: Database (edit for your credentials)
% cp etc/db_connection_data.yml.sample etc/db_connection_data.yml

: Apache2 conf
% cp etc/davaz.com.conf.sample /etc/apache2/vhosts.d/davaz.com.conf
```

### Database scheme

__TODO__

### Booting

Setup [daemontools](http://cr.yp.to/daemontools.html)

```zsh
: Boot application server (setup daemontools as supervisor)
% bundle exec ./bin/davazd

: Boot yus server (for user authencitation, setup this also before use)
: See https://github.com/zdavatz/yus/blob/master/Guide.txt
% bundle exec yusd
```

```zsh
: Boot admin console (for developer)
% bundle exec ./bin/admin
davaz> load_artgroups.length
-> 11
davaz> exit
-> Goodbye
```

## Test

### Requirements

* xvfb

### Dependencies (via rubygems)

* minitest
* Selenium (watir-webdriver)

### How to run

#### Test suite

__TODO__

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
