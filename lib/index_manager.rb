class IndexManager
  INDEX_DEFINITIONS_FILE = Rails.root.join("tmp", "index_definitions.sql")

  def self.disable_all
    connection = ActiveRecord::Base.connection

    # Use the more robust query to select only explicitly created indexes
    indexes = connection.execute("SELECT name, sql FROM sqlite_master WHERE type = 'index' AND sql IS NOT NULL;")

    # Store the CREATE INDEX statements
    File.open(INDEX_DEFINITIONS_FILE, "w") do |file|
      indexes.each do |index|
        file.puts index["sql"] + ";"
      end
    end

    # Drop all retrieved indexes
    indexes.each do |index|
      puts "Dropping index: #{index["name"]}"
      connection.execute("DROP INDEX \"#{index["name"]}\"")
    end
  end

  def self.enable_all
    unless File.exist?(INDEX_DEFINITIONS_FILE)
      puts "Index definitions file not found. Cannot enable indexes."
      return
    end

    connection = ActiveRecord::Base.connection
    sql = File.read(INDEX_DEFINITIONS_FILE)

    # Recreate all indexes from the stored SQL statements
    sql.split(";").each do |create_statement|
      next if create_statement.blank?

      puts "Creating index from: #{create_statement.strip}"
      connection.execute(create_statement)
    end

    # Clean up the temporary file
    File.delete(INDEX_DEFINITIONS_FILE)
  end
end
