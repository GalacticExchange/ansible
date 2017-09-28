
module CleanHelper

  def safe_execute
    begin
      yield
    rescue Exception => e
      puts "Excpetion handled: #{e}"
    end
  end

  def self.safe_execute
    begin
      yield
    rescue Exception => e
      puts "Excpetion handled: #{e}"
    end
  end

end