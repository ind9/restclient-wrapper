#!/bin/bash

bundle install

bundle exec rake

gem build api-client.gemspec

gem inabox -o --host http://gems.indix.tv:8153/ *gem
