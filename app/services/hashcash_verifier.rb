# frozen_string_literal: true

require "digest"
require "date"

#
# Verifies a client-side generated Hashcash stamp.
#
# This module is designed to validate stamps created by the accompanying
# JavaScript implementation, which uses SHA-256.
#
class HashcashVerifier
  class VerificationError < StandardError; end

  # Main verification class.
  #
  # Verifies a Hashcash stamp string.
  #
  # @param stamp_string [String] The full stamp, e.g., "1:20:250719:127.0.0.1::a1b2c3d4:12345"
  # @param resource [String] The required resource string that must match the stamp's resource.
  # @param min_bits [Integer] The minimum number of leading zero bits required.
  # @param validity_days [Integer] The number of days a stamp remains valid.
  # @param debug [Boolean] If true, prints debugging information to the console.
  #
  # @return [Boolean] Returns true if the stamp is valid, otherwise false.
  #
  def self.verify(stamp_string, resource:, min_bits: 16, validity_days: 1, debug: false)
    new(stamp_string, resource, min_bits, validity_days, debug).verify
  end

  def initialize(stamp_string, resource, min_bits, validity_days, debug)
    @stamp_string = stamp_string
    @expected_resource = resource
    @min_bits = min_bits
    @validity_days = validity_days
    @debug = debug
    @parsed_stamp = {}
  end

  # Instance method to perform the verification.
  def verify
    parse_stamp
    check_version
    check_resource
    check_date_validity
    check_difficulty
    check_proof_of_work
    true # If all checks pass
  end

  private

  def parse_stamp
    parts = @stamp_string.to_s.split(":", 7) # Use 7 to allow empty extension
    raise VerificationError, "Invalid stamp format (must have 7 parts)" unless parts.length == 7

    @parsed_stamp = {
      version: parts[0],
      bits: Integer(parts[1]),
      date: parts[2],
      resource: parts[3],
      extension: parts[4],
      rand: parts[5],
      counter: Integer(parts[6])
    }
  rescue ArgumentError
    raise VerificationError, "Invalid number format for bits or counter"
  end

  def check_version
    raise VerificationError, "Unsupported version: '#{@parsed_stamp[:version]}'" unless @parsed_stamp[:version] == "1"
  end

  def check_resource
    raise VerificationError, "Resource mismatch" unless @parsed_stamp[:resource] == @expected_resource
  end

  def check_date_validity
    stamp_date = Date.strptime(@parsed_stamp[:date], "%y%m%d")
    today = Date.today
    raise VerificationError, "Stamp has expired" if stamp_date < (today - @validity_days)
    raise VerificationError, "Stamp date is in the future" if stamp_date > today
  rescue Date::Error
    raise VerificationError, "Invalid date format: '#{@parsed_stamp[:date]}'"
  end

  def check_difficulty
    raise VerificationError, "Insufficient difficulty (required: #{@min_bits}, provided: #{@parsed_stamp[:bits]})" if @parsed_stamp[:bits] < @min_bits
  end

  def check_proof_of_work
    # Recreate the exact string that was hashed on the client.
    # The JS worker uses an empty string for null/undefined extension.
    recreated_stamp_string = [
      @parsed_stamp[:version],
      @parsed_stamp[:bits],
      @parsed_stamp[:date],
      @parsed_stamp[:resource],
      @parsed_stamp[:extension] || "",
      @parsed_stamp[:rand],
      @parsed_stamp[:counter]
    ].join(":")

    digest = Digest::SHA256.hexdigest(recreated_stamp_string)
    binary_hash = digest.hex.to_s(2).rjust(256, "0")

    if @debug
      puts "\n--- HASHCASH DEBUG ---"
      puts "String to hash: #{recreated_stamp_string}"
      puts "SHA256 Digest:  #{digest}"
      puts "Required bits:  #{@parsed_stamp[:bits]}"
      puts "Actual bits:    #{binary_hash.match(/^0*/)[0].length}"
      puts "----------------------\n"
    end

    # Check if the hash starts with the required number of zeros.
    required_prefix = "0" * @parsed_stamp[:bits]
    return if binary_hash.start_with?(required_prefix)

    raise VerificationError, "Proof-of-work is invalid"
  end
end

# --- Example Usage ---

# This is the example stamp you provided.
# "1:18:250719:127.0.0.1::ff1ee294d6de24bd3b7c94b486cc5e0e:138346"
# Let's assume this is a valid stamp for today (July 19, 2025).

# We need to create a real valid stamp to test against, as we can't know if the
# example one is truly valid without running the proof-of-work.
def create_test_stamp(resource, bits)
  date_str = Date.today.strftime("%y%m%d")
  rand_str = SecureRandom.hex(16)
  counter = 0
  loop do
    stamp_str = "1:#{bits}:#{date_str}:#{resource}::#{rand_str}:#{counter}"
    digest = Digest::SHA256.hexdigest(stamp_str)
    binary_hash = digest.hex.to_s(2).rjust(256, "0")
    return stamp_str if binary_hash.start_with?("0" * bits)
    counter += 1
    # Add a safety break for very high difficulties
    break if counter > 5_000_000
  end
end
