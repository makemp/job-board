namespace :memory do
  desc "Analyze memory usage patterns"
  task analyze: :environment do
    require "memory_profiler"
    require "get_process_mem"

    puts "Starting memory analysis..."

    # Test memory usage with different query patterns
    tests = [
      {
        name: "Job offers index query (ORIGINAL)",
        code: -> { JobOffer.valid.paid.sorted.includes(:employer, :order_placement).limit(20).to_a }
      },
      {
        name: "Job offers index query (OPTIMIZED)",
        code: -> { JobOffer.for_index.sorted.limit(20).to_a }
      },
      {
        name: "Single job offer with associations",
        code: -> { JobOffer.includes(:employer, :order_placement, :job_offer_actions).first }
      },
      {
        name: "Pagination query",
        code: -> { JobOffer.valid.paid.sorted.limit(20).offset(0).to_a }
      }
    ]

    tests.each do |test|
      puts "\n" + "=" * 50
      puts "Testing: #{test[:name]}"
      puts "=" * 50

      # Measure memory before
      GC.start
      memory_before = GetProcessMem.new.mb

      # Run the test with memory profiling
      report = MemoryProfiler.report do
        test[:code].call
      end

      # Measure memory after
      memory_after = GetProcessMem.new.mb

      puts "Memory before: #{memory_before} MB"
      puts "Memory after: #{memory_after} MB"
      puts "Memory increase: #{(memory_after - memory_before).round(2)} MB"
      puts "Total allocated: #{report.total_allocated_memsize} bytes"
      puts "Total retained: #{report.total_retained_memsize} bytes"
      puts "Objects allocated: #{report.total_allocated}"
      puts "Objects retained: #{report.total_retained}"

      # Force garbage collection
      GC.start
    end

    puts "\n" + "=" * 50
    puts "Memory analysis complete!"
    puts "=" * 50
  end

  desc "Show current memory statistics"
  task stats: :environment do
    puts "Current Memory Statistics"
    puts "=" * 30

    mem = GetProcessMem.new
    puts "Current process memory: #{mem.mb} MB"

    puts "\nGarbage Collection Stats:"
    GC.stat.each { |k, v| puts "  #{k}: #{v}" }

    puts "\nDatabase Connection Pools:"
    ActiveRecord::Base.connection_handler.connection_pool_list.each do |pool|
      puts "  #{pool.db_config.name}: #{pool.stat}"
    end
  end

  desc "Optimize memory by running garbage collection"
  task optimize: :environment do
    puts "Running memory optimization..."

    before = GetProcessMem.new.mb
    puts "Memory before optimization: #{before} MB"

    # Clear various caches
    Rails.cache.clear if Rails.cache.respond_to?(:clear)

    # Force garbage collection
    3.times { GC.start }

    after = GetProcessMem.new.mb
    puts "Memory after optimization: #{after} MB"
    puts "Memory freed: #{(before - after).round(2)} MB"
  end
end
