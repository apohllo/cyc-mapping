class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable

  attr_protected :admin

  def self.current
    begin
      UserSession.find.record
    rescue
      User.find(:first)
    end
  end

  def modified_elements(from=nil,to=nil)
    dates = []
    [:created_spellings,:created_parentships,:updated_spellings,
      :updated_parentships,:evaluations].each do |type|
      if type == :evaluations
        field = :updated_at
      else
        field = (type.to_s.split("_")[0] + "_at").to_sym
      end
      elements = self.send(type).select(field).order(field)
      if from
        elements = elements.where(["#{field} > ?",from])
      end
      if to
        elements = elements.where(["#{field} < ?",to])
      end
      dates += elements.map{|e| e.send(field)}
    end
    if dates.empty?
      []
    else
      find_continous(dates.compact.sort)
    end
  end

  def reorder_evaluations
    self.evaluations.missing.to_a.shuffle.each.with_index do |evaluation,index|
      evaluation.update_attribute(:position,index)
    end
  end

  protected
  def find_continous(dates)
    first_date = dates.first
    last_date = dates.first
    continous = []
    dates.each do |date|
      if date - last_date > 20.minutes
        continous << ((first_date - 10.minutes)..last_date)
        first_date = date
      end
      last_date = date
    end
    continous << ((first_date - 10.minutes)..dates.last)
    continous
  end
end
