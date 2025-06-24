require 'rails_helper'

RSpec.describe DeviseOverrides do
  let(:user) { create(:user) }

  describe '#send_devise_notification' do
    let(:mailer) { class_double(Devise::Mailer) }
    let(:delivery) { instance_double(ActionMailer::MessageDelivery) }

    before do
      allow(user).to receive(:devise_mailer).and_return(mailer)
      allow(mailer).to receive(:confirmation_instructions).and_return(delivery)
      allow(delivery).to receive(:deliver_later)
    end

    it 'uses deliver_later for devise mailers' do
      user.send_devise_notification(:confirmation_instructions)

      expect(delivery).to have_received(:deliver_later)
    end
  end

  describe '#active_for_authentication?' do
    it 'returns true when user is not suspended' do
      expect(user.active_for_authentication?).to be true
    end

    it 'returns false when user is suspended' do
      user.update(suspended_at: Time.current)

      expect(user.active_for_authentication?).to be false
    end
  end

  describe '#access_suspended?' do
    it 'returns false when suspended_at is nil' do
      expect(user.access_suspended?).to be false
    end

    it 'returns true when suspended_at is set' do
      user.update(suspended_at: Time.current)

      expect(user.access_suspended?).to be true
    end
  end

  describe '#inactive_message' do
    it 'returns :locked_html when user is locked' do
      user.lock_access!

      expect(user.inactive_message).to eq(:locked_html)
    end

    it 'returns :unconfirmed_html when user is unconfirmed' do
      user.update(confirmed_at: nil)

      expect(user.inactive_message).to eq(:unconfirmed_html)
    end

    it 'calls super when user is neither locked nor unconfirmed' do
      # Verify it's not returning our custom messages.
      expect(user.inactive_message).not_to be_in([ :locked_html, :unconfirmed_html ])
    end
  end

  describe '#unauthenticated_message' do
    it 'returns :locked_html when user is locked and not in paranoid mode' do
      allow(Devise).to receive(:paranoid).and_return(false)

      user.lock_access!

      expect(user.unauthenticated_message).to eq(:locked_html)
    end

    it 'calls super in other cases' do
      # Make sure it doesn't return :locked_html.
      allow(Devise).to receive(:paranoid).and_return(true)

      expect(user.unauthenticated_message).not_to eq(:locked_html)
    end
  end
end
