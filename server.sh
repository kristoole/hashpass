#!/bin/bash
yarn build
APP_ENV=production bundle exec rackup -p 9292 --host 0.0.0.0

