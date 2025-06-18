# == Schema Information
#
# Table name: contacts
#
#  id         :bigint           not null, primary key
#  email      :string(255)      not null
#  message    :text             not null
#  name       :string(255)      not null
#  topic      :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Contact < ApplicationRecord
  validates :name, :email, :topic, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, :email, :topic, length: { in: 5..255 }
  validates :message, length: { in: 15..5000 }
end
