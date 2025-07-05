class AddIndicesForJobOfferExpirationQuery < ActiveRecord::Migration[8.0]
  def change
    # Composite index on job_offer_actions for the main filtering and joining
    # Order: job_offer_id first (for JOIN), then type (for WHERE), then valid_till (for MAX and HAVING)
    # add_index :job_offer_actions, [:job_offer_id, :action_type, :valid_till],
    #          name: 'idx_job_offer_actions_expiration_query'

    # Index on job_offers.expired_on for the NULL check in WHERE clause
    add_index :job_offers, :expired_on,
      name: "idx_job_offers_expired_on"

    # Additional covering index if the table grows large - includes all needed columns
    # This would eliminate the need to access the actual table rows
    add_index :job_offer_actions, [:action_type, :job_offer_id, :valid_till],
      name: "idx_job_offer_actions_covering",
      where: "action_type IN ('created', 'extended')"
  end
end
