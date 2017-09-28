

=begin
Dir[Rails.root.join("app/workflows/**/*.rb")].each do |file|
  require file
end
=end



# superworker
=begin
Dir['superworkers/*.rb'].each do |f|
  require_relative "../#{f}"
end
=end

