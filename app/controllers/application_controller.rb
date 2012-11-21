class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :authenticate_user!
  layout :configure_layout

  protected
  # If the cyc symbol with given name (stored in +params[:id]+)
  # is in the DB, the persistated object
  # is returned. If not - temporary object is created.
  def get_cyc_symbol(name=params[:id])
    CycConcept.find_by_name(name) || CycConcept.new(:name => name)
  end

  def configure_layout
    if devise_controller?
      "main"
    end
  end
end
