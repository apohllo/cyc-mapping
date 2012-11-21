module CycConceptsHelper
  def link_to_rest(symbol)
    if symbol.english_mappings.size > 4
      link_to("...", {:action => "translations_rest", :id => symbol},
              :"data-update" => translations_rest_id(symbol), :remote => true)
    end
  end

  def link_to_create_translation(symbol, index, value)
    link_to(image_tag("add.png"), concept_spellings_path(symbol,Spelling.new(:name => value)),
            :remote => true, :method => :post)
  end

  def link_to_spelling(symbol)
    link_to((symbol.spellings.first.try(:name) || image_tag("add.png")),
      concepts_spelling_path(symbol), :remote => true,
      :"data-update" => related_id(symbol,"spellings"), :method => :get)
  end

  def translations_rest_id(symbol)
    "translations_rest_#{symbol.name}"
  end

  def translation_id(symbol)
    "translation_#{symbol.name}"
  end

  def symbol_id(symbol)
    symbol = symbol.name if symbol.is_a?(CycConcept)
    "symbol_#{symbol}"
  end

  def bigrams_id(symbol, index)
    "bigrams_#{symbol.name}_#{index}"
  end

  def concept_id(concept)
    element_id(concept)
  end

  def make_symbol_receiving(symbol)
    drop_receiving_element symbol_id(symbol),
      :url => {:action => "handle_wiki_link", :symbol_id => symbol.id},
      :hoverclass=> "highlighted", :update => "symbol_#{symbol.id}",
      :accept => "wiki"
  end

protected

  def related_button(symbol, type, title,controller="cyc_concepts")
    link_to(title, {:action => type,
       :controller => controller, :id => concept_id(symbol) },
       :"data-update" => related_id(symbol,type), :remote => true)
  end

end
