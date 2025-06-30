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



Libraries:
vips  for image processing
geoip-database ??