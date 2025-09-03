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

Use RUBY_GC variables to play with garbage collector and stuff.

For encryption:
bin/rails db:encryption:init
and store them:
EDITOR=vim bin/rails credentials:edit

Libraries:
vips  for image processing
geoip-database ??
clamav for anti-virus



SQLITE on prod: https://fly.io/docs/rails/advanced-guides/sqlite3/

Gemini important thigs for this project:
https://gemini.google.com/app/084680b9db528fd8


SEO: compactkeywords.com


Shell, https://jobs.shell.com/
ExxonMobil, https://jobs.exxonmobil.com/
Chevron, https://careers.chevron.com/
TotalEnergies, https://careers.totalenergies.com/en
Schlumberger (SLB), https://careers.slb.com/
Halliburton, https://jobs.halliburton.com/
Baker Hughes, https://careers.bakerhughes.com/
BHP, https://www.bhp.com/careers/job-openings
Rio Tinto, https://www.riotinto.com/careers
Glencore, https://www.glencore.com/careers/career-opportunities