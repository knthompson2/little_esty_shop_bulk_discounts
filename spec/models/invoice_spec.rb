require 'rails_helper'

RSpec.describe Invoice, type: :model do
  describe "validations" do
    it { should validate_presence_of :status }
    it { should validate_presence_of :customer_id }
  end
  describe "relationships" do
    it { should belong_to :customer }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many :transactions}
  end
  describe "instance methods" do
    it "total_revenue" do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 9, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 1, unit_price: 10, status: 1)

      expect(@invoice_1.total_revenue).to eq(100)
    end

    it 'returns max percentage discounts' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Conditioner", description: "This smooths your hair", unit_price: 10, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 7, unit_price: 10, status: 1)
      @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 10, unit_price: 10, status: 1)
      @bd_1 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 10)
      @bd_2 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 15)
      actual = []
      @invoice_1.max_discounts.each do |discount|
        actual << discount.maximum_discount
      end

      expected = [ @bd_2.percentage_discount, @bd_1.percentage_discount]
      expect(actual).to eq(expected)

    end

    it 'returns total discount' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Conditioner", description: "This smooths your hair", unit_price: 10, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 7, unit_price: 10, status: 1)
      @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 10, unit_price: 10, status: 1)
      @bd_1 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 10)
      @bd_2 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 15)

      expect(@invoice_1.total_discounted_revenue).to eq(280.00)
    end
    describe 'example 1' do
    before :each do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 5, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 5, unit_price: 10, status: 1)

      @bd1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)
    end

    it 'does not have discounted revenue' do
      expect(@invoice_1.total_revenue).to eq(100)
      expect(@invoice_1.total_discounted_revenue).to eq(100)
    end
  end

  describe 'example 2' do
    before :each do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 10, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 5, unit_price: 10, status: 1)

      @bd1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)
      @bd2 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 8)
    end

    it 'has one bulk discount' do
      expect(@invoice_1.total_discounted_revenue).to eq(130)
    end
  end

  describe 'example 3' do
    before :each do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 15, unit_price: 10, status: 1)

      @bd1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)
      @bd2 = @merchant1.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 15)
    end

    it 'has two bulk discounts' do
      expect(@invoice_1.total_discounted_revenue).to eq(201)
    end
  end

  describe 'example 4' do
    before :each do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 12, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 15, unit_price: 10, status: 1)

      @bd1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)
      @bd2 = @merchant1.bulk_discounts.create!(percentage_discount: 15, quantity_threshold: 15)
    end

    it 'has both items discounted with discount A' do
      expect(@invoice_1.total_discounted_revenue).to eq(216)
    end
  end

  describe 'example 5' do
    before :each do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Other merchant')
      @item_a1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_a2 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_b = Item.create!(name: "Other stuff", description: "Does stuff", unit_price: 5, merchant_id: @merchant2.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_a1.id, quantity: 12, unit_price: 10, status: 2)
      @ii_11 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_a2.id, quantity: 15, unit_price: 10, status: 1)
      @ii_12 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_b.id, quantity: 15, unit_price: 10, status: 1)

      @bd1 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 10)
      @bd2 = @merchant1.bulk_discounts.create!(percentage_discount: 30, quantity_threshold: 15)
    end

    it 'has two discounts but not for the second merchant' do
      expect(@invoice_1.total_discounted_revenue).to eq(351)
    end
  end
  end
end
