require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:one)
    @random_title = "The Great Book #{rand(1000)}" # so we don't try to create a product w/ a non-unique title
  end

  test "should get index" do
    get products_url
    assert_response :success
  end

  test "should get new" do
    get new_product_url
    assert_response :success
  end

  test "should create product" do
    assert_difference("Product.count") do
      post products_url, params: { product: { description: @product.description, image_url: @product.image_url, price: @product.price, title: @random_title } }
    end

    assert_redirected_to product_url(Product.last)
  end

  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  test "should get edit" do
    get edit_product_url(@product)
    assert_response :success
  end

  test "should update product" do
    patch product_url(@product), params: { product: { description: @product.description, image_url: @product.image_url, price: @product.price, title: @random_title } }
    assert_redirected_to product_url(@product)
  end

  test "should destroy product" do
    # can delete this product (product :one) because line_items.yml doesn't have any lineitems referencing product one
    assert_difference("Product.count", -1) do
      delete product_url(@product)
    end

    assert_redirected_to products_url
  end

  test "should not destroy product that line items point to" do
    # can't delete this product (product :two) because line_items.yml has carts that point to it
    assert_raises ActiveRecord::RecordNotDestroyed do
      delete product_url(products(:two))
    end

    assert Product.exists?(products(:two).id)
  end
end
