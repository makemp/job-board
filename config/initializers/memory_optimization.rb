# Memory optimization settings for Ruby GC and Rails
if Rails.env.production?
  # Set Ruby GC environment variables for memory optimization
  # These should ideally be set as environment variables, but we can set them here as fallback
  ENV["RUBY_GC_HEAP_GROWTH_FACTOR"] ||= "1.1"
  ENV["RUBY_GC_HEAP_GROWTH_MAX_SLOTS"] ||= "10000"
  ENV["RUBY_GC_MALLOC_LIMIT"] ||= "16000000"
  ENV["RUBY_GC_MALLOC_LIMIT_MAX"] ||= "32000000"
  ENV["RUBY_GC_MALLOC_LIMIT_GROWTH_FACTOR"] ||= "1.4"
  ENV["RUBY_GC_OLDMALLOC_LIMIT"] ||= "16000000"
  ENV["RUBY_GC_OLDMALLOC_LIMIT_MAX"] ||= "128000000"

  # Force more frequent garbage collection in production for memory optimization
  at_exit { GC.start }
end

# Force garbage collection after each request in development (not production)
if Rails.env.development?
  class GCMiddleware
    def initialize(app)
      @app = app
    end

    def call(env)
      response = @app.call(env)
      GC.start if rand < 0.1 # 10% chance to run GC
      response
    end
  end

  Rails.application.middleware.use(GCMiddleware)
end
