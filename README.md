# README
## What is this?
This is a production-grade rails application - a job board for drillin/mining-related jobs.
It is already deployed and you can visit it at https://drillcrew.work/

## Noticable features/tech stack used:
- Adding a job posting using Gemini integration. You give a url to the offer and html/content of the offer. It builds a nice job posting from that.
- Stripe payments integration
- Admin panel for managing job offers and users
- Nice front-end using Hotwire(Stimulus + Turbo) and TailwindCSS
- Hosted using fly.io
- Sqlite database for production use (https://fly.io/ruby-dispatch/sqlite-and-rails-in-production/)
- ActionCable for real-time updates and ActionJobs for background processing
- Integration with mailing provider