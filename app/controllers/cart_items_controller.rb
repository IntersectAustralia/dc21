class CartItemsController < ApplicationController

  layout 'data_files'

  def index
    @cart_items = current_user.cart_items
    session[:back]= request.referer
  end

  def new
    @cart_item = CartItem.new
    set_tab :explore, :contentnavigation
  end

  def edit
    @cart_item = CartItem.find(params[:id])
  end


  def create
    if params[:add_all] == 'true'
      add_all
    else
      add_single
    end
  end

  def add_single
    session[:return_to]= request.referer
    @data_file = DataFile.find(params[:data_file_ids])
    @cart_item = current_user.cart_items.build
    @cart_item.data_file= @data_file

    respond_to do |format|
      if !current_user.data_file_in_cart?(@data_file) and @cart_item.save
        format.html { redirect_to session[:return_to]||data_files_path,
            notice: 'File was successfully added to cart.' }
        format.js { }
      else
        format.html { redirect_to session[:return_to]||data_files_path,
            notice: 'File could not be added: It may already exist in your cart.' }
        format.js { }
      end
    end
  end

  def add_all
    count = 0
    session[:return_to]= request.referer
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
      format.html {  redirect_to session[:return_to]||data_files_path,
          notice: "#{count} files were added to your cart." }
    end
  end

  def destroy
    session[:return_to]= request.referer
    @cart_item = CartItem.find(params[:id])
    unless @cart_item.nil?
      @cart_item.destroy
    end

    respond_to do |format|
      format.html { redirect_to session[:return_to]||data_files_path, notice: "File was successfully removed from cart." }
      format.json { head :ok }
    end
  end

  def destroy_all
    session[:return_to]= request.referer
    if current_user.data_files.empty?
      redirect_to(data_files_path, :notice => "Your cart is empty.")
    else
      current_user.cart_items.each do |cart_item|
        unless cart_item.nil?
          cart_item.destroy
        end
      end
      respond_to do |format|
        format.html { redirect_to session[:return_to]||data_files_path, notice: 'Your cart was cleared.' }
        format.js {  }
      end
    end
  end
end
