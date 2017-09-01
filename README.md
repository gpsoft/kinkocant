# Kinkocant

See also [a blog post about kinkocant](http://gpsoft.dip.jp/gpblog/posts-output/2017-08-13-railsenv/) in Japanese.

## Intro

Kinkocant is a configuration that enables you to start a Rails project easily. You just need Docker to use it.

Kinkocant is a Japanese word, aka "ideal cant", meaning the way a train runs through a carve at just right speed against the cant(_bank_ or _tilt_) of rail so that passengers don't feel centrifugal force.

## Version

- Ruby 2.4.1
- Rails 4.2.9
- Postgresql 9.6.3


Currently the latest `pg` gem(version 0.21.0) doesn't likely work with `rails 4.2.*`; a workaround is to use `pg 0.20.0`. Also use `thor 0.19.4` instead of 0.20.0 or higher.

## Docker volumes

We use a couple of docker volumes.

    $ docker volume create pgdata
    $ docker volume create gems

The `pgdata` volume can be shared between projects as long as each database name is distinct. About the `gems` volume, I should think it over later.

## Usage

Assuming your new project name is `myapp` and you use `~/dev/myapp/` to work on...

    $ cd ~/dev
    $ git clone https://github.com/gpsoft/kinkocant.git
    $ cp -r kinkocant myapp
    $ cd myapp
    $ rm -rf .git .gitignore
    $ vi docker-compose.yml
        ... Replace "rappdb" with the database name for the project.
    $ docker-compose build
    $ docker-compose run --rm web \
      rails new . --force --database=postgresql --skip-bundle


Note that we use `--skip-bundle` because we want to edit `Gemfile`, which `rails new` will create for us, before `bundle install`.

    $ vi Gemfile
        ... Change the version for "pg" like so:
            gem 'pg', '0.20.0'
            gem 'thor', '0.19.4'
    $ docker-compose run --rm web bundle install
    $ sudo chown -R USERNAME:USERNAME    # for Linux user only
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
    /rapp/db/schema.rb doesn't exist yet. Run `rake db:migrate`
    to create it, then try again. If you do not intend to use
    a database, you should instead alter /rapp/config/application.rb
    to limit the frameworks that will be loaded.

`rails` and `rake` command has been *binstub*-ed by Rails; so you don't need to prefix `bundle exec` before the command;

You maybe want to edit `config/application.rb` first to change the main module name --Rapp; it has been named after the directory name `/rapp` in the container.
