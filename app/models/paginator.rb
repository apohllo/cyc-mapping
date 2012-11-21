module Paginator
  def paginate(per_page=10, conditions=nil, current=1, options = {}) 
    options[:conditions] = conditions 
    options[:page] = {:size => per_page, :current => current}
    #options[:include] = :relations
    find(:all, options)
  end

  def paginate_by_letter(per_page, page, letter, options={},field="name")
    conditions = options.delete(:conditions) || []
    options[:order] ||= field
    if letter
      conditions[0] = " #{field} ILIKE ?"
      conditions <<  letter + '%'
    end
    paginate(per_page,conditions,page,options)
  end

  def paginator(per_page=10, options={})
    Enumerator.new do |yielder|
      #options[:page] = {:size => per_page, :current => 1}
      self.transaction do
        connection = self.connection
        selected_column = "selected_#{5.times.map{|i| rand(i+2).to_s}.join("")}"
        connection.add_column(self.table_name,selected_column.to_sym,:boolean,
                             :default => false)
        conditions = options.delete(:conditions)
        new_conditions = ["#{selected_column} = ?",true]
        if conditions
          self.update_all(new_conditions,conditions)
        else
          self.update_all(new_conditions)
        end
        connection.add_index(self.table_name,selected_column.to_sym)
        options[:conditions] = new_conditions 
        pages = (self.count(:conditions => new_conditions) / per_page.to_f).ceil
        pages.times do |index|
          c_options = options.dup
          c_options[:offset] = per_page * index
          c_options[:limit] = per_page
          self.find(:all, c_options).each do|object|
            yielder.yield(object)
          end
        end
        connection.remove_column(self.table_name,selected_column.to_sym)
      end
    end
  end
end
