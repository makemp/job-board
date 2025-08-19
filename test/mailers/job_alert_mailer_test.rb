require "test_helper"

class JobAlertMailerTest < ActionMailer::TestCase
  test "confirmation_email" do
    mail = JobAlertMailer.confirmation_email
    assert_equal "Confirmation email", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
