class HashcashVerifier
  class VerificationError < StandardError; end

  #
  # Verifies a Hashcash stamp string.
  #
  # @param stamp_string [String] The full stamp, e.g., "1:20:250719:127.0.0.1::a1b2c3d4:12345"
  # @param resource [String] The required resource string that must match the stamp's resource.
  # @param min_bits [Integer] The minimum number of leading zero bits required.
  # @param validity_days [Integer] The number of days a stamp remains valid.
  #
  # @return [Boolean] Returns true if the stamp is valid, otherwise false.
  #
  def self.verify(stamp_string, resource:, min_bits: 18, validity_days: 1)
    new(stamp_string, resource, min_bits, validity_days).verify
  rescue VerificationError
    # For debugging, you can uncomment the next line to see why verification failed.
    # warn "Hashcash verification failed: #{e.message}"
    false
  end

  def initialize(stamp_string, resource, min_bits, validity_days)
    @stamp_string = stamp_string
    @expected_resource = resource
    @min_bits = min_bits
    @validity_days = validity_days
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

    # The JS worker hashes the recreated string, not the original one if it had extra colons.
    # This ensures we are hashing the exact same content.
    digest = Digest::SHA256.hexdigest(recreated_stamp_string)

    # Convert hex digest to a binary string for easy zero-checking.
    # .rjust ensures we have the full 256 bits with leading zeros if necessary.
    binary_hash = digest.hex.to_s(2).rjust(256, "0")

    # Check if the hash starts with the required number of zeros.
    required_prefix = "0" * @parsed_stamp[:bits]
    return if binary_hash.start_with?(required_prefix)

    raise VerificationError, "Proof-of-work is invalid"
  end
end
