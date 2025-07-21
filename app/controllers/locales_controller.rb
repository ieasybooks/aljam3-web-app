class LocalesController < ApplicationController
  def switch
    locale = params[:locale]&.to_sym
    if I18n.available_locales.include?(locale)
      session[:locale] = locale
    end
    
    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_back_or_to(root_path) }
    end
  end
end 