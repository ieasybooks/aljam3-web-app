class Avo::Resources::User < Avo::BaseResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  self.devise_password_optional = true

  def fields
    field :id, as: :id
    field :email, as: :text
    field :password, as: :password
    field :sign_in_count, as: :number, readonly: true
    field :current_sign_in_at, as: :date_time, readonly: true
    field :last_sign_in_at, as: :date_time, readonly: true
    field :current_sign_in_ip, as: :text, readonly: true
    field :last_sign_in_ip, as: :text, readonly: true
    field :confirmation_token, as: :text
    field :confirmed_at, as: :date_time, readonly: true
    field :confirmation_sent_at, as: :date_time, readonly: true
    field :unconfirmed_email, as: :text, readonly: true
    field :failed_attempts, as: :number, readonly: true
    field :unlock_token, as: :text
    field :locked_at, as: :date_time, readonly: true
    field :role, as: :select, enum: ::User.roles
  end
end
