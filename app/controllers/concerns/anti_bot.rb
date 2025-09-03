module AntiBot
  FIELDS = [:anti_bot_token, :anti_bot_seed, :anti_bot_timestamp, :given_name, :family_name].freeze

  def valid_anti_bot_token?
    puts anti_bot_params
    puts "Debugging anti-bot token: #{anti_bot_params[:anti_bot_token]}"
    puts "Debugging anti-bot seed: #{anti_bot_params[:anti_bot_seed]}"
    puts "Debugging anti-bot timestamp: #{anti_bot_params[:anti_bot_timestamp]}"
    puts "Debugging honeypot - given_name: '#{anti_bot_params[:given_name]}', family_name: '#{anti_bot_params[:family_name]}'"

    # Check honeypot fields first - if filled, it's definitely a bot
    if anti_bot_params[:given_name].present? || anti_bot_params[:family_name].present?
      puts "❌ Bot detected! Honeypot fields were filled."
      return false
    end

    return false unless anti_bot_params[:anti_bot_token].present?
    return false unless anti_bot_params[:anti_bot_seed].present?
    return false unless anti_bot_params[:anti_bot_timestamp].present?

    # Extract the calculation parameters - must match JavaScript exactly
    multiplier = 11
    offset = 34
    seed = anti_bot_params[:anti_bot_seed].to_i
    js_timestamp = anti_bot_params[:anti_bot_timestamp].to_i

    submitted_token = anti_bot_params[:anti_bot_token].to_i
    puts "Submitted token: #{submitted_token}, Using seed: #{seed}"
    puts "JavaScript timestamp: #{js_timestamp}"

    # Use the exact timestamp that JavaScript used for the calculation
    expected_token = ((js_timestamp % 10000) * multiplier) + seed + offset

    if submitted_token == expected_token
      puts "✅ Token validated! Using exact JS timestamp: #{js_timestamp}, Seed: #{seed}, Expected: #{expected_token}"
      return true
    end

    # If exact match fails, try a small time window around the JS timestamp (±5 seconds)
    # This accounts for any potential network delays or processing time
    (-50..50).each do |deciseconds_offset|  # ±5 seconds in 100ms increments
      test_timestamp = js_timestamp + (deciseconds_offset * 100)
      expected_token_with_offset = ((test_timestamp % 10000) * multiplier) + seed + offset

      if submitted_token == expected_token_with_offset
        puts "✅ Token validated with offset! Timestamp: #{test_timestamp}, Seed: #{seed}"
        puts "Time difference: #{(test_timestamp - js_timestamp) / 1000.0} seconds"
        return true
      end
    end

    puts "❌ Token validation failed"
    puts "Expected token with JS timestamp: #{expected_token}"
    puts "Difference: #{submitted_token - expected_token}"
    false
  end
end
