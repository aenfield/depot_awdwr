class OrderMailer < ApplicationMailer
  default from: "Andrew Enfield <depot@example.com>"
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.received.subject
  #
  def received(order)
    @order = order

    mail to: order.email, subject: "Pragmatic Store order confirmation"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.order_mailer.shipped.subject
  #
  def shipped(order)
    @order = order

    mail to: order.email, subject: "Pragmatic Store order shipped"
  end
end
