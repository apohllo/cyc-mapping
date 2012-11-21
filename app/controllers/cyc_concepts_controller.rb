#  encoding:utf-8
class CycConceptsController < ApplicationController
  layout "main", :only => [:index, :tree]
  helper :lexemes
  respond_to :html

  def index
    if params[:mappable_id]
      @symbols = Mapping.
        find_all_by_mappable_id(params[:mappable_id], :include => "cyc_symbol").
        map{|m| m.cyc_symbol}
      render :partial => "symbol", :collection => @symbols and return
    else
      page_size = 20
      @symbols = CycConcept.search(params[:letter])
      if params[:filter] && !params[:filter].empty?
        if matched = params[:filter].match(/!(.*)!/)
          spellings = Spelling.where("status = ?",matched[1].to_sym).order("name").
            search(params[:letter]).page(params[:page])
          @symbols = spellings.map{|s| s.concept}
          [:total_pages,:current_page,:previous_page,:next_page].each do |method|
            @symbols.define_singleton_method method do
              spellings.send(method)
            end
          end
          render :action => "index", :layout => false
          return
        else
          @symbols = @symbols.where("#{params[:filter]} = ?",true)
        end
      end
      @symbols = @symbols.order(params[:order] || "name").page(params[:page]).
        includes(:spellings)
    end
    if request.xhr?
      render :action => "index", :layout => false
    end
  end

  def create
    @concept = CycConcept.create(:name => params[:name])
    @concept.update_english_mapping
    @concept.update_counters
    #concept.synonym_id = concept.id
    @concept.save(false)
  end

  def translations
    @symbol = get_cyc_symbol
    # each entry should contain :source and :value
    @translations = []
    @spelling = Spelling.new
    @spelling.concept = @symbol

    # wikipedia translations
    #if @symbol.en_wiki_mapping
    #  @translations << {:source => "wiki #{@symbol.en_wiki_mapping}", :value =>
    #    @symbol.pl_wiki_mapping.downcase}
    #end

    # wikipedia as corpus translations
    wiki_translations = @symbol.wikipedia_translations
    wiki_translations.
      each{|t| @translations << {:source => "wikipedia full", :value => t}}

    # full pwn translations
    (@symbol.full_translations - wiki_translations).
      each{|t| @translations << {:source => "pwn full", :value => t}}

    # simple pwn translations
    @symbol.simple_translations.
      each{|t| @translations << {:source => "pwn", :value => t}}


    unless @translations.find{|t| t[:source] =~ /^pwn/}
      @symbol.single_word_translations.
        each{|t| @translations << {:source => "pwn single", :value => t}}
    end
  end

  def delete_translation
    symbol = CycConcept.find(params[:id])
    symbol.translations.clear
    render(:update) do |page|
      page.replace symbol_id(symbol), :partial => "symbol_content",
        :object => symbol
    end
  end

  def description
    symbol = get_cyc_symbol
    @descriptions = symbol.parent_descriptions
    @descriptions += symbol.child_descriptions
    @descriptions.uniq!
  end

  def cyc_comment
    @comment = get_cyc_symbol.comment
  end

  def cyc_parents
    @symbols = get_cyc_symbol.native_parents
  end

  def cyc_children
    @symbols = get_cyc_symbol.native_children
  end

  def semantic_types
    symbol = get_cyc_symbol
    @types = symbol.umbel_types
  end

  def instances
    @symbols = get_cyc_symbol.instances
  end

  def translations_rest
    render :text => CycConcept.find(params[:id]).
      english_mappings[4..-1].join(", "), :layout => false
  end

  def tree
    @items = CycConcept.roots.sort_by{|e| e.translation}
  end

  def tree_item
    @items = CycConcept.find(params[:id]).
      children.sort_by{|e| e.translation}
  end

end
