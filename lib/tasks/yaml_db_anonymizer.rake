namespace :db do
  namespace :data do
    desc 'Dump anonymized database contents to db/data.yml'
    task :dump_anonymized => :environment do
      SerializationHelper::Base.new(YamlDb::Anonymizer::Helper).dump File.join(Rails.root, 'db', 'data.yml')
    end
  end
end
