class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  before_save :update_total_price
  before_save :update_last_interaction_at

  def add_product(product, quantity = 1)
    cart_item = cart_items.find_or_initialize_by(product: product)
    cart_item.quantity = (cart_item.quantity || 0) + quantity
    cart_item.save!
    save!
  end

  def remove_product(product)
    cart_item = cart_items.find_by(product: product)
    return false unless cart_item

    cart_item.destroy
    save!
    true
  end

  def update_quantity(product, quantity)
    cart_item = cart_items.find_by(product: product)
    return false unless cart_item

    if quantity <= 0
      cart_item.destroy
    else
      cart_item.update(quantity: quantity)
    end

    save!
    true
  end

  def empty?
    cart_items.empty?
  end

  def abandoned?
    abandoned_at.present?
  end

  def mark_as_abandoned
    update(abandoned_at: Time.current) unless abandoned?
  end

  def remove_if_abandoned
    return false unless abandoned?
    return false unless abandoned_at < 7.days.ago

    destroy
    true
  end

  private

  def update_total_price
    self.total_price = cart_items.sum(&:total_price)
  end

  def update_last_interaction_at
    self.last_interaction_at = Time.current
  end
end
