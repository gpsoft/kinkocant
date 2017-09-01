FROM ruby:2.4.1

ENV LANG C.UTF-8
RUN echo "Asia/Tokyo" >/etc/timezone
RUN ln -snf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime

RUN apt-get update -qq \
 && apt-get install -y \
      build-essential \
      libpq-dev \
      libxml2-dev \
      libxslt1-dev \
      libqt4-webkit \
      libqt4-dev \
      xvfb \
      nodejs \
      npm \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV APP_HOME /rapp
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

ENV GEM_HOME=/gems
ENV GEM_PATH=$GEM_HOME \
    BUNDLE_HOME=$GEM_HOME \
    BUNDLE_PATH=$GEM_HOME \
    BUNDLE_GEMFILE=$APP_HOME/Gemfile \
    PATH=$GEM_HOME/bin:$PATH
RUN gem install bundler

## (A)
## If you want to start new project,
## you would have Gemfile with only 'rails' in it
## and empty Gemfile.lock file.
ADD Gemfile* $APP_HOME/
## (B)
## Or...
## If you already have the app and Gemfile* for it,
## and want it to be in the image.
# ADD . $APP_HOME

RUN bundle install
