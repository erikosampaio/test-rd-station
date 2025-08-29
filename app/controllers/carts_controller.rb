class CartsController < ApplicationController
  before_action :set_cart, only: [:show, :add_item, :remove_product]

  # GET /cart
  def show
    render json: cart_response(@cart)
  end

  # POST /cart
  def create
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    if quantity <= 0
      return render json: { error: 'Quantity must be greater than 0' }, status: :unprocessable_entity
    end

    cart = get_or_create_cart
    cart.add_product(product, quantity)

    render json: cart_response(cart), status: :created
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  end

  # POST /cart/add_item
  def add_item
    product = Product.find(params[:product_id])
    quantity = params[:quantity].to_i

    if quantity <= 0
      return render json: { error: 'Quantity must be greater than 0' }, status: :unprocessable_entity
    end

    @cart.add_product(product, quantity)
    render json: cart_response(@cart)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  end

  # DELETE /cart/:product_id
  def remove_product
    product = Product.find(params[:product_id])

    if @cart.remove_product(product)
      render json: cart_response(@cart)
    else
      render json: { error: 'Product not found in cart' }, status: :not_found
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  end

  private
  def set_cart
    @cart = get_or_create_cart
  end

  def get_or_create_cart
    cart_id = session[:cart_id]

    if cart_id
      cart = Cart.find_by(id: cart_id)
      return cart if cart && !cart.abandoned?
    end

    cart = Cart.create!(total_price: 0)
    session[:cart_id] = cart.id
    cart
  end

  def cart_response(cart)
    {
      id: cart.id,
      products: cart.cart_items.map do |item|
        {
          id: item.product.id,
          name: item.product.name,
          quantity: item.quantity,
          unit_price: item.product.price.to_f,
          total_price: item.total_price.to_f
        }
      end,
      total_price: cart.total_price.to_f
    }
  end
end
