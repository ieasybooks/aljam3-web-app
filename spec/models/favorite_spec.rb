# == Schema Information
#
# Table name: favorites
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :bigint           not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_favorites_on_book_id              (book_id)
#  index_favorites_on_user_id_and_book_id  (user_id,book_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (book_id => books.id)
#  fk_rails_...  (user_id => users.id)
#
require 'rails_helper'

RSpec.describe Favorite do
  describe 'associations' do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:book) }
  end

  describe 'validations' do
    subject { create(:favorite) }

    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:book_id) }
    it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:book_id) }
  end

  describe 'database constraints' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }

    it 'prevents duplicate favorites for the same user and book' do
      create(:favorite, user: user, book: book)

      expect {
        create(:favorite, user: user, book: book)
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
