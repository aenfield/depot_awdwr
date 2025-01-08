class CombineItemsInCart < ActiveRecord::Migration[7.2]
  # I don't think this is needed because I think it only handles cases where there are multiple line items for the same item, which can no longer happen given the prev quantity addition, but I'll add it to follow the book and see a specific example of up/down in migrations
  def up
    # replace multiple items for a single product in a cart w/ a single item
    Cart.all.each do |cart|
      sum_of_each_item_in_cart = cart.line_items.group(:product_id).sum(:quantity)

      sum_of_each_item_in_cart.each do |product_id, quantity|
        if quantity > 1
          # remove indiv items for this product first
          cart.line_items.where(product_id: product_id).delete_all
          
          # and then replace w/ a single item
          item = cart.line_items.build(product_id: product_id)
          item.quantity = quantity
          item.save!
        end
      end
    end
  end

  def down
    # split items with quantity > 1 into multiple items
     LineItem.where("quantity>1").each do |line_item|
      line_item.quantity.times do
        LineItem.create(
          cart_id: line_item.cart_id,
          product_id: line_item.product_id,
          quantity: 1
        )
      end

      # and remove original line item
      line_item.destroy
     end
  end
end
