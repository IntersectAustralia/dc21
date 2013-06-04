class CartItemsController < ApplicationController

  layout 'data_files'

  def index
    @cart_items = cart_items.includes(:experiment, :created_by)
    session[:back]= request.referer
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
    data_file_id = params[:data_file_ids].to_i
    current_cart_ids = cart_items.collect(&:id)

    respond_to do |format|
      if !current_cart_ids.include?(data_file_id)
        current_user.cart_items << DataFile.find(data_file_id)
        format.html { redirect_to session[:return_to]||data_files_path,
            notice: 'File was successfully added to cart.' }
        format.js { render :nothing => true, :status => :ok }
      else
        format.html { redirect_to session[:return_to]||data_files_path,
            notice: 'File could not be added: It may already exist in your cart.' }
        format.js { render :nothing => true, :status => :not_modified }
      end
    end
  end

  def add_all
    session[:return_to]= request.referer
    search = DataFileSearch.new(session[:search])

    to_add = search.do_search(DataFile.scoped) - cart_items
    count = to_add.count


    if count > 0
      user_id = current_user.id
      values = to_add.collect(&:id).map {|data_file_id| "(#{data_file_id},#{user_id})"}.join(",")
      # by default, ActiveRecord generates a query for each data_file_id inserted, which is inefficient.
      ActiveRecord::Base.connection.execute("INSERT INTO data_files_users (data_file_id, user_id) VALUES #{values}")
    end

    respond_to do |format|
      format.html {redirect_to session[:return_to] || data_files_path,
          notice: "#{count} files were added to your cart." }
    end
  end

  def destroy
    session[:return_to]= request.referer

    ActiveRecord::Base.connection.execute("delete from data_files_users where user_id = #{current_user.id} and data_file_id = #{params[:id]}")

    respond_to do |format|
      format.html { redirect_to session[:return_to]||data_files_path, notice: "File was successfully removed from cart." }
      format.json { head :ok }
    end
  end

  def destroy_all
    session[:return_to]= request.referer
    if cart_items.count == 0
      redirect_to(data_files_path, :notice => "Your cart is empty.")
    else
      ActiveRecord::Base.connection.execute("delete from data_files_users where user_id = #{current_user.id}")
      respond_to do |format|
        format.html { redirect_to session[:return_to]||data_files_path, notice: 'Your cart was cleared.' }
        format.js { render :nothing => true, :status => :ok }
      end
    end
  end
end
