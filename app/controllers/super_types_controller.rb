class SuperTypesController < ApplicationController
  layout "main", :only => [:show, :index]

  def index
    @types = SuperType.order(:name).all
  end

  def show
    @type = SuperType.find(params[:id])
    @symbols = @type.concepts.order(:name).page(params[:page])
    @symbols = @symbols.where(["name ilike ?",params[:letter]+"%"]) if params[:letter]
    if request.xhr?
      render :partial => "show"
    end
  end

  def stats
    @type = SuperType.find(params[:id])
    @total = @type.concepts.count
    @mapped = @type.concepts.where("spellings_count is not null and spellings_count > 0").
      count
    render :text => "#{@mapped}/#{@total}"
  end

end
