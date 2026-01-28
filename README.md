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

Topics:
https://gemini.google.com/app/c6b7c1b566e92fc1

SEO: compactkeywords.com


Shell, https://jobs.shell.com/
ExxonMobil, https://jobs.exxonmobil.com/
Chevron, https://careers.chevron.com/
TotalEnergies, https://careers.totalenergies.com/en
Schlumberger (SLB), https://careers.slb.com/
Halliburton, https://jobs.halliburton.com/
Baker Hughes, https://careers.bakerhughes.com/
BHP, https://careers.bhp.com/search/?createNewAlert=false&q=&optionsFacetsDD_location=&optionsFacetsDD_customfield1=&optionsFacetsDD_title=&optionsFacetsDD_customfield4=
Rio Tinto, https://www.riotinto.com/careers
Glencore, https://www.glencore.com/careers/career-opportunities



Hey everyone,
After reviewing the current job boards for mining and drilling professionals, I felt there was a real need for something better.
To try and help, I've started manually gathering job openings from the major players and putting them all in one simple, clean place. All links go directly to the official application pages—no third-party tracking or ads.
We do not use web scrapping, just manual process but indeed the summary of job offer is done by AI.
Here some job offers:

| Company | Position | Location | Type | Apply |
|---------|----------|----------|------|-------|
| Chevron | Production Specialist Excavation | USA - Carlsbad | Drilling | [Apply](https://careers.chevron.com/job/carlsbad/production-specialist-excavation/38138/86062953760) |
| TotalEnergies | Junior Fluids Processing Engineer | France - Pau | Drilling | [Apply](https://jobs.totalenergies.com/en_US/careers/JobDetail/Ing-nieur-Traitement-des-Fluides-D-butant-H-F/70679) |
| Halliburton | Suriname Talent Network - Future Opportunities | Suriname | Drilling | [Apply](https://jobs.halliburton.com/job/George-Kondre-Halliburton-Suriname-Job-Opportunities-PM/1293407900/) |
| Halliburton | Senior Scientist - Chemist | India - Pune | Drilling | [Apply](https://jobs.halliburton.com/job/Pune-Senior-Scientist-Chemist-MH-411001/1305838900/) |
| Halliburton | Project Coordinator | Suriname - Paramaribo | Drilling | [Apply](https://jobs.halliburton.com/job/Toeboeka-Project-Coordinator-PM/1285016200/) |
| Halliburton | Electronics Technician, Princ | Guyana - Georgetown | Drilling | [Apply](https://jobs.halliburton.com/job/De-Kinderen-Electronics-Technician%2C-Princ-DE/1293431300/) |
| Baker Hughes | Field Operator (Cementing) | Azerbaijan - Baku, Balakən | Drilling | [Apply](https://careers.bakerhughes.com/global/en/job/R153203/Field-Operator-Cementing) |
| Baker Hughes | Lead Technical Support Engineer - Cementing | Egypt - Cairo | Drilling | [Apply](https://careers.bakerhughes.com/global/en/job/R153218/Lead-Technical-Support-Engineer-Cementing) |
| Baker Hughes | Lead Application Engineer - Drilling Services | UAE - Abu Dhabi | Drilling | [Apply](https://careers.bakerhughes.com/global/en/job/R154370/Lead-Application-Engineer-Drilling-Services) |
| BHP | HR Manager NSW Energy Coal | Australia - Newcastle, Muswellbrook, New South Wales | Mining | [Apply](https://careers.bhp.com/job/HR-Manager-NSW-Energy-Coal-Australia/1325184000/) |
| BHP | Lead Engineering - Mine Surface Production | Australia - Roxby Downs | Mining | [Apply](https://careers.bhp.com/job/Lead-Engineering-Mine-Surface-Production-Olympic-Dam-43-Roster/1325185200/) |
| BHP | Mantenedor(a) Mecánico | Minera Escondida | Chile - Minera Escondida, Antofagasta | Mining | [Apply](https://careers.bhp.com/job/Mantenedor%28a%29-Mec%C3%A1nico-Minera-Escondida/1325731300/) |
| BHP | Specialist Tenure | Australia - Perth | Mining | [Apply](https://careers.bhp.com/job/Specialist-Tenure-Perth-Mon-Fri-Expression-of-Interest/1325588700/) |
| BHP | Maintenance Planner | Canada - Saskatoon | Mining | [Apply](https://careers.bhp.com/job/Maintenance-Planner/1325716400/) |
| BHP | Manager Resource Characterisation | Australia - Perth | Mining | [Apply](https://careers.bhp.com/job/Manager-Resource-Characterisation-WAIO-Geoscience-Perth-Mon-Fri/1325573100/) |
To make it truly great, I need your feedback. Please, let me know your thoughts!
The next step is to have companies post their openings directly, so any help or connections in that area would be more than welcome!