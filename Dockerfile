FROM ruby:3.2.2

# Install dependancies
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client

# Set working directory
WORKDIR /rails

# Install Gems
COPY Gemfile* ./
RUN bundle install

# Add app code
COPY . .

# entrypoint
COPY entrypoint.sh /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

# default cmd
CMD ["rails", "s", "-b", "0.0.0.0"]
