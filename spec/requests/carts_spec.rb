require 'rails_helper'

RSpec.describe "/carts", type: :request do
  let(:product) { create(:product, name: "Test Product", price: 10.0) }
  let(:cart) { create(:cart) }

  before do
    allow_any_instance_of(CartsController).to receive(:session).and_return({ cart_id: cart.id })
  end

  describe "GET /cart" do
    it "returns the current cart" do
      get '/cart'
      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['id']).to eq(cart.id)
      expect(json_response['products']).to be_an(Array)
      expect(json_response['total_price']).to eq(0)
    end
  end

  describe "POST /cart" do
    context "with valid parameters" do
      it "creates a new cart and adds product" do
        allow_any_instance_of(CartsController).to receive(:session).and_return({})

        expect do
          post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        end.to change { Cart.count }.by(1)

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['products'].length).to eq(1)
        expect(json_response['products'].first['name']).to eq(product.name)
        expect(json_response['products'].first['quantity']).to eq(2)
        expect(json_response['total_price']).to eq(20.0)
      end

      it "adds product to existing cart" do
        expect do
          post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json
        end.not_to change { Cart.count }

        expect(response).to have_http_status(:created)

        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(3)
        expect(json_response['total_price']).to eq(30.0)
      end
    end

    context "with invalid parameters" do
      it "returns error for invalid product" do
        post '/cart', params: { product_id: 999, quantity: 1 }, as: :json
        expect(response).to have_http_status(:not_found)
      end

      it "returns error for invalid quantity" do
        post '/cart', params: { product_id: product.id, quantity: 0 }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "POST /cart/add_item" do
    before do
      cart.add_product(product, 1)
    end

    context "when the product already is in the cart" do
      it "updates the quantity of the existing item in the cart" do
        expect do
          post '/cart/add_item', params: { product_id: product.id, quantity: 1 }, as: :json
        end.to change { cart.cart_items.first.reload.quantity }.by(1)

        expect(response).to have_http_status(:ok)

        json_response = JSON.parse(response.body)
        expect(json_response['products'].first['quantity']).to eq(2)
        expect(json_response['total_price']).to eq(20.0)
      end
    end

    context "with invalid parameters" do
      it "returns error for invalid product" do
        post '/cart/add_item', params: { product_id: 999, quantity: 1 }, as: :json
        expect(response).to have_http_status(:not_found)
      end

      it "returns error for invalid quantity" do
        post '/cart/add_item', params: { product_id: product.id, quantity: 0 }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /cart/:product_id" do
    before do
      cart.add_product(product, 2)
    end

    it "removes the product from the cart" do
      expect do
        delete "/cart/#{product.id}"
      end.to change { cart.cart_items.count }.by(-1)

      expect(response).to have_http_status(:ok)

      json_response = JSON.parse(response.body)
      expect(json_response['products']).to be_empty
      expect(json_response['total_price']).to eq(0)
    end

    it "returns error for product not in cart" do
      other_product = create(:product)
      delete "/cart/#{other_product.id}"
      expect(response).to have_http_status(:not_found)
    end

    it "returns error for invalid product" do
      delete "/cart/999"
      expect(response).to have_http_status(:not_found)
    end
  end
end
