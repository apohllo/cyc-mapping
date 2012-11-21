# encoding: utf-8
class Spelling < ActiveRecord::Base
  attr_writer :interpretation
  #extend Paginator

  belongs_to :concept
  belongs_to :created_by, :class_name => "User"
  belongs_to :updated_by, :class_name => "User"
  has_many :segments, :dependent => :destroy, :order => :position
  has_many :lexemes, :through => :segments

  validates_presence_of :concept_id, :position, :status
  after_create :parse_name
  before_save :update_user

  attr_accessible :name, :concept_id

  # added - added by user
  # primary - the primary mapping for given concep (entails valid)
  # valid - verified spelling (might be taken directly from Wikipedia)
  # confirmed - verified in the previous mapping experiment (published IIS 2009)
  # suggested - suggested by the mapping system with strong confidece (published IIS 2009)
  # merged - the spelling is acquired from the merged concept
  # wiki - taken from Wikipedia to Cyc mapping
  STATUS = [:added, :primary, :valid, :confirmed, :suggested, :merged, :wiki]

  symbolize :status

  class Missing < Exception
    def initialize(spelling)
      @spelling = spelling
    end
    def to_s
      "There are no interpretations for spelling '#{@spelling}'"
    end
  end

  class Ambigiuous < StandardError
    attr_reader :spellings

    def initialize(spellings,expression="")
      @spellings = spellings
      @expression = expression
    end

    def to_s
      "There are ambigiuous interpretations for expression #{@expression}"
    end
  end

  def to_s
    self.name
  end

  def name
    name_attr = attributes_before_type_cast["name"]
    if name_attr.blank?
      name_attr = update_name
    end
    if name_attr.blank?
      "[pusty łańcuch]"
    else
      name_attr
    end
  end

  # TODO the head should be determined more precisely.
  def head
    self.segments.to_a.find{|t| t.nominal}
  end

  def inflected
    # XXX provisional implementation
    self.segments.map{|s| s.inflected}.join(" ")
  end

  def ==(other)
    return false unless other.kind_of?(Spelling)
    return false if self.segments.count != other.segments.count
    return true if self.segments.count == 0 and other.segments.count == 0
    # TODO should include the fact that THERE ARE ambigiuous spellings
    self.segments.zip(other.segments) do |segment1,segment2|
      if segment1.lexeme != segment2.lexeme
        return false
      end
      (segment1.tags.keys & segment2.tags.keys).each do |key|
        return false if segment1.tags[key] != segment2.tags[key]
      end
    end
    true
  end

  def clone
    duplicate = super()
    duplicate.segments = self.segments.map{|s| s.clone}
    duplicate
  end

  def self.search(name)
    if name
      where("name like ?",name + "%")
    else
      scoped
    end
  end

protected
  def parse_name
    # TODO here we have to detect nominal segments!
    # this is only provisional implementation
    segments.clear
    self.name.split(" ").each.with_index do |value, index|
      # we assume that the first segment is always nominal
      nominal = (index == 0 ? true : false)
      segment = self.segments.create(:value => value,
                                     :position => index, :nominal => nominal)
      if segment.new_record?
        logger.error("Segment #{segment} not saved: #{segment.errors.full_messages}")
        raise ActiveRecord::RecordNotSaved.new
      end
    end
  end

  def update_name
    name_value = self.segments.to_a.map{|s| s.inflected}.join(" ")
    unless new_record?
      self.update_attribute(:name,name_value) unless name_value.blank?
    end
    name_value
  end

  def update_user
    if self.created_by.nil?
      self.created_by = User.current
    end
    self.updated_by = User.current
  end

end
