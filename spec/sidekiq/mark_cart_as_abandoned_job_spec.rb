require 'rails_helper'

RSpec.describe(MarkCartAsAbandonedJob, type: :job) do
  describe '#perform' do
    let!(:active_cart) { create(:cart, last_interaction_at: 1.hour.ago) }
    let!(:inactive_cart) { create(:cart, :inactive) }
    let!(:abandoned_cart) { create(:cart, :abandoned) }
    let!(:old_abandoned_cart) { create(:cart, :old_abandoned) }

    before { inactive_cart.update_column(:last_interaction_at, 5.hours.ago) }

    it 'marks inactive carts as abandoned' do
      expect do
        described_class.new.perform
      end.to change { inactive_cart.reload.abandoned? }.from(false).to(true)
    end

    it 'does not mark active carts as abandoned' do
      expect do
        described_class.new.perform
      end.not_to change { active_cart.reload.abandoned? }
    end

    it 'removes old abandoned carts' do
      expect do
        described_class.new.perform
      end.to change { Cart.count }.by(-1)
    end

    it 'does not remove recently abandoned carts' do
      expect do
        described_class.new.perform
      end.not_to change { abandoned_cart.reload.persisted? }
    end
  end
end
