class Native::SessionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :handoff

  def handoff
    user = User.find_signed(params[:token], purpose: "native_handoff")

    return head :unauthorized unless user

    sign_in(user)

    redirect_to "/reset_app"
  end
end
