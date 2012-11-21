module Enum
  def self.included(base)
    base.send(:extend, ClassMethods)
  end

  module ClassMethods

    include Enumerable

    def self.extended(base)
      class << base
        self.instance_eval do
          attr_accessor :enum_values
        end
      end
    end

    def enums(*values)
      self.enum_values = {}
      values.each_with_index do |v,i|
        self.enum_values[v] = i
      end
    end

    def find(id)
      return nil if id.nil?
      values = self.enum_values
      if id.is_a?(Fixnum)
        values.find{|key,value| value == id}[0] if(id < values.size) || 
          raise("No such #{self.to_s}: #{id.inspect} ")
      else
        values[id] || raise("No such #{self.to_s}: #{id.inspect} ")
      end
    end

    def [](id)
      find(id)
    end

    def to_a
      self.enum_values.to_a.sort{|v1,v2| v1[1] <=> v2[1]}
    end

    def each 
      self.enum_values.each do |key,val|
        yield val
      end
    end

    def accessors
      super_name, self_name = self.to_s.split("::")[-2..-1]
      myself = self
      method_name = self_name.underscore
      super_module = Module.const_get(super_name)
      # getter
      super_module.send(:define_method, method_name) do  
        myself[self.send("#{method_name}_id")]
      end
      # setter
      super_module.send(:define_method, method_name + "=") do |value|
        self.send("#{method_name}_id=", myself[value])
      end
    end

  end
end
