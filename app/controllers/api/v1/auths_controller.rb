class Api::V1::AuthsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :destroy ]

  def destroy
    sign_out(current_user)

    render json: {}
  end
end
