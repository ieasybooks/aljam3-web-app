# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  confirmation_sent_at   :datetime
#  confirmation_token     :string
#  confirmed_at           :datetime
#  current_sign_in_at     :datetime
#  current_sign_in_ip     :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  failed_attempts        :integer          default(0), not null
#  last_sign_in_at        :datetime
#  last_sign_in_ip        :string
#  locked_at              :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  role                   :integer          default("user"), not null
#  sign_in_count          :integer          default(0), not null
#  suspended_at           :datetime
#  unconfirmed_email      :string
#  unlock_token           :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_unlock_token          (unlock_token) UNIQUE
#
require "rails_helper"

RSpec.describe User do
  describe "associations" do
    it { is_expected.to have_many(:search_queries).dependent(:destroy) }
    it { is_expected.to have_many(:search_clicks).through(:search_queries) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:encrypted_password) }
    it { is_expected.to validate_presence_of(:sign_in_count) }
    it { is_expected.to validate_presence_of(:failed_attempts) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:role).with_values(user: 0, admin: 1) }
  end
end
