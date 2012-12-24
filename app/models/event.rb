class Event

  include MongoMapper::Document

    attr_accessible :module_name, :log_level, :message, :thread_name, :stack_trace, :environment_name, :ip_address

    key :module_name,       String
    key :log_level,         String
    key :message,           String
    key :timestamp,         Time
    key :thread_name,       String
    key :stack_trace,       String
    key :environment_name,  String
    key :ip_address,        String

    belongs_to :application

    timestamps!

end
