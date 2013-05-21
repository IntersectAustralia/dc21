class ForCodesController < ApplicationController

  respond_to :json

  def top_level
    if MintServerStatus.server_up?
      respond_with(ForCodesLookup.get_instance.top_level_codes)
    else
      render json: {:error => "404"}, status: 404
    end
  end

  def second_level
    if MintServerStatus.server_up?
      top_level = params[:top_level]
      respond_with(ForCodesLookup.get_instance.second_level_codes(top_level))
    else
      render json: {:error => "404"}, status: 404
    end
  end

  def third_level
    if MintServerStatus.server_up?
      second_level = params[:second_level]
      respond_with(ForCodesLookup.get_instance.third_level_codes(second_level))
    else
      render json: {:error => "404"}, status: 404
    end
  end

  def server_status
    if MintServerStatus.server_up?
      render :text => "200"
    else
      render :text => "404"
    end
  end

end
