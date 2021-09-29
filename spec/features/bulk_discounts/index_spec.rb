require 'rails_helper'

RSpec.describe 'Bulk Discount Index Page' do
  before :each do
    @merchant1 = Merchant.create!(name: 'Hair Care')

    @bulk_discount_1 = @merchant1.bulk_discounts.create!(name: "Discount A", percentage_discount: 10, quantity_threshold: 10)
    @bulk_discount_2 = @merchant1.bulk_discounts.create!(name: "Discount B", percentage_discount: 5, quantity_threshold: 7)
    @bulk_discount_3 = @merchant1.bulk_discounts.create!(name: "Discount C", percentage_discount: 20, quantity_threshold: 25)

    @customer_1 = Customer.create!(first_name: 'Joey', last_name: 'Smith')
    @customer_2 = Customer.create!(first_name: 'Cecilia', last_name: 'Jones')
    @customer_3 = Customer.create!(first_name: 'Mariah', last_name: 'Carrey')
    @customer_4 = Customer.create!(first_name: 'Leigh Ann', last_name: 'Bron')
    @customer_5 = Customer.create!(first_name: 'Sylvester', last_name: 'Nader')
    @customer_6 = Customer.create!(first_name: 'Herber', last_name: 'Kuhn')

    @invoice_1 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_2 = Invoice.create!(customer_id: @customer_1.id, status: 2)
    @invoice_3 = Invoice.create!(customer_id: @customer_2.id, status: 2)
    @invoice_4 = Invoice.create!(customer_id: @customer_3.id, status: 2)
    @invoice_5 = Invoice.create!(customer_id: @customer_4.id, status: 2)
    @invoice_6 = Invoice.create!(customer_id: @customer_5.id, status: 2)
    @invoice_7 = Invoice.create!(customer_id: @customer_6.id, status: 1)

    @item_1 = Item.create!(name: "Shampoo", description: "This washes your hair", unit_price: 10, merchant_id: @merchant1.id)
    @item_2 = Item.create!(name: "Conditioner", description: "This makes your hair shiny", unit_price: 8, merchant_id: @merchant1.id)
    @item_3 = Item.create!(name: "Brush", description: "This takes out tangles", unit_price: 5, merchant_id: @merchant1.id)
    @item_4 = Item.create!(name: "Hair tie", description: "This holds up your hair", unit_price: 1, merchant_id: @merchant1.id)

    @ii_1 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_1.id, quantity: 1, unit_price: 10, status: 0)
    @ii_2 = InvoiceItem.create!(invoice_id: @invoice_1.id, item_id: @item_2.id, quantity: 1, unit_price: 8, status: 0)
    @ii_3 = InvoiceItem.create!(invoice_id: @invoice_2.id, item_id: @item_3.id, quantity: 1, unit_price: 5, status: 2)
    @ii_4 = InvoiceItem.create!(invoice_id: @invoice_3.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_5 = InvoiceItem.create!(invoice_id: @invoice_4.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_6 = InvoiceItem.create!(invoice_id: @invoice_5.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)
    @ii_7 = InvoiceItem.create!(invoice_id: @invoice_6.id, item_id: @item_4.id, quantity: 1, unit_price: 5, status: 1)

    @transaction1 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_1.id)
    @transaction2 = Transaction.create!(credit_card_number: 230948, result: 1, invoice_id: @invoice_3.id)
    @transaction3 = Transaction.create!(credit_card_number: 234092, result: 1, invoice_id: @invoice_4.id)
    @transaction4 = Transaction.create!(credit_card_number: 230429, result: 1, invoice_id: @invoice_5.id)
    @transaction5 = Transaction.create!(credit_card_number: 102938, result: 1, invoice_id: @invoice_6.id)
    @transaction6 = Transaction.create!(credit_card_number: 879799, result: 1, invoice_id: @invoice_7.id)
    @transaction7 = Transaction.create!(credit_card_number: 203942, result: 1, invoice_id: @invoice_2.id)
  end

  it 'lists all the bulk discounts for the merchant' do
    visit merchant_bulk_discounts_path(@merchant1)
    expect(page).to have_content(@bulk_discount_1.name)
    expect(page).to have_content(@bulk_discount_1.percentage_discount)
    expect(page).to have_content(@bulk_discount_1.quantity_threshold)
    expect(page).to have_content(@bulk_discount_2.percentage_discount)
    expect(page).to have_content(@bulk_discount_2.quantity_threshold)
    expect(page).to have_content(@bulk_discount_3.percentage_discount)
    expect(page).to have_content(@bulk_discount_3.quantity_threshold)
    click_link "Discount A"
    expect(current_path).to eq(merchant_bulk_discount_path(@merchant1, @bulk_discount_1))
  end

  it 'has a link to create new discount' do
    visit merchant_bulk_discounts_path(@merchant1)
    expect(page).to have_content("Create New Discount")
    click_on "Create New Discount"
    expect(current_path).to eq(new_merchant_bulk_discount_path(@merchant1))
  end

  it 'has a link to delete discount next to each discount' do
    visit merchant_bulk_discounts_path(@merchant1)
    within("#bulk_discounts") do
      expect(page).to have_content(@bulk_discount_1.percentage_discount)
      expect(page).to have_content(@bulk_discount_1.quantity_threshold)
      within("#bulk_discount-#{@bulk_discount_1.id}") do
        expect(page).to have_content("Delete Discount")
        click_on "Delete Discount"
      end
      expect(current_path).to eq(merchant_bulk_discounts_path(@merchant1))
      expect(page).to_not have_content (@bulk_discount_1.percentage_discount)
      expect(page).to_not have_content (@bulk_discount_1.quantity_threshold)
    end
  end
end
