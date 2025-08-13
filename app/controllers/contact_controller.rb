class ContactController < ApplicationController
  def index
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(contact_params.slice(:email, :message))

    # Validate anti-bot token before processing the form
    unless valid_anti_bot_token?
      @contact.errors.add(:base, "Security validation failed. Please try again.")
      render :index, status: :unprocessable_entity
      return
    end

    if @contact.valid?
      ContactMailer.contact_email(@contact).deliver_now
      redirect_to contact_path, notice: "Your message has been sent."
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:email, :message, :anti_bot_token, :anti_bot_seed, :anti_bot_timestamp)
  end

  def valid_anti_bot_token?
    return false unless contact_params[:anti_bot_token].present?
    return false unless contact_params[:anti_bot_seed].present?
    return false unless contact_params[:anti_bot_timestamp].present?

    # Extract the calculation parameters - must match JavaScript exactly
    multiplier = 7
    offset = 42
    seed = contact_params[:anti_bot_seed].to_i
    js_timestamp = contact_params[:anti_bot_timestamp].to_i

    submitted_token = contact_params[:anti_bot_token].to_i

    # Use the exact timestamp that JavaScript used for the calculation
    expected_token = ((js_timestamp % 10000) * multiplier) + seed + offset

    if submitted_token == expected_token
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
