# config/initializers/load_config.rb
APP_CONFIG = YAML.load_file("#{Rails.root}/config/kiln.yml")[Rails.env]

kiln_override_file = Pathname.new( File.join( File.expand_path("~"), "kiln.yml" ) )
if kiln_override_file.file?
    puts "Merging Kiln configuration file #{kiln_override_file}"
    APP_CONFIG.merge! YAML.load( kiln_override_file.read )
end

# optional external configuration file path:
config = {}

db_config_defaults_file = Rails.root.join('config/kiln_mongo.yml')
if db_config_defaults_file.file?
    puts "Merging DB configuration file #{db_config_defaults_file}"
    config.merge! YAML.load( db_config_defaults_file.read )
end

db_config_override_file = Rails.root.join('config/overrides/mongo.yml')
if db_config_override_file.file?
    puts "Merging DB configuration file #{db_config_override_file}"
    config.merge! YAML.load( db_config_override_file.read )
end

db_config_local_file = Pathname.new( File.join( File.expand_path("~"), "kiln_mongo.yml" ) )
if db_config_local_file.file?
    puts "Merging DB configuration file #{db_config_local_file}"
    config.merge! YAML.load( db_config_local_file.read )
end

begin
    MongoMapper.setup( config, Rails.env, :logger => Rails.logger ) unless config.empty?    
rescue
    puts "Could not initalize mongo connection"
end