class InvoiceItem < ApplicationRecord
  validates_presence_of :invoice_id,
                        :item_id,
                        :quantity,
                        :unit_price,
                        :status

  belongs_to :invoice
  belongs_to :item

  enum status: [:pending, :packaged, :shipped]

  def self.incomplete_invoices
    invoice_ids = InvoiceItem.where("status = 0 OR status = 1").pluck(:invoice_id)
    Invoice.order(created_at: :asc).find(invoice_ids)
  end

  def applied_discount
    item.merchant.bulk_discounts
        .select("bulk_discounts.*")
        .where('bulk_discounts.quantity_threshold <= ?', quantity)
        .order('bulk_discounts.percentage_discount desc')
        .first
  end

  def revenue
    unit_price * quantity
  end

  def revenue_after_discount
    revenue * (1- (applied_discount.percentage_discount.to_f / 100))
  end

  def self.total_discounted_revenue_by_ii
    self.sum do |invoice_item|
      if invoice_item.applied_discount
        invoice_item.revenue_after_discount
      else
        invoice_item.revenue
      end
    end
  end
end
