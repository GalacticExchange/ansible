
namespace :provision do

  desc 'add application'
  task :clean_test_containers do

    on roles(:master) do
      execute('/mount/vagrant/master/cleantestcontainers.sh')
    end

  end


end