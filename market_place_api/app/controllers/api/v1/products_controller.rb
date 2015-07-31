class Api::V1::ProductsController < ApplicationController
  before_action :authenticate_with_token!, only: [:create, :update, :destroy]
  before_action :product_exists, only: [:show]
  before_action :check_for_user_product, only: [:update, :destroy]
  respond_to :json

  def show
    respond_with Product.find(params[:id])
  end

  def index
    products = Product.search(search_params.symbolize_keys).page(params[:page]).per(params[:per_page])

    render json: products, meta: pagination(products, params[:per_page])
  end

  def create
    product = current_user.products.new(product_params)
    if product.save
      render json: product, status: 201
    else
      render json: { errors: product.errors }, status: 422
    end
  end

  def update
    product = current_user.products.find(params[:id])

    if product.update(product_params)
      render json: product
    else
      render json: { errors: product.errors }, status: 422
    end
  end

  def destroy
    product = current_user.products.find(params[:id])
    product.destroy

    head 204
  end

  private

  def product_params
    params.require(:product).permit(:title, :price, :published)
  end

  def search_params
    params.permit(:keyword, :min_price, :max_price, :product_ids => [])
  end

  def check_for_user_product
    unless product_exists_for_user params[:id]
      head 404
    end
  end

  def product_exists
    unless Product.where(id: params[:id]).count > 0
      head 404
    end
  end

  def product_exists_for_user id
    current_user.products.where(id: id).count > 0
  end

end
