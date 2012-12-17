class CartItemsController < ApplicationController

  # GET /cart_items
  # GET /cart_items.json
  def index
    @cart_items = CartItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @cart_items }
    end
  end

  # GET /cart_items/new
  # GET /cart_items/new.json
  def new
    @cart_item = CartItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @cart_item }
    end
  end

  # GET /cart_items/1/edit
  def edit
    @cart_item = CartItem.find(params[:id])
  end

  # POST /cart_items
  # POST /cart_items.json
  def create
      if params[:add_all] == 'true'
        add_all
      else
        add_single
      end
  end

  def add_single
    @data_file = DataFile.find(params[:data_file_ids])
    @cart_item = current_user.cart_items.build
    @cart_item.data_file= @data_file

    respond_to do |format|
      if @cart_item.save
        format.html { redirect_to data_file_path(@data_file),
          notice: 'File was successfully added to cart.' }
        format.js { }
      else
        format.html { redirect_to data_file_path(@data_file),
          notice: 'File could not be added to cart.' }
      end
    end
  end

  def add_all
    count = 0
    params[:data_file_ids].each do |data_file_id|
      @data_file = DataFile.find(data_file_id)
      unless current_user.data_file_in_cart?(@data_file)
        @cart_item = current_user.cart_items.build
        @cart_item.data_file= @data_file
        @cart_item.save
        count = count + 1
      end
    end
    respond_to do |format|
      format.html { redirect_to data_files_path(@data_file),
          notice: "#{count} files were added to your cart." }
      format.js { }
    end
  end

  # DELETE /cart_items/1
  # DELETE /cart_items/1.json
  def destroy
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy

    respond_to do |format|
      format.html { redirect_to cart_items_url }
      format.json { head :ok }
    end
  end

  def destroy_all
    session[:return_to]= request.referer
    CartItem.where('user_id' == current_user.id).each do |cart_item|
      unless cart_item.nil?
        cart_item.destroy
      end
    end
    respond_to do |format|
      format.html { redirect_to session[:return_to], notice: 'Your cart was cleared.' }
      format.js {  }
    end
  end

   # DELETE /cart_items/1
  # DELETE /cart_items/1.json
  def download
    @cart_item = CartItem.find(params[:id])
    @cart_item.destroy

    respond_to do |format|
      format.html { redirect_to cart_items_url }
      format.json { head :ok }
    end
  end
end
