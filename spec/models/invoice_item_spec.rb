require 'rails_helper'

RSpec.describe InvoiceItem, type: :model do
  describe "validations" do
    it { should validate_presence_of :invoice_id }
    it { should validate_presence_of :item_id }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :unit_price }
    it { should validate_presence_of :status }
  end
  describe "relationships" do
    it { should belong_to :invoice }
    it { should belong_to :item }
  end

  describe "class methods" do
    before(:each) do
      @m1 = Merchant.create!(name: 'Merchant 1')
      @c1 = Customer.create!(first_name: 'Bilbo', last_name: 'Baggins')
      @c2 = Customer.create!(first_name: 'Frodo', last_name: 'Baggins')
      @c3 = Customer.create!(first_name: 'Samwise', last_name: 'Gamgee')
      @c4 = Customer.create!(first_name: 'Aragorn', last_name: 'Elessar')
      @c5 = Customer.create!(first_name: 'Arwen', last_name: 'Undomiel')
      @c6 = Customer.create!(first_name: 'Legolas', last_name: 'Greenleaf')
      @item_1 = Item.create!(name: 'Shampoo', description: 'This washes your hair', unit_price: 10, merchant_id: @m1.id)
      @item_2 = Item.create!(name: 'Conditioner', description: 'This makes your hair shiny', unit_price: 8, merchant_id: @m1.id)
      @item_3 = Item.create!(name: 'Brush', description: 'This takes out tangles', unit_price: 5, merchant_id: @m1.id)
      @i1 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i2 = Invoice.create!(customer_id: @c1.id, status: 2)
      @i3 = Invoice.create!(customer_id: @c2.id, status: 2)
      @i4 = Invoice.create!(customer_id: @c3.id, status: 2)
      @i5 = Invoice.create!(customer_id: @c4.id, status: 2)
      @ii_1 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
      @ii_2 = InvoiceItem.create!(invoice_id: @i1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
      @ii_3 = InvoiceItem.create!(invoice_id: @i2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
      @ii_4 = InvoiceItem.create!(invoice_id: @i3.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 1)
    end
    it 'incomplete_invoices' do
      expect(InvoiceItem.incomplete_invoices).to eq([@i1, @i3])
    end
  end

  it 'returns revenue' do
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
    @bd_1 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 10)
    @bd_2 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 15)

    expect(@ii_1.revenue).to eq(150.0)
    expect(@ii_4.revenue).to eq(170.0)
  end

  it 'returns max discount percentage for specific invoice_item' do
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
    @bd_1 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 10)
    @bd_2 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 15)

    expect(@ii_1.applied_discount).to eq(@bd_2)
    expect(@ii_3.applied_discount).to eq(@bd_1)
  end

  #helper method for total discounted revenue by ii
  it 'revenue of an invoice_item after discount if discount' do
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
    @bd_1 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 10)
    @bd_2 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 15)

    expect(@ii_1.revenue_after_discount).to eq(120.0)
  end

  it 'returns total discounted revenue for designated group of invoice_items' do
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
    @bd_1 = @merchant1.bulk_discounts.create!(percentage_discount: 10, quantity_threshold: 10)
    @bd_2 = @merchant1.bulk_discounts.create!(percentage_discount: 20, quantity_threshold: 15)

    invoice_items = @invoice_1.merchant_invoice_items(@merchant1)
    expect(invoice_items.total_discounted_revenue_by_ii).to eq(280.0)

    #merchant 2 has no discounts applied 
    invoice_items_2 = @invoice_1.merchant_invoice_items(@merchant2)
    expect(invoice_items_2.total_discounted_revenue_by_ii).to eq(170.0)
  end

end
