class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    mark_abandoned_carts
    remove_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    carts_to_mark = Cart.where(
      abandoned_at: nil
    ).where('last_interaction_at < ?', 3.hours.ago)

    carts_to_mark.find_each do |cart|
      cart.mark_as_abandoned
    end
  end

  def remove_old_abandoned_carts
    carts_to_remove = Cart.where('abandoned_at < ?', 7.days.ago)

    carts_to_remove.find_each do |cart|
      cart.remove_if_abandoned
    end
  end
end
