class Invoice < ApplicationRecord
  validates_presence_of :status,
                        :customer_id

  belongs_to :customer
  has_many :transactions
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :bulk_discounts, through: :merchants

  enum status: [:cancelled, 'in progress', :complete]

  def total_revenue
    invoice_items.sum("unit_price * quantity")
  end

  def merchant_total_revenue(merchant_id)
    invoice_items
      .joins(:item)
      .where('items.merchant_id = ?', merchant_id)
      .sum('invoice_items.quantity * invoice_items.unit_price')
  end

  def max_discounts
    invoice_items.joins(item: {merchant: :bulk_discounts})
                 .select("invoice_items.*, MAX(bulk_discounts.percentage_discount) AS maximum_discount")
                 .where("invoice_items.quantity >= bulk_discounts.quantity_threshold")
                 .group("invoice_items.id")
  end

  def total_discounted_revenue
    discount = max_discounts.sum do |ii|
      ii.maximum_discount * ii.quantity * ii.unit_price
    end
    total_revenue - discount.fdiv(100)
  end

  def merchant_invoice_items(merchant)
    invoice_items.joins(:item).where("items.merchant_id = ?", merchant.id)
  end
end
