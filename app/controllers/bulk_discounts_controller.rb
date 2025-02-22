class BulkDiscountsController < ApplicationController
  before_action :find_bulk_discount_and_merchant, only: [:show, :update,]
  before_action :find_merchant, only: [:index]

  def index
    @bulk_discounts = @merchant.bulk_discounts
    @holidays = HolidayFacade.holidays
  end

  def show
  end

  def new
    @bulk_discount = BulkDiscount.new
  end

  def create
    merchant = Merchant.find(params[:merchant_id])
    discount = merchant.bulk_discounts.new(bulk_discount_params)

    if discount.save
      redirect_to merchant_bulk_discounts_path(merchant)
      flash[:alert] = "New bulk discount was created!"
    else
      redirect_to new_merchant_bulk_discount_path(merchant)
      flash[:alert] = "Error: You must fill in all the blanks"
    end
  end

  def destroy
    merchant = Merchant.find(params[:merchant_id])
    bulk_discount = BulkDiscount.find(params[:id])
    bulk_discount.destroy
    redirect_to merchant_bulk_discounts_path(merchant)
  end

  def edit
    @merchant = Merchant.find(params[:merchant_id])
    @bulk_discount = BulkDiscount.find(params[:id])
  end

  def update
    merchant = Merchant.find(params[:merchant_id])
    bulk_discount = BulkDiscount.find(params[:id])
    bulk_discount.update(bulk_discount_params)
    redirect_to merchant_bulk_discount_path(merchant, bulk_discount)
    flash[:alert] = "Bulk discount has been updated"
  end


  private
  def bulk_discount_params
    params.require(:bulk_discount).permit(:percentage_discount, :quantity_threshold, :name)
  end

  def find_bulk_discount_and_merchant
    @bulk_discount = BulkDiscount.find(params[:id])
    @merchant = Merchant.find(params[:merchant_id])
  end

  def find_merchant
    @merchant = Merchant.find(params[:merchant_id])
  end
end
