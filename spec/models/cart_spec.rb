require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  describe 'associations' do
    it { should have_many(:cart_items).dependent(:destroy) }
    it { should have_many(:products).through(:cart_items) }
  end

  describe '#add_product' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0) }

    it 'adds a new product to the cart' do
      expect { cart.add_product(product, 2) }.to change { cart.cart_items.count }.by(1)
      expect(cart.cart_items.first.quantity).to eq(2)
      expect(cart.total_price).to eq(20.0)
    end

    it 'increases quantity if product already exists' do
      cart.add_product(product, 2)
      cart.reload
      expect { cart.add_product(product, 3) }.not_to change { cart.cart_items.count }
      expect(cart.cart_items.first.quantity).to eq(5)
      expect(cart.total_price).to eq(50.0)
    end
  end

  describe '#remove_product' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }
    let(:other_product) { create(:product) }

    before do
      cart.add_product(product, 2)
      cart.reload
    end

    it 'removes the product from the cart' do
      expect { cart.remove_product(product) }.to change { cart.cart_items.count }.by(-1)
      expect(cart.total_price).to eq(0)
    end

    it 'returns false if product not in cart' do
      expect(cart.remove_product(other_product)).to be_falsey
    end
  end

  describe '#update_quantity' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0) }
    let(:other_product) { create(:product) }

    before do
      cart.add_product(product, 2)
      cart.reload
    end

    it 'updates the quantity of the product' do
      expect { cart.update_quantity(product, 5) }.not_to change { cart.cart_items.count }
      expect(cart.cart_items.first.quantity).to eq(5)
      expect(cart.total_price).to eq(50.0)
    end

    it 'removes the product if quantity is 0' do
      expect { cart.update_quantity(product, 0) }.to change { cart.cart_items.count }.by(-1)
      expect(cart.total_price).to eq(0)
    end

    it 'returns false if product not in cart' do
      expect(cart.update_quantity(other_product, 5)).to be_falsey
    end
  end

  describe '#empty?' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product) }

    it 'returns true when cart has no items' do
      expect(cart.empty?).to be_truthy
    end

    it 'returns false when cart has items' do
      cart.add_product(product, 1)
      expect(cart.empty?).to be_falsey
    end
  end

  describe '#abandoned?' do
    let(:cart) { create(:cart) }

    it 'returns false when not abandoned' do
      expect(cart.abandoned?).to be_falsey
    end

    it 'returns true when abandoned' do
      cart.update(abandoned_at: Time.current)
      expect(cart.abandoned?).to be_truthy
    end
  end

  describe '#mark_as_abandoned' do
    let!(:cart) { create(:cart) }

    it 'marks the cart as abandoned' do
      expect { cart.mark_as_abandoned }.to change { cart.abandoned? }.from(false).to(true)
    end

    it 'does not mark as abandoned if already abandoned' do
      cart.update(abandoned_at: 1.day.ago)
      expect { cart.mark_as_abandoned }.not_to change { cart.abandoned_at }
    end
  end

  describe '#remove_if_abandoned' do
    let!(:cart) { create(:cart) }

    it 'does not remove cart if not abandoned' do
      expect { cart.remove_if_abandoned }.not_to change { Cart.count }
    end

    it 'does not remove cart if abandoned for less than 7 days' do
      cart.update(abandoned_at: 6.days.ago)
      expect { cart.remove_if_abandoned }.not_to change { Cart.count }
    end

    it 'removes cart if abandoned for more than 7 days' do
      cart.update(abandoned_at: 8.days.ago)
      expect { cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end

  describe 'callbacks' do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, price: 10.0) }

    it 'updates total_price before save' do
      cart.add_product(product, 2)
      expect(cart.total_price).to eq(20.0)
    end

    it 'updates last_interaction_at before save' do
      old_time = cart.last_interaction_at
      sleep(1)
      cart.add_product(product, 1)
      expect(cart.last_interaction_at).to be > old_time
    end
  end
end
