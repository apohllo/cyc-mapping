# encoding: utf-8
# == Schema Information
#
# Table name: concepts
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  ignored         :string(255)     default("")
#  concept_id      :integer
#  kind_id         :integer
#  external        :string(255)
#  english_mapping :string(255)


class CycConcept < Concept
  OPENCYC_ID = /\/([^\/]*)\Z/

  attr_writer :translation, :spelling
  serialize :ignored

  class Kind
    include Enum
    enums :collection, :individual, :relation, :nart
  end
  Kind.accessors

  def self.ignored?(name,origin)
    symbol = CycConcept.find_by_name(name)
    return false if symbol.nil?
    return false if symbol.ignored.nil?
    symbol.ignored.include? origin
  end

  def to_cyc
    self.to_sym.to_cyc
  end

  def to_sym
    case self.name
    when /^NART/
      eval(self.name[self.name.index("[")..-1])
    when /^\[/
      eval(self.name)
    else
      self.name.to_sym
    end
  end

  def wiki_links
    self.mappings.map{|e| e.mappable}
  end

  # Returns mapping to English expression.
  #
  # If the mapping is not stated in the Cyc ontology
  # then the name of the symbol itself is splitted
  # into segments and returned.
  def english_mappings
    return @mappings unless @mappings.nil?
    first = english_mapping
    if cyc.cyc_opencyc_feature
      rest = cyc.symbol_strs(self.to_sym)
    else
      rest = cyc.all_phrases_for_term(self.to_sym)
    end
    @mappings =
      if first
        if rest
          [first] + rest
        else
          [first]
        end
      else
        rest || [self.as_english_word]
      end
  end

  def update_english_mapping
    self.english_mapping = self.english_mapping(true).first
    self.save(:validate => false)
  end

  def update_counters
    self.native_parents_count = internal_parents_count().to_i
    self.native_children_count = internal_children_count().to_i
    super
  end

  # Takse the mapping from DB or from Cyc server
  # directly if +force+ is set to true.
  def english_mapping(force=false)
    if force
      cyc.cycl_term_to_nl_string(self.to_sym)
    else
      super()
    end
  end


  # Returns the CYC comment assigned to the symbol.
  def comment
    cyc.comment(self.to_sym)
  end

  # The translations transformed into string
  def translation
    if self.spellings.first
      self.spellings.first.name
    else
      ""
    end
  end

  def raw_translation
    @translation
  end

  def children
    regular = super.to_a
    (regular + native_children.reject{|c| c.new_record?}).uniq
  end

  def parents
    if self.name == "HomoSapiens"
      [:HomoGenus, :IntelligentAgent, :MorallyFalible].
        map{|s| wrap_symbol(s)}
    else
      regular = super.to_a
      (regular + native_parents.reject{|c| c.new_record?}).uniq
    end
  end

  def all_parents
    get_related(:all_genls)
  end

  def all_children
    get_related(:all_specs)
  end

  def individual?
    cyc.isa?(self.to_sym,:Individual)
  end

  def collection?
    cyc.isa?(self.to_sym,:Collection)
  end

  def relation?
    cyc.isa?(self.to_sym,:Relation)
  end

  def instances
    if self.collection?
      get_related(:max_instances)
    else
      result = {}
      self.assertions.each{|a| a.formula[1..-1].each{|s| result[s] = true}}
      result.keys.map{|s| wrap_symbol(s)}.sort_by{|c| c.name}
    end
  end

  def type_relation?
    raise "Not a relation" unless self.relation?
    self.name.match(/type/i) && true || false
  end

  def all_instances
    get_related(:all_instances)
  end

  def self.count_translated
    Translation.count_by_sql("select count(distinct cyc_symbol_id) from translations")
  end

  def self.count_mapped
    Mapping.count_by_sql("select count(distinct cyc_symbol_id) from mappings")
  end

  def to_s
    "\#\$#{self.name}:#{self.id}"
  end

  def native_parents
    get_related(:min_genls)
  end

  def native_children
    get_related(:max_specs)
  end

  def native_kinds
    get_related(:min_isa)
  end

  def parent_descriptions
    if self.translation.blank?
      []
    else
      selected_parents = self.all_parents.
        reject{|p| p.translation.blank? || p == self || p.abstract? }
      near_parents = []
      selected_parents.each do |p1|
        unless selected_parents.any?{|p2| p1 != p2 &&
          cyc.with_any_mt{|cyc| cyc.genls?(p2.to_sym,p1.to_sym)}}
          near_parents << p1
        end
      end
      near_parents.map do |parent|
        kind_of_description(self,parent)
      end.compact
    end
  end

  def child_descriptions
    if self.translation.blank?
      []
    else
      (self.native_children.reject{|c| c.translation.blank? || c == self } +
        self.children).map do |child|
        kind_of_description(child,self)
      end.compact
    end
  end

  def disjoint?(concept)
    if concept.is_a?(CycConcept)
      cyc.with_any_mt do |cyc|
        cyc.collections_disjoint?(self.to_sym,concept.to_sym)
      end && true || false
    else
      false
    end
  end

  def self.search(name)
    if name
      where("name like ?",name + "%")
    else
      scoped
    end
  end

  def self.find_by_opencyc_uri(uri)
    find_by_opencyc_id(uri.match(OPENCYC_ID)[1])
  end

  def self.find_by_opencyc_id(id)
    wrap_symbol(CYC.find_cycl_object_by_compact_hl_external_id_string(id))
  end

  def self.find_all_by_english_name(name)
    result = CYC.denotation_mapper(name)
    unless result.nil?
      result = result.map{|r| r.last}
    end
    #logger.info(result)
    (result || []).map{|e| wrap_symbol(e)}
  end

  def self.male
    @male_concept ||= wrap_symbol(:MaleHuman)
  end

  def self.female
    @female_concept ||= wrap_symbol(:FemaleHuman)
  end

  def self.count_covered
    queue = self.find(:all)
    visited = {}
    count_all = 0
    count_cyc = 0
    count_mapped = 0
    while(concept = queue.shift) do
      next if concept.spellings.count == 0
      visited[concept] = true
      non_leafs = concept.children(:conditions => ["children_count > 0"])
      non_leafs.each{|c| queue << c unless visited[c]}
      count_all += concept.children_count - non_leafs.size + 1
      if concept.is_a?(CycConcept)
        count_cyc += 1
        if concept.children_count > 0
          count_mapped += 1
        end
      end
    end
    [count_all,count_cyc,count_mapped]
  end

  def self.fetch_concept(name)
    wrap_symbol(name)
  end

  def ==(other)
    if self.new_record? || other.new_record?
      self.class == other.class && self.name == other.name
    else
      super(other)
    end
  end

  protected

  def get_instances_count
    internal_instances_count
  end

  def internal_parents_count
    related_count(:min_genls)
  end

  def internal_children_count
    related_count(:max_specs)
  end

  def internal_instances_count
    related_count(:max_instances)
  end

  # Apply uniq on array of +sorted+ elements preserving their order.
  # TODO move somewhere else, not optimized in any way
  def preserving_uniq(sorted)
    result = []
    elements = sorted.uniq
    sorted.each do |element|
      if elements.include?(element)
        result << element
        elements.delete(element)
      end
    end
    result
  end

  # Returns the number of related symbols
  def related_count(type)
    cyc.talk("(length (#{type.to_s.gsub("_","-")} #{self.to_cyc}))").to_i
  end

  # Returns related cyc symbols and maps them to CycConcept class
  def get_related(type)
    (cyc.with_any_mt{|cyc| cyc.send("#{type}", self.to_sym)}||[]).
      map{|s| wrap_symbol(s) }
  end

  def wrap_symbol(symbol)
    self.class.wrap_symbol(symbol)
  end

  def self.wrap_symbol(symbol)
    CycConcept.find_by_name(symbol.to_s) || CycConcept.new(:name => symbol.to_s)
  end

  # Changes the symbol name into string of English words.
  def as_english_word
    self.name.gsub(/\W/," ").gsub(/([a-z])([A-Z])/,"\\1 \\2").
      squeeze(" ").strip.downcase
  end

  # Returns the cyc connection object.
  def cyc
    CYC
  end
end

