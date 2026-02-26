# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

davaz.com is a Ruby web application for an artist portfolio site with gallery, shop, guestbook, and content management. It uses a non-Rails stack: **Rack + SBSM (State-Based Session Management) + HtmlGrid (component-based views) + MySQL**.

### Runtime
- Ruby 3.4.5 (`.ruby-version`), Bundler 4.0.7
- Key Ruby 3.4 notes: `require 'ostruct'` is explicit (gem in Gemfile), `String#crypt` rejects newline in salt, `YAML.safe_load` uses keyword args only, `.untaint` removed
- Git LFS tracks `db/*.sql` (see `.gitattributes`)

## Commands

### Run the server
```
bundle exec rackup config.ru
```

### Run all tests
```
bundle exec rake test
```

### Run a single test file
```
bundle exec foreman run ruby -I.:test test/feature/lectures_test.rb
```

### Run a specific test method
```
bundle exec rake test TEST_OPTS="--name=TestLectures#test_lectures_toggle_hidden_dev_links"
```

### Admin console (interactive REPL)
```
bundle exec ./bin/admin
```

## Architecture

### Request Flow
```
HTTP → Rack (config.ru) → RackInterface (util/app.rb) → SBSM State Machine → HtmlGrid Views → HTML Response
```

### Source Layout (`src/`)

- **`state/`** — SBSM state classes define request handling and state transitions. `state/global.rb` is the root state. `state/predefine.rb` defines the state hierarchy. States are organized by section: `gallery/`, `personal/`, `works/`, `communication/`, `public/`, `admin/`. Partials in `state/_partial/` provide reusable mixins (login, AJAX, paging, etc.).

- **`view/`** — HtmlGrid component classes that render HTML. Mirror the state directory structure. `view/template.rb` is the base template. Partials in `view/_partial/` are reusable UI components.

- **`model/`** — Domain models: `ArtObject` (main entity), `ArtGroup`, `Serie`, `Tag`, `Tool`, `Material`, `Guest`, `Link`, `Oneliner`, `Country`.

- **`util/`** — Infrastructure code:
  - `app.rb` — Main App class and RackInterface (Rack entry point)
  - `db_manager.rb` — All database operations (~1200 lines, raw SQL via Mysql2)
  - `session.rb` — Session management
  - `config.rb` — Configuration via RCLConf
  - `image_helper.rb` — Image processing with RMagick
  - `lookandfeel.rb` — Theme/styling configuration
  - `validator.rb` — Form input validation
  - `trans_handler.davaz.rb` — URL translation/routing

### Key Patterns

- **State machine pattern**: Each page/action is a state class. Navigation happens via state transitions defined in `predefine.rb`. States inherit from `SBSM::State`.
- **Component-based views**: Views are Ruby classes inheriting from HtmlGrid components. UI is composed by mapping named slots to component classes.
- **No ORM**: `DbManager` uses raw SQL queries directly. All DB access goes through the singleton `DaVaz.config.db_manager` or `app.db_manager`.
- **Client-side JS**: Uses Dojo toolkit (1.7.x) in `doc/resources/` for AJAX interactions.

### Testing

Tests use **Minitest** with **Watir 7 / Selenium WebDriver 4** for headless browser feature tests (Chrome or Firefox). Feature tests are in `test/feature/`. Mocking uses **Flexmock**. Coverage tracked via **SimpleCov**.

- Watir 7 uses keyword args for element locators: `div(id: 'foo')` not `div(:id, 'foo')`
- Test server starts on port 11090 (see `test/config.ru` and `test/support/server.rb`)
- Test stubs: `test/support/stub/db_manager.rb` replaces real DB; `test/pw_server.passwords` has test credentials
- Dojo toolkit is auto-downloaded on first test run
- `Rack::Lint` is NOT used in test config — sbsm's `body.rewind` call is incompatible with Rack 3.x Lint wrapper
- Default Watir timeout is 15 seconds (`TEST_CLIENT_TIMEOUT` in `test/test_helper.rb`)

### Current test status
27 runs, 165 assertions, 0 failures, 0 errors, 5 skips. The 5 skips are known limitations:
- Stub db_manager does not support creating/updating art objects
- Shop validation error messages not displayed in test environment
- Movie thumbnail image not found during tests
- Postal code validation message not shown

## Configuration

- `etc/db_connection_data.yml` — MySQL credentials (copy from `.sample`)
- `etc/pw_server.passwords` — Authentication credentials
- `etc/pw_server.salt` — Password salt
