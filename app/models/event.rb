class Event

    include MongoMapper::Document
    
    attr_accessible :module_name, :log_level, :message, :thread_name, :stack_trace, :environment_name, :ip_address, :source

    key :module_name,       String
    key :log_level,         String
    key :message,           String
    key :timestamp,         Time
    key :thread_name,       String
    key :stack_trace,       String
    key :environment_name,  String
    key :ip_address,        String
    key :source,            String

    belongs_to :application

    timestamps!


    def self.module_name_list( application_id )
        options = { }

        options[ :application_id ] = BSON::ObjectId.from_string( application_id ) unless application_id.nil?

        Event.collection.distinct( :module_name, options )
    end

    def self.environment_name_list( application_id, module_name )
        options = { }

        options[ :application_id ] = BSON::ObjectId.from_string( application_id ) unless application_id.nil?
        options[ :module_name    ] = module_name    unless module_name.nil?

        Event.collection.distinct( :environment_name, options )
    end

    def self.log_level_list( application_id, module_name, environment_name )
        options = { }

        options[ :application_id ] = BSON::ObjectId.from_string( application_id ) unless application_id.nil?
        options[ :module_name      ] = module_name      unless module_name.nil?
        options[ :environment_name ] = environment_name unless environment_name.nil?

        Event.collection.distinct( :log_level, options )
    end

    def self.find_for_user( user, options = {} )
        self.all( options )
    end

end
