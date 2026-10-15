require "test_helper"

class RackMiniProfilerTest < ApplicationTest
  setup do
    @user = mock("user")
    ApplicationController.any_instance.stubs(:current_user).returns(@user)
    Rack::MiniProfiler.stubs(:authorize_request)
  end

  test "does not authorize non-admin users" do
    @user.stubs(:admin?).returns(false)

    get "/"

    Rack::MiniProfiler.expects(:authorize_request).never
  end

  test "authorizes admin users" do
    @user.stubs(:admin?).returns(true)
    Rack::MiniProfiler.expects(:authorize_request)

    get "/"
  end
end
