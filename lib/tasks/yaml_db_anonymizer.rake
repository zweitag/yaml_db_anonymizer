namespace :db do
  namespace :data do
    desc 'Dump anonymized database contents to db/data.yml'
    task :dump_anonymized => :environment do
      format_class = ENV['class'] || "YamlDb::Anonymizer::Helper"
      require format_class.split('::').first.underscore
      helper = format_class.constantize
      SerializationHelper::Base.new(helper).dump File.join(Rails.root, 'db', "data.#{helper.extension}")
    end
  end
end
