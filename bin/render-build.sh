#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean
# Free plan: run migrations during build (preDeploy is not available).
bundle exec rails db:prepare
