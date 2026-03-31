# The [davaz.com](http://davaz.com/)

![davaz.com](https://raw.githubusercontent.com/zdavatz/davaz.com/master/doc/screenshot-davaz-com.png)

## Setup

### Requirements

* Ruby, `>= 3.4` (tested with 3.4.5)
* MySQL, `>= 5.6`
* `sudo apt-get install default-libmysqlclient-dev`
* ImageMagick
* [Git LFS](https://git-lfs.github.com/) (for database dumps in `db/`)
* Apache2 `a2enmod proxy_html`
* cronolog (optional)
* daemontools
* `sudo apt-get install daemontools-run`

### Install

```zsh
: Ruby and Rubygems
: check your ruby version
% ruby --version
ruby 3.4.5 (2025-07-16 revision 20cda200d3) [x86_64-linux]

% echo 'gem: --no-ri --no-rdoc' > ~/.gemrc

% cd /var/www/new.davaz.com
% bundle install

: JavaScript libraries
% cd doc/resources
% curl -sLO https://download.dojotoolkit.org/release-1.7.12/dojo-release-1.7.12.tar.gz
% tar zxvf dojo-release-1.7.12.tar.gz
% mv dojo-release-1.7.12 dojo
```

### Configuration

Use sample files in `etc` directory.

```zsh
: Database (edit for your credentials)
% cp etc/db_connection_data.yml.sample etc/db_connection_data.yml

: Apache2 conf
% cp etc/davaz.com.conf.sample /etc/apache2/vhosts.d/davaz.com.conf

: Password for login
% cd /var/www/new.davaz.com
% echo "Salting" > etc/pw_server.salt # But use a different word!!
# To generate a user with a password (uses crypt() with the salt)
% bundle exec bin/generate_passwd_entry user@example.com mypassword >> etc/pw_server.passwords

: YouTube API keys for movie/short view counts (optional, one key per line)
% cat > .yt-keys <<EOF
# YouTube Data API v3 keys
YOUR_API_KEY_1
YOUR_API_KEY_2
EOF
```

### YouTube 4K Migration

Update existing shorts/movies to Enhanced 4K URLs and create missing entries from YouTube:

```zsh
: Requires yt-dlp
% pip3 install yt-dlp

: Dry run (shows what would change)
% bundle exec ruby bin/update_4K_shorts_movies_yt.rb --scan

: Apply changes
% bundle exec ruby bin/update_4K_shorts_movies_yt.rb --scan --apply
```

Channels: `@jdavatz` (originals), `@gozipa` (Enhanced 4K). Videos <=60s are classified as Shorts, >60s as Movies.

### Database
* [Backup](https://github.com/zdavatz/davaz.com/tree/master/db)
* Dump DB: `mysqldump -u davaz -p -h localhost --databases davaz2 > davaz2_backup.sql`
* `# mysql -u root -h localhost -p`
* Create DB: `create database davaz2;`
* Grant DB rights: `grant all privileges on davaz2.* to davaz@localhost identified by 'password';`
* Flush: `flush privileges;`
* Restore DB: `mysql -u davaz -p -D davaz2 < migration_dump_2.12.2022.sql`

### Boot

[daemontools](http://cr.yp.to/daemontools.html) supervises the service.

* `cat /var/www/davaz.com/svc/run`
```zsh
#!/bin/sh
exec 2>&1
cd /var/www/davaz.com
exec setuidgid zdavatz /home/zdavatz/.rbenv/versions/3.4.5/bin/bundle exec rackup config.ru
```
* `cd /etc/service`
* `ln -s /var/www/davaz.com/svc/ davaz`

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

* Ruby `>= 3.4`
* Google Chrome or Firefox (for headless browser tests)
* [minitest](https://github.com/seattlerb/minitest)
* [Selenium WebDriver 4](https://www.selenium.dev/) (via [watir 7](https://github.com/watir/watir))

### Setup

```zsh
% git clone https://github.com/zdavatz/davaz.com.git
% cd davaz.com
% bundle install
```

Dojo toolkit is downloaded automatically on first test run.

### How to run

#### Test suite

```zsh
% bundle exec rake test
```

#### Single test method

```zsh
% bundle exec rake test TEST_OPTS="--name=TestLectures#test_lectures_toggle_hidden_dev_links"
```

### Current status

27 runs, 159 assertions, 0 failures, 0 errors, 5 skips (Ruby 3.4.5, headless Chrome).
Note: The admin movies WYSIWYG editor test has a known flaky cursor position issue in headless Chrome.

# TODO:

* Fix 5 skipped tests:
  * Stub of db_manager does not allow creation/update of art_objects
  * Shop does not show some help messages on validation failures
  * Movies: thumbnail of movie picture is not shown while running tests
  * Postal code validation message not shown
* Improve/add coverage for partial views

## License

Copyright (C) 2006-2016 ywesee GmbH.

This is free software;
You can redistribute it and/or modify it under the terms of the GNU General Public License (GPL v2.0).

See `LICENSE`.
