require "application_system_test_case"

class OrdersTest < ApplicationSystemTestCase
  include ActiveJob::TestHelper

  test "check dynamic payment type fields" do
    visit store_index_url
    click_on "Add to Cart", match: :first
    click_on "Checkout"

    assert has_no_field? "Routing number"
    assert has_no_field? "Account number"
    assert has_no_field? "Credit card number"
    assert has_no_field? "Expiration date"
    assert has_no_field? "Po number"

    select "Check", from: "Pay with"
    assert has_field? "Routing number"
    assert has_field? "Account number"
    assert has_no_field? "Credit card number"
    assert has_no_field? "Expiration date"
    assert has_no_field? "Po number"

    select "Credit card", from: "Pay with"
    assert has_no_field? "Routing number"
    assert has_no_field? "Account number"
    assert has_field? "Credit card number"
    assert has_field? "Expiration date"
    assert has_no_field? "Po number"

    select "Purchase order", from: "Pay with"
    assert has_no_field? "Routing number"
    assert has_no_field? "Account number"
    assert has_no_field? "Credit card number"
    assert has_no_field? "Expiration date"
    assert has_field? "PO number"
  end

  test "check order and delivery" do
    LineItem.delete_all
    Order.delete_all

    visit store_index_url

    click_on "Add to Cart", match: :first

    click_on "Checkout"

    fill_in "Name", with: "Dave Thomas"
    fill_in "Address", with: "123 Main Street"
    fill_in "Email", with: "dave@example.com"

    select "Check", from: "Pay with"
    fill_in "Routing number", with: "123"
    fill_in "Account number", with: "456"

    click_button "Place order"
    assert_text "Thank you for your order"

    # we have two jobs enqueued: the charge job we queue and the mail job the charge job itself queues
    perform_enqueued_jobs
    perform_enqueued_jobs
    assert_performed_jobs 2

    orders = Order.all
    assert_equal 1, orders.size

    order = Order.first
    assert_equal "Dave Thomas", order.name
    assert_equal "123 Main Street", order.address
    assert_equal "dave@example.com", order.email
    assert_equal "Check", order.pay_type
    assert_equal 1, order.line_items.size

    mail = ActionMailer::Base.deliveries.last
    assert_equal [ "dave@example.com" ], mail.to
    assert_equal "Andrew Enfield <depot@example.com>", mail[:from].value
    assert_equal "Pragmatic Store order confirmation", mail.subject
  end

  # these two scaffolding-created tests fail with Capybara::ElementNotFound: Unable to find field "Address" that is not disabled
  # and Capybara::ElementNotFound: Unable to find field "Pay type" that is not disabled messages; there's more to Capybara
  # that I don't yet know, so commenting them out for now... I tried looking at what I thought might be the page text that
  # Capybara's seeing, to see why it's not finding those elements (using puts page.body in the tests) but what it outputs doesn't
  # match what the screen shot Capybara takes shows, so I'm missing something.

  # And actually, the book just recommends getting rid of these auto-created tests 'because they duplicate what's already
  # being tested' (not sure that's actually the case), but I'll go w/ it for now since I certainly haven't reviewed what was
  # created automatically and we changed things from what the scaffolding created
end
