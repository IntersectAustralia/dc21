class ForCodesController < ApplicationController

  respond_to :json

  def second_level
    top_level = params[:top_level]
    respond_with(ForCodesLookup.get_instance.second_level_codes(top_level))
  end

  def third_level
    second_level = params[:second_level]
    respond_with(ForCodesLookup.get_instance.third_level_codes(second_level))
  end
end
