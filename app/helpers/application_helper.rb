# encoding: utf-8
# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def accept_button
    tag(:input,{:type => "image", :src => image_path("accept.png")})
  end

  def default_remote_options
    url_options = {}
    url_options[:id] = escape_query(params[:id])
    url_options[:model] = params[:model]
    url_options[:engine] = params[:engine]
    url_options[:relata] = params[:relata]
    url_options[:category] = params[:category]
    url_options[:order] = params[:order]
    url_options[:filter] = params[:filter]
    url_options[:letter] = params[:letter]
    url_options
  end

  def form_for_page(update,&block)
    form_tag(default_remote_options, :"data-update" => update,
      :method => :get, :html => {:class => "page_form"},&block)
  end

  def link_to_category(category, update)
    if category.id == params[:category].to_i
      '<span class="selected">' + category.name[0..3] + '</span>'
    else
      link_to(category.name[0..3],
        :url => default_remote_options.merge({:category => category.id}),
        :"data-update" => update, :method => :get, :remote => true)
    end
  end

  def show_link?(navigation, index)
    (navigation.page - index - 1) ** 2 <= 7**2 || index == 0 ||
      index == navigation.page_count - 1
  end

  def escape_query(query)
    query && query.gsub(/\./,"%46")
  end

  def unescape_query(query)
    query && query.gsub(/%46/,".")
  end

  def close()
    raw link_to(image_tag("cancel.png", :title => "zamknij", :class => "close_button"),"#")
  end

  def panel(&block)
    content_tag(:div,
      content_tag(:div, :class => "content", :style => "width:95%", &block) +
      content_tag(:div, close(), :class => "actions") +
      content_tag(:div, tag(:span), :class => "clear") +
      '</div>'.html_safe,:class => "relations")
  end

  ORDERS = {
    "name" => "name",
    "definition" => "definitions_count desc, name",
    "# of subtypes" => "children_count desc, name",
    "# of direct subtypes" => "native_children_count desc, name",
    "# of instances" => "instances_count desc, name"
  }
  def link_to_order(name,update)
    if ORDERS.index(params[:order]) == name
      content_tag(:span,name,:class => "selected")
    else
      type = ORDERS[name]
      link_to name, default_remote_options.merge(:order => type, :action => "index"),
        :method => :get, :remote => true, :"data-update" => update
    end
  end

  FILTERS = {
    /isa/ => "isa_argument",
    /genl/ => "genl_argument",
    /relation/ => "relation_argument",
    /umbel/ => "umbel",
    /none/ => "",
    /\(auto\)/ => "!suggested!",
    /\(potwierdzone\)/ => "!confirmed!",
    /\(wiki\)/ => "!wiki!",
    /niezweryfikowane/ => "fresh",
    /^poprawne/ => "valid",
    /niepoprawne/ => "invalid",
    /problematyczne/ => "other"
  }
  def link_to_filter(name,update,action=nil)
    if name =~ FILTERS.key(params[:filter])
      content_tag(:span,name,:class => "selected")
    else
      type = FILTERS.find{|k,v| name =~ k}[1]
      link_to name, {:filter => type, :action => (action || "index")},
        :method => :get, :remote => true, :"data-update" => update
    end
  end


  def related_id(element,type)
    "#{type}_#{element_id(element)}"
  end

  def element_id(element)
    case element
    when CycConcept
      element_id = element.name
    when String
      element_id = element
    when Fixnum
      element_id = element.to_s
    else
      element_id = element.id
    end
  end

  def related_hook(element, type)
    content_tag(:div, "", :id => related_id(element,type))
  end

  def paginated_list(name,letters=true,&block)
    list_id = name
    result = tag(:div, :id => name).html_safe
    if letters
      result += render(:partial => "shared/letters", :locals => {:update => list_id}).html_safe
    end
    result += render(:partial => "shared/navigation",
                     :locals => {:navigation => eval("@#{name}"), :update => list_id}).html_safe +
                     content_tag(:div,&block) +
                     render(:partial => "shared/navigation",
                            :locals => {:navigation => eval("@#{name}"), :update => list_id}).html_safe
    if letters
      result += render(:partial => "shared/letters", :locals => {:update => list_id}).html_safe
    end
    result += '</div>'.html_safe
  end

  def link_to_letter(letter, update)
    if params[:letter] == letter
      raw '<span class="selected">' + letter + '</span>'
    else
      link_to(letter, default_remote_options.merge({ :letter => letter}), :remote => true,
        :"data-update" => update)
    end
  end

  def polish_letters
    result = (("A".."Z").to_a + %w{Ą Ż Ś Ź Ę Ć Ń Ó Ł}).sort
  end

end
