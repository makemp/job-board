# README

## Stripe stuff
First you might to log in:
```
stripe login
```
then you need to run process to listen for events:
```
stripe listen --forward-to localhost:3000/stripe/webhook
```
the command above will also print out the webhook secret which needs to be stored here:
```
EDITOR="vim" bin/rails credentials:edit --environment development
```

For encryption:
bin/rails db:encryption:init
and store them:
EDITOR=vim bin/rails credentials:edit

Libraries:
vips  for image processing
geoip-database ??
clamav for anti-virus



SQLITE on prod: https://fly.io/docs/rails/advanced-guides/sqlite3/
