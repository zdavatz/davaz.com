# The [davaz.com](http://davaz.com/)

![davaz.com](https://raw.githubusercontent.com/zdavatz/davaz.com/master/doc/screenshot-davaz-com.png)

## Setup

### Requirements

* Ruby, `>= 2.3.1`
* PostgreSQL, `>= 9.0` (for [yus](https://github.com/zdavatz/yus))
* MySQL, `>= 5.6`
* ImageMagick
* Apache2
* [mod_ruby](https://github.com/shugo/mod_ruby) (It works with Ruby `1.8.6`)
* cronolog (optional)
* daemontools (for davazd, yusd)

### Install

```zsh
: Ruby and Rubygems
: check your ruby version
% ruby --version
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-linux]

% echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

% cd /path/to/davaz.com
% bundle install --path vendor

: JavaScript libraries
% cd doc/resources
% curl -sLO http://download.dojotoolkit.org/release-1.7.10/dojo-release-1.7.10.tar.gz
% tar zxvf dojo-release-1.7.10
% mv dojo-release-1.7.10 dojo
```

### Configureation

Use sample files in `etc` directory.

```zsh
: Database (edit for your credentials)
% cp etc/db_connection_data.yml.sample etc/db_connection_data.yml

: Apache2 conf
% cp etc/davaz.com.conf.sample /etc/apache2/vhosts.d/davaz.com.conf
```

### Database scheme

__TODO__

### Boot

Setup [daemontools](http://cr.yp.to/daemontools.html) then let supervise these
servers.

```zsh
: Boot application server (setup daemontools as supervisor)
% bundle exec ./bin/davazd

: Boot yus server (for user authencitation, setup this also before use)
: See https://github.com/zdavatz/yus/blob/master/Guide.txt
% bundle exec yusd config=/var/www/davaz.com/etc/yus.yml
```

How to boot developer console.

```zsh
: Boot admin console
% bundle exec ./bin/admin
davaz> load_artgroups.length
-> 11
davaz> exit
-> Goodbye
```

## Test

### Dependencies

* Ruby
* Node.js

* [minitest](https://github.com/seattlerb/minitest)
* [Selenium](http://docs.seleniumhq.org/) (via [watir](https://github.com/watir/watir))
* [PhantomJS](https://github.com/ariya/phantomjs)

### Setup

```zsh
% git clone https://github.com/zdavatz/davaz.com.git
% cd davaz.com

: e.g. use nodeenv
% pip install nodeenv
% nodeenv --node=0.12.15 env
% source env/bin/activate

(env) % npm install
(env) % bundle install
```

### How to run

bundle exec rake test TEST_OPTS="--name=TestLectures#test_lectures_toggle_hidden_dev_links" 2>&1 | tee rack_test-2.log

#### Test suite

```zsh
% bundle exec rake test
```

#### Single feature test

```zsh
: `DEBUG=true` is useful for debug (but it might be not interested)
bundle exec foreman run ruby -I.:test test/feature/lectures_test.rb
Run options: --seed 33427

`bundle exec rake test TEST_OPTS="--name=TestLectures#test_lectures_toggle_hidden_dev_links"`

# Running:

**

Fabulous run in 3.490279s, 0.5730 runs/s, 3.7246 assertions/s.

2 runs, 13 assertions, 0 failures, 0 errors, 0 skips
```

# TODO:

* Fix 4 skipped unit tests
** Stub of db_manager does not allow update of art_objects
** shop does not show some help messages when validations failures
** movies: thumbnail of movie picture is not show while running tests
* improve/add coverage for partial views

## License

Copyright (C) 2006-2016 ywesee GmbH.

This is free software;
You can redistribute it and/or modify it under the terms of the GNU General Public License (GPL v2.0).

See `LICENSE`.
