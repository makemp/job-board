# frozen_string_literal: true

require "rails_helper"

RSpec.describe JobAlerts::FetchDataService do
  describe ".call" do
    it "initializes the service and calls the call method" do
      service_instance = instance_double(described_class, call: {})
      allow(described_class).to receive(:new).with(:daily).and_return(service_instance)

      described_class.call(:daily)

      expect(service_instance).to have_received(:call)
    end
  end

  describe "#call" do
    let!(:employer) { create(:employer) }
    let!(:job_alert) { create(:job_alert, :confirmed) }

    # Filters
    let!(:daily_filter) { create(:job_alert_filter, job_alert: job_alert, frequency: :daily, region: "Canada", category: "Engineering", enabled: true) }
    let!(:weekly_filter) { create(:job_alert_filter, job_alert: job_alert, frequency: :weekly, region: "USA", category: "Sales", enabled: true) }
    let!(:monthly_filter) { create(:job_alert_filter, job_alert: job_alert, frequency: :monthly, region: "Australia", category: "Marketing", enabled: true) }

    # Job Offers
    let!(:daily_offer) do
      create(:job_offer, employer: employer, region: "Canada", category: "Engineering").tap do |offer|
        create(:job_offer_action, job_offer: offer, created_at: 20.hours.ago)
      end
    end
    let!(:weekly_offer) do
      create(:job_offer, employer: employer, region: "USA", category: "Sales").tap do |offer|
        create(:job_offer_action, job_offer: offer, created_at: 5.days.ago)
      end
    end
    let!(:monthly_offer) do
      create(:job_offer, employer: employer, region: "Australia", category: "Marketing").tap do |offer|
        create(:job_offer_action, job_offer: offer, created_at: 20.days.ago)
      end
    end
    let!(:old_offer) do
      create(:job_offer, employer: employer, region: "Canada", category: "Engineering").tap do |offer|
        create(:job_offer_action, job_offer: offer, created_at: 2.months.ago)
      end
    end

    context "when frequency is :daily" do
      subject(:call_service) { described_class.new(:daily).call }

      it "returns job offers matching daily filters" do
        expect(call_service[job_alert.id]).to contain_exactly(daily_offer)
      end
    end

    context "when frequency is :weekly" do
      subject(:call_service) { described_class.new(:weekly).call }

      it "returns job offers matching daily and weekly filters" do
        expect(call_service[job_alert.id]).to contain_exactly(daily_offer, weekly_offer)
      end
    end

    context "when frequency is :monthly" do
      subject(:call_service) { described_class.new(:monthly).call }

      it "returns job offers matching daily, weekly, and monthly filters" do
        expect(call_service[job_alert.id]).to contain_exactly(daily_offer, weekly_offer, monthly_offer)
      end
    end

    context "with inactive filters" do
      subject(:call_service) { described_class.new(:monthly).call }

      let!(:unconfirmed_alert) { create(:job_alert) }
      let!(:unconfirmed_filter) { create(:job_alert_filter, job_alert: unconfirmed_alert, frequency: :daily, enabled: true) }
      let!(:disabled_filter) { create(:job_alert_filter, job_alert: job_alert, frequency: :daily, enabled: false) }

      it "ignores filters from unconfirmed alerts" do
        expect(call_service).not_to have_key(unconfirmed_alert.id)
      end

      it "ignores disabled filters" do
        # The only offers returned should be from the active filters
        expect(call_service[job_alert.id]).to contain_exactly(daily_offer, weekly_offer, monthly_offer)
      end
    end

    context "when a job offer matches multiple filters" do
      subject(:call_service) { described_class.new(:weekly).call }
      let!(:another_daily_filter) { create(:job_alert_filter, job_alert: job_alert, frequency: :daily, region: "Canada", category: "Engineering", enabled: true) }

      it "includes the job offer for each matching filter" do
        expect(call_service[job_alert.id]).to contain_exactly(daily_offer, daily_offer, weekly_offer)
      end
    end

    context "when matching categories" do
      subject(:call_service) { described_class.new(:daily).call }

      let(:overcategory) { "Engineering & Project Management" }
      let(:subcategory) { "Mining Engineering" }

      context "when filter has an overcategory" do
        let!(:offer_with_subcategory) do
          create(:job_offer, employer: employer, region: "Canada", category: subcategory).tap do |offer|
            create(:job_offer_action, job_offer: offer, created_at: 20.hours.ago)
          end
        end
        let!(:filter_with_overcategory) { create(:job_alert_filter, job_alert: job_alert, frequency: :daily, region: "Canada", category: overcategory, enabled: true) }

        it "returns job offers that are within the overcategory" do
          expect(call_service[job_alert.id]).to contain_exactly(daily_offer, offer_with_subcategory)
        end
      end

      context "when filter has an exact category" do
        let!(:offer_with_category) do
          create(:job_offer, employer: employer, region: "Canada", category: subcategory).tap do |offer|
            create(:job_offer_action, job_offer: offer, created_at: 20.hours.ago)
          end
        end
        let!(:filter_with_category) { create(:job_alert_filter, job_alert: job_alert, frequency: :daily, region: "Canada", category: subcategory, enabled: true) }

        it "returns job offers that match the category exactly" do
          expect(call_service[job_alert.id]).to contain_exactly(daily_offer, offer_with_category)
        end
      end

      context "when category does not match" do
        let!(:offer_with_category) do
          create(:job_offer, employer: employer, region: "Canada", category: "Sales").tap do |offer|
            create(:job_offer_action, job_offer: offer, created_at: 20.hours.ago)
          end
        end
        let!(:filter_with_different_category) { create(:job_alert_filter, job_alert: job_alert, frequency: :daily, region: "Canada", category: "Marketing", enabled: true) }

        it "does not return job offers that do not match the category" do
          expect(call_service[job_alert.id]).to contain_exactly(daily_offer)
        end
      end
    end
  end
end
