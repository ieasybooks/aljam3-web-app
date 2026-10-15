require "test_helper"

class DeviseOverridesTest < ModelTest
  setup do
    @user = create(:user)
    @mailer = mock("Devise::Mailer")
    @delivery = mock("ActionMailer::MessageDelivery")
    @user.stubs(:devise_mailer).returns(@mailer)
    @mailer.stubs(:send).returns(@delivery)
    @delivery.stubs(:deliver_later)
  end

  test "delivers Devise notifications later" do
    @delivery.expects(:deliver_later)

    @user.send_devise_notification(:confirmation_instructions)
  end

  test "authenticates users who are not suspended" do
    assert @user.active_for_authentication?
  end

  test "does not authenticate suspended users" do
    @user.update!(suspended_at: Time.current)

    refute @user.active_for_authentication?
  end

  test "reports an unsuspended user" do
    refute @user.access_suspended?
  end

  test "reports a suspended user" do
    @user.update!(suspended_at: Time.current)

    assert @user.access_suspended?
  end

  test "uses the locked message for locked users" do
    @user.lock_access!

    assert_equal :locked_html, @user.inactive_message
  end

  test "uses the unconfirmed message for unconfirmed users" do
    @user.update!(confirmed_at: nil)

    assert_equal :unconfirmed_html, @user.inactive_message
  end

  test "uses Devise's inactive message for other users" do
    refute_includes [ :locked_html, :unconfirmed_html ], @user.inactive_message
  end

  test "uses the locked message for locked users outside paranoid mode" do
    Devise.stubs(:paranoid).returns(false)
    @user.lock_access!

    assert_equal :locked_html, @user.unauthenticated_message
  end

  test "does not expose the locked message in paranoid mode" do
    Devise.stubs(:paranoid).returns(true)

    refute_equal :locked_html, @user.unauthenticated_message
  end
end
