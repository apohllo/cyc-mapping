class Parentship < ActiveRecord::Base
  belongs_to :parent, :class_name => "Concept"
  belongs_to :child, :class_name => "Concept"
  belongs_to :created_by, :class_name => "User"
  belongs_to :updated_by, :class_name => "User"

  validates_presence_of :parent_id, :child_id

  symbolize :status, :in => [:extracted, :suggested, :added]

  before_save :update_user

protected
  def update_user
    if self.created_by.nil?
      self.created_by = User.current
    end
    self.updated_by = User.current
  end

end
