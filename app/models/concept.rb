# encoding: utf-8
#
# == Schema Information
#
# Table name: concepts
#
#  id              :integer         not null, primary key
#  base_form       :string(255)     not null
#  cls_ids         :string(255)
#  strength_id     :integer
#  created_at      :datetime
#  updated_at      :datetime
#  kind_id         :integer
#  status_id       :integer
#  description     :string(255)
#  lexeme_id       :integer
#  cyc_symbol_id   :integer
#  mapping_type_id :integer
#  matched         :string(255)
#  translation     :string(255)


class Concept < ActiveRecord::Base
  paginates_per 20
  STOP_WORDS = %w{the on of in at for a an with to}

  has_many :spellings, :order => "position", :dependent => :destroy,
    :before_add => Proc.new {|c,s| s.position = c.next_spelling_position},
    :after_add => :update_spellings_count, :after_remove => :update_spellings_count
  has_many :segments, :through => :spellings

  has_many :parentships, :foreign_key => "parent_id", :dependent => :destroy
  has_many :childships, :foreign_key => "child_id", :table_name => "parentships",
    :class_name => "Parentship", :dependent => :destroy
  has_many :children, :through => :parentships
  has_many :parents, :through => :childships

  has_and_belongs_to_many :super_types

  has_many :synonyms

  attr_accessible :name

  symbolize :status, :in => [:new, :accepted, :deleted]

  validates_presence_of :name

  before_destroy {|concept|
    raise "This concept cannot be destroyed!" unless concept.destroyable?
  }

  #after_save :match_names_and_ids
  after_save :update_spelling

  def <=>(other)
   self.name <=> other.name
  end

  def to_s
    "Concept #{self.id} #{self.name}"
  end

  def all_parents
    result = self.parents.to_a
    self.parents.map{|p| p.all_parents}.flatten.compact.uniq
  end

  def umbel_types
    if self.super_types.empty?
      all_parents.map{|p| p.super_types}.flatten.compact.uniq
    else
      self.super_types
    end
  end

  # The parents of the concept which are clarifying collections.
  # (see #$ClarifyingCollectionType)
  def clarifying_parents(level=0)
    self.parents.map{|p| p.clarifying_parents(level)}.flatten.compact.uniq
  end

  # The parents of the concept which appear as argument constraints (isa or genl)
  # in some relations. (see #$argIsa, #$argGenl)
  def argument_parents
    self.all_parents.select{|p| p.isa_argument? || p.genl_argument?}
  end

  def semantic_categories
    concepts_map = {}
    self.spellings.reject{|s| s.status == :merged}.
      map{|s| s.segments.to_a}.flatten.compact.
      each{|s| s.lexeme.concepts.each{|c| concepts_map[c] = true}}
    concepts_map.each_key.
      reject{|c| c.kind_of?(CycConcept) || self == c || c.parents_count > 0}.
      reject{|c| c.children_count <= 1 && concepts_map.keys.size > 25}.
      #reject{|e| self.rank(e) < 0.1}.
      sort{|e1,e2| self.rank(e2) <=> self.rank(e1)}
  end

  def merge_synonym(synonym)
    raise "Cannot marge with self!" if synonym == self
    self.transaction do
      synonym.parentships.each do |parentship|
        next if parentship.child == self
        parentship.parent = self
        parentship.status = :added
        parentship.save!
      end
      next_position = self.next_spelling_position
      synonym.spellings.each do |spelling|
        spelling.concept = self
        spelling.position = next_position
        next_position += 1
        spelling.status = :merged
        spelling.save!
      end
      update_counters
      Concept.find(synonym.id).destroy
    end
  end

  def merge_child(child)
    raise "Cannot marge with self!" if child == self
    self.transaction do
      parentship = Parentship.new(:parent => self, :child => child, :status => :added)
      parentship.save
      update_counters
      child.update_counters
    end
  end

  def remove_child(child)
    self.transaction do
      self.parentships.to_a.find{|p| p.child == child}.destroy
      update_counters
      child.update_counters
    end
  end

  def next_spelling_position
    self.spellings.
      inject(0){|max,e| (e.position ||0) >= max ? (e.position || 0)+1 : max}
  end

  def rank(other)
    @ranks ||= {}
    if @ranks[other].nil?
      self_count = self.lexemes.size.to_f
      other_count = other.lexemes.size.to_f
      common_lexemes = self.lexemes & other.lexemes
      #lexemes_rank = (other.lexemes-common_lexemes).inject(1){|p,l| p * l.rank[0]}
      @ranks[other] = (common_lexemes.size/self_count)*
        (common_lexemes.size/other_count)*
        other.children_count
    end
    @ranks[other]
  end

  def spelling
    self.spellings.first
  end

  def lexemes
    @lexemes ||= self.segments.map{|s| s.lexeme}.uniq
  end

  # Sets the spelling of the concept. Assumes that
  # the spelling is one lexeme in base form.
  def lexeme=(lexeme)
    self.transaction do
      self.spellings.clear
      spelling = self.spellings.create(:lexeme_id => lexeme.id, :position => 0,
                              :tags => lexeme.base_form_tags)
      raise ActiveRecord::RecordNotSaved.new if spelling.new_record?
    end
  end

  def accept
    update_attribute(:status,:accepted)
  end

  def cancel
    update_attribute(:status,:new)
  end

  def delete
    uptade_attribute(:status,:deleted)
  end

  def destroyable?
    not self.kind_of?(CycConcept)
  end

  def update_counters
    self.instances_count = get_instances_count
    self.save(:validate => false)
  end

  def set_new_spelling(expression, index=0)
    @new_spelling = expression
    @spelling_index = index
  end

protected

  def get_current_spelling_index
    @spelling_index || 0
  end

  def get_instances_count
    0
  end

  def kind_of_description(hyponym,hyperonym)
    return nil if hyponym.spelling.blank? || hyperonym.spelling.blank?
    upcased_spelling = hyponym.spelling.to_s[0].upcase +
      hyponym.spelling.to_s[1..-1]
    head = hyponym.spellings.first.head
    predicate_form = "is" # inflect the verb for number
    inflected_spelling = hyperonym.spellings.first.segments.map do |segment|
      # XXX provisional implementation
      segment.value = segment.value + ":inflect" if segment.nominal?
      segment.value
    end.join(" ")
    [ {:text => upcased_spelling, :object => hyponym},
      {:text => " #{predicate_form} a kind of "},
      {:text => inflected_spelling + ".", :object => hyperonym}
    ]
  end

  def update_spelling
    if @spelling.nil?
      return true if @new_spelling.blank?
      # select only these spellings, which has the same order of
      # words as the original expression
      spelling = Spelling.new(:name => @new_spelling,
                              :position => current_spelling_index,
                              :concept_id => self.id)
      spelling.save
    else
      spelling = self.spellings[current_spelling_index]
      if spelling.nil?
        spelling = Spelling.new(:index => current_spelling_index, :concept_id => self.id)
      end
      spelling.intepretation = @spelling
      spelling.save
    end
  end

  def update_spellings_count(spelling)
    self.update_attribute(:spellings_count,self.spellings.count)
  end

end

