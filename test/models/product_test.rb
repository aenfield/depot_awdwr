require "test_helper"

class ProductTest < ActiveSupport::TestCase
  fixtures :products # not needed because default is to load all fixtures (not just products)

  test "product attributes must not be empty" do 
    product = Product.new
    assert product.invalid?
    assert product.errors[:title].any?
    assert product.errors[:description].any?
    assert product.errors[:price].any?
    assert product.errors[:image_url].any?
  end

  test "product price must be positive" do
    expected_error_msg = "must be greater than or equal to 0.01" # p95 shows how to use error table for messages
    product = new_product('foo.png')
    product.price = -1

    assert product.invalid?
    assert_equal [ expected_error_msg ], product.errors[:price]

    product.price = 0
    assert product.invalid?
    assert_equal [ expected_error_msg ], product.errors[:price]

    product.price = 1
    assert product.valid?
  end

  test "image url has correct endings" do
    ok = %w[ fred.gif fred.jpg fred.png FRED.JPG FRED.Jpg
             http://a.b.c/x/y/z/fred.gif ]
    bad = %w[ fred.doc fred.gif/more fred.gif.more ]

    ok.each do |image_url|
      assert new_product(image_url).valid?, "#{image_url} must be valid"
    end

    bad.each do |image_url| 
      assert new_product(image_url).invalid?, "#{image_url} must be invalid"
    end
  end

  test "product is not valid without a unique title" do
    product = new_product('foo.png')
    product.title = products(:ruby).title
    
    assert product.invalid?
    assert_equal [ "has already been taken" ], product.errors[:title] # p95 shows how to use error table for messages
  end


  def new_product(image_url)
    product = Product.new(title:        "My book title",
                          description:  "yyy",
                          price:        1,
                          image_url:    image_url)
  end
end
