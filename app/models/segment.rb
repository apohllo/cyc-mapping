class Segment < ActiveRecord::Base
  belongs_to :spelling
  belongs_to :lexeme
  has_many :concepts, :through => :spelling
  validates_presence_of :value, :position

  attr_accessible :value, :position, :nominal

  before_validation {|r| r.position = 0 if r.position.nil?}

  def to_s
    "#{self.value}[#{self.nominal ? "*" : "-"}]"
  end

  # XXX provisional implementation
  def inflected
    self.value
  end
end
