require "pago" # dummy payment processor (see lib/pago.rb)

class Order < ApplicationRecord
  has_many :line_items, dependent: :destroy

  enum :pay_type, {
    "Check"           => 0,
    "Credit card"     => 1,
    "Purchase order"  => 2
  }

  validates :name, :address, :email, presence: true
  validates :pay_type, inclusion: pay_types.keys

  def add_line_items_from_cart(cart)
    cart.line_items.each do |line_item|
      line_item.cart_id = nil
      line_items << line_item
    end
  end

  def charge!(pay_type_params)
    payment_details = {}
    payment_method = nil

    # convert form/model params to what payment processor requires
    case pay_type
    when "Check"
      payment_method = :check
      payment_details[:routing] = pay_type_params[:routing_number]
      payment_details[:account] = pay_type_params[:account_number]
    when "Credit card"
      payment_method = :credit_card
      month, year = pay_type_params[:expiration_date].split(//)
      payment_details[:cc_num] = pay_type_params[:routing_number]
      payment_details[:expiration_month] = month
      payment_details[:expiration_year] = year
    when "Check"
      payment_method = :po
      payment_details[:po_num] = pay_type_params[:po_number]
    end

    payment_result = Pago.make_payment(
      order_id: id,
      payment_method: payment_method,
      payment_details: payment_details
    )

    if payment_result.succeeded?
      OrderMailer.received(self).deliver_later
    else
      raise payment_result.error
    end
  end
end
