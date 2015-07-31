class Api::V1::OrdersController < ApplicationController
  before_action :authenticate_with_token!
  before_action :order_exists, only: [:show]

  respond_to :json

  def index
    orders = current_user.orders.page(params[:page]).per(params[:per_page])

    render json: orders, meta: pagination(orders, params[:per_page])
  end

  def show
    respond_with current_user.orders.find(params[:id])
  end

  def create
    order = current_user.orders.build
    order.build_placements(order_params[:product_orders])

    if order.save
      order.reload

      OrderMailer.delay.send_confirmation(order)
      render json: order, status: 201
    else
      render json: { errors: order.errors }, status: 422
    end
  end

  private

  def order_params
    params.require(:order).permit(product_orders: [:product_id, :quantity])
  end

  def order_exists
    if current_user.orders.where(id: params[:id]).count == 0
      head 404
    end
  end

end
