begin
  require 'cycr'
  CYC = Cyc::Client.new(:host => "localhost", :port => 3601)
#  CYC.debug = true unless CYC.nil?
rescue Errno::ECONNREFUSED
  CYC = Class.new do
    def self.method_missing(*args)
      raise "Cyc connection not established"
    end
  end
  puts("Connection to Cyc server refused")
  puts("Did you enabled TCP communication? (enable-tcp-server :cyc-api 3601)")
end
