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

    #used for admin invoices
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
      @bd_1 = @merchant1.bulk_discounts.create!(name: "Discount A", percentage_discount: 10, quantity_threshold: 10)
      @bd_2 = @merchant1.bulk_discounts.create!(name: "Discount B", percentage_discount: 20, quantity_threshold: 15)

      actual = []
      @invoice_1.max_discounts.each do |discount|
        actual << discount.maximum_discount
      end

      expected = [ @bd_2.percentage_discount, @bd_1.percentage_discount]
      expect(actual).to eq(expected)
    end

    #used for admin invoices
    it 'returns total discounted revenue for invoice' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Foot Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Conditioner", description: "This smooths your hair", unit_price: 10, merchant_id: @merchant1.id)
      @item_3 = Item.create!(name: "Foot Cream", description: "This smooths your feet", unit_price: 10, merchant_id: @merchant2.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 7, unit_price: 10, status: 1)
      @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 10, unit_price: 10, status: 1)
      @ii_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 17, unit_price: 10, status: 1)
      @bd_1 = @merchant1.bulk_discounts.create!(name: "Discount A", percentage_discount: 10, quantity_threshold: 10)
      @bd_2 = @merchant1.bulk_discounts.create!(name: "Discount B", percentage_discount: 20, quantity_threshold: 15)

      expect(@invoice_1.total_discounted_revenue).to eq(450.00)
    end

    it 'finds invoice_items of invoice by merchant' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Foot Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Conditioner", description: "This smooths your hair", unit_price: 10, merchant_id: @merchant1.id)
      @item_3 = Item.create!(name: "Foot Cream", description: "This smooths your feet", unit_price: 10, merchant_id: @merchant2.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 7, unit_price: 10, status: 1)
      @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 10, unit_price: 10, status: 1)
      @ii_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 17, unit_price: 10, status: 1)
      @bd_1 = @merchant1.bulk_discounts.create!(name: "Discount A", percentage_discount: 10, quantity_threshold: 10)
      @bd_2 = @merchant1.bulk_discounts.create!(name: "Discount B", percentage_discount: 20, quantity_threshold: 15)

      expect(@invoice_1.merchant_invoice_items(@merchant1)).to eq([@ii_1, @ii_2, @ii_3])
      expect(@invoice_1.merchant_invoice_items(@merchant2)).to eq([@ii_4])
    end

    it 'calculates total revenue for invoice by merchant' do
      @merchant1 = Merchant.create!(name: 'Hair Care')
      @merchant2 = Merchant.create!(name: 'Foot Care')
      @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id, status: 1)
      @item_8 = Item.create!(name: "Butterfly Clip", description: "This holds up your hair but in a clip", unit_price: 5, merchant_id: @merchant1.id)
      @item_2 = Item.create!(name: "Conditioner", description: "This smooths your hair", unit_price: 10, merchant_id: @merchant1.id)
      @item_3 = Item.create!(name: "Foot Cream", description: "This smooths your feet", unit_price: 10, merchant_id: @merchant2.id)
      @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
      @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2, created_at: "2012-03-27 14:54:09")
      @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 15, unit_price: 10, status: 2)
      @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_8.id, quantity: 7, unit_price: 10, status: 1)
      @ii_3 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 10, unit_price: 10, status: 1)
      @ii_4 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_3.id, quantity: 17, unit_price: 10, status: 1)
      @bd_1 = @merchant1.bulk_discounts.create!(name: "Discount A", percentage_discount: 10, quantity_threshold: 10)
      @bd_2 = @merchant1.bulk_discounts.create!(name: "Discount B", percentage_discount: 20, quantity_threshold: 15)

      expect(@invoice_1.merchant_total_revenue(@merchant1.id)).to eq(320.00)
    end
  end
end
