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
    session[:return_to] = request.referer
    id = params[:id] || params[:data_file_ids]
    data_file = DataFile.find(id)
    current_cart_items = cart_items.collect(&:id)

    respond_to do |format|
      if data_file.modifiable?
        if !current_cart_items.include? data_file.id
          current_user.cart_items << data_file
          format.html {
            redirect_to session[:return_to]||data_files_path, notice: 'File was successfully added to cart.'
          }
          format.js {
            partial = render_to_string :partial => "layouts/notice", :locals => {:msg => 'File was successfully added to cart.'}
            data = {:notice => partial, :status => 200}
            render :json => data.to_json
          }
        else
          format.html {
            redirect_to session[:return_to]||data_files_path, notice: 'File could not be added: It may already exist in your cart.'
          }
          format.js {
            partial = render_to_string :partial => "layouts/notice", :locals => {:msg => 'File could not be added: It may already exist in your cart.'}
            data = {:notice => partial, :status => 422}
            render :json => data.to_json
          }
        end
      else
        format.html {
          redirect_to session[:return_to]||data_files_path, notice: 'File could not be added: The processing is not complete.'
        }
        format.js {
          partial = render_to_string :partial => "layouts/notice", :locals => {:msg => 'File could not be added: The processing is not complete.'}
          data = {:notice => partial, :status => 422}
          render :json => data.to_json
        }
      end
    end

  end

  def add_all
    session[:return_to]= request.referer
    if params[:related]
      data_file = DataFile.find(params[:related])
      ids = [data_file.id] + data_file.parent_ids + data_file.child_ids
      to_add = DataFile.scoped.completed_items.where(id: ids) - cart_items
      unadded_items_count = DataFile.where(id: ids).count_unadded_items.count
    else
      search = DataFileSearch.new(session[:search])
      to_add = search.do_search(DataFile.scoped.completed_items) - cart_items
      unadded_items_count = DataFile.count_unadded_items.count
    end
    added_items_count = to_add.count

    if added_items_count > 0
      user_id = current_user.id
      values = to_add.collect(&:id).map {|data_file_id| "(#{data_file_id},#{user_id})"}.join(",")
      # by default, ActiveRecord generates a query for each data_file_id inserted, which is inefficient.
      ActiveRecord::Base.connection.execute("INSERT INTO data_files_users (data_file_id, user_id) VALUES #{values}")
    end

    respond_to do |format|
      if unadded_items_count > 0
        format.html {redirect_to session[:return_to] || data_files_path,
                                 notice: "#{added_items_count} files were added to your cart. #{unadded_items_count} items were not added due to problems." }
      else
        format.html {redirect_to session[:return_to] || data_files_path, notice: "#{added_items_count} files were added to your cart." }
      end
    end
  end

  def add_recent
    session[:return_to]= request.referer
    to_add = DataFile.most_recent_first_and_completed_items.limit(5) - cart_items
    added_items_count = to_add.count

    if added_items_count > 0
      user_id = current_user.id
      values = to_add.collect(&:id).map {|data_file_id| "(#{data_file_id},#{user_id})"}.join(",")
      ActiveRecord::Base.connection.execute("INSERT INTO data_files_users (data_file_id, user_id) VALUES #{values}")
    end

    respond_to do |format|
      format.html {redirect_to session[:return_to] || data_files_path, notice: "#{added_items_count} files were added to your cart." }
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
