# frozen_string_literal: true

require "rails_helper"

RSpec.describe JobAlertsJob do
  describe "#perform" do
    subject(:perform) { described_class.new.perform(frequency:) }

    let(:frequency) { :daily }
    let(:job_offers_by_email) { {"test@example.com" => [1, 2]} }

    before do
      allow(JobAlerts::FetchDataService).to receive(:call).and_return(job_offers_by_email)
      allow(JobAlerts::SendEmailsService).to receive(:call)
    end

    context "when guard condition is met" do
      context "for daily frequency on a non-monday" do
        before do
          travel_to Time.zone.local(2023, 1, 10) # A Tuesday
        end

        it "calls the services" do
          perform
          expect(JobAlerts::FetchDataService).to have_received(:call).with(:daily)
          expect(JobAlerts::SendEmailsService).to have_received(:call).with(job_offers_by_email)
        end
      end

      context "for weekly frequency on a Monday after the 7th" do
        let(:frequency) { :weekly }

        before do
          travel_to Time.zone.local(2023, 1, 9) # A Monday
        end

        it "calls the services" do
          perform
          expect(JobAlerts::FetchDataService).to have_received(:call).with(:weekly)
          expect(JobAlerts::SendEmailsService).to have_received(:call).with(job_offers_by_email)
        end
      end

      context "for monthly frequency on a Monday before the 7th" do
        let(:frequency) { :monthly }

        before do
          travel_to Time.zone.local(2023, 1, 2) # A Monday
        end

        it "calls the services" do
          perform
          expect(JobAlerts::FetchDataService).to have_received(:call).with(:monthly)
          expect(JobAlerts::SendEmailsService).to have_received(:call).with(job_offers_by_email)
        end
      end
    end

    context "when guard condition is not met" do
      context "for daily frequency on a Monday" do
        before do
          travel_to Time.zone.local(2023, 1, 9) # A Monday
        end

        it "does not call the services" do
          perform
          expect(JobAlerts::FetchDataService).not_to have_received(:call)
          expect(JobAlerts::SendEmailsService).not_to have_received(:call)
        end
      end

      context "for weekly frequency on a non-Monday" do
        let(:frequency) { :weekly }

        before do
          travel_to Time.zone.local(2023, 1, 10) # A Tuesday
        end

        it "does not call the services" do
          perform
          expect(JobAlerts::FetchDataService).not_to have_received(:call)
          expect(JobAlerts::SendEmailsService).not_to have_received(:call)
        end
      end

      context "for weekly frequency on a Monday before the 8th" do
        let(:frequency) { :weekly }

        before do
          travel_to Time.zone.local(2023, 1, 2) # A Monday
        end

        it "does not call the services" do
          perform
          expect(JobAlerts::FetchDataService).not_to have_received(:call)
          expect(JobAlerts::SendEmailsService).not_to have_received(:call)
        end
      end

      context "for monthly frequency on a non-Monday" do
        let(:frequency) { :monthly }

        before do
          travel_to Time.zone.local(2023, 1, 3) # A Tuesday
        end

        it "does not call the services" do
          perform
          expect(JobAlerts::FetchDataService).not_to have_received(:call)
          expect(JobAlerts::SendEmailsService).not_to have_received(:call)
        end
      end

      context "for monthly frequency on a Monday after the 7th" do
        let(:frequency) { :monthly }

        before do
          travel_to Time.zone.local(2023, 1, 9) # A Monday
        end

        it "does not call the services" do
          perform
          expect(JobAlerts::FetchDataService).not_to have_received(:call)
          expect(JobAlerts::SendEmailsService).not_to have_received(:call)
        end
      end
    end
  end
end
