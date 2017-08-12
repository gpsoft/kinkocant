# Kinkocant

## Intro

Kinkocant is a configuration that enables you to start a Rails project easily. You just need Docker to use it.

Kinkocant is a Japanese word, aka "ideal cant", meaning the way a train runs through a carve at just right speed against the cant(_bank_ or _tilt_) of rail so that passengers don't feel centrifugal force.

## Version

- Ruby 2.4.1
- Rails 4.2.9
- Postgresql 9.6.3


Currently the latest `pg` gem(version 0.21.0) doesn't likely work with `rails 4.2.*`; a workaround is to use `pg 0.20.0`.

## Usage

Assuming your new project name is `myapp` and you use `~/dev/myapp/` to work on...

    $ cd ~/dev
    $ git clone https://github.com/gpsoft/kinkocant.git
    $ cp -r kinkocant myapp
    $ cd myapp
    $ vi docker-compose.yml
        ... Replace "rappdb" with the database name for the project.
    $ docker-compose build
    $ docker-compose run --rm web \
      rails new . --force --database=postgresql --skip-bundle


Note that we use `--skip-bundle` because we want to edit `Gemfile`, which `rails new` will create for us, before `bundle install`.

    $ vi Gemfile
        ... Change the version for "pg" like so:
            gem 'pg', '0.20.0'
    $ docker-compose run --rm web bundle install
    $ vi config/database.yml
        ... Just replace the content with below:
        default: &default
          adapter: postgresql
          encoding: unicode
          pool: 5
          host: <%= ENV['DB_HOST'] %>
          username: <%= ENV['DB_USERNAME'] %>
          password: <%= ENV['DB_PASSWORD'] %>
        development:
          <<: *default
          database: <%= ENV['DB_NAME'] %>_development
        test:
          <<: *default
          database: <%= ENV['DB_NAME'] %>_test
        production:
          <<: *default
          database: <%= ENV['DB_NAME'] %>
          username: <%= ENV['RAPP_DATABASE_USERNAME'] %>
          password: <%= ENV['RAPP_DATABASE_PASSWORD'] %>

That's it. You can start developing with:

    $ docker-compose up -d

And connect your browser to `http://localhost:3000/` as usual.

When you need to run a `rake` command or a `rails` command:

    $ docker-compose exec web <YOUR COMMAND HERE>

For example:

    $ docker-compose exec web rake db:setup db:migrate

`rails` and `rake` command has been *binstub*-ed by Rails; so you don't need to prefix `gem exec` before the command;
