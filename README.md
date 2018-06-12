# Hashpass Hashcracking Web Application 

## Requirements
```
- hashcat should be installed and accessable from yoru PATH
- Update .env with your gmail API key for SMS notifications
````

## Build Setup
```
bundle install
yarn
```

## run development
```
foreman start
# for back-end
# open http://localhost:9292
# for front-end
# open http://localhost:8080
```

## run production
```
yarn run build
APP_ENV=production bundle exec rackup -p 9292 --host 0.0.0.0
# open http://localhost:9292
```
