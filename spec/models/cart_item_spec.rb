require 'rails_helper'

RSpec.describe CartItem, type: :model do
  describe 'associations' do
    it { should belong_to(:cart) }
    it { should belong_to(:product) }
  end

  describe 'validations' do
    it { should validate_presence_of(:quantity) }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }

    it 'validates uniqueness of cart_id scoped to product_id' do
      cart_item = create(:cart_item)
      duplicate = build(:cart_item, cart: cart_item.cart, product: cart_item.product)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:cart_id]).to include('has already been taken')
    end
  end

  describe '#total_price' do
    let(:product) { create(:product, price: 15.50) }
    let(:cart_item) { create(:cart_item, product: product, quantity: 3) }

    it 'calculates total price correctly' do
      expect(cart_item.total_price).to eq(46.50)
    end
  end
end
