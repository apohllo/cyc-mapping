# encoding=utf-8

class DictionaryController < ApplicationController
  layout "dictionary", :except => ["index"]

  def index
  end

  # Regular Cyc server
  def cyc
    @word = params[:id]
    if CYC.nil?
      @concepts = [["Error", "Cannot connect to Cyc server"]]
      return
    end
    concepts = CYC.denotation_mapper(@word)
    @concepts = unless concepts.nil?
      concepts.map{|c| get_cyc_symbol(c.last.to_s)}
    else
      :not_found
    end
  end

  def cyc_symbol
    @word = params[:id]
    if CYC.nil?
      @concepts = [["Error", "Cannot connect to Cyc server"]]
      return
    end
    symbols = CYC.find_constant(@word)
    @concepts =
      unless symbols.nil?
        [get_cyc_symbol(symbols.to_s)]
      else
        :not_found
      end
  end

  def search
    @engine = params[:engine]
    unless @engine.blank?
      send(@engine)
      render :action => @engine, :layout => "dictionary"
    end
  end
end
