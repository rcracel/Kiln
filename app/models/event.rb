class Event

  include MongoMapper::Document

    attr_accessible :application_name, :log_level, :message, :thread_name, :stack_trace, :environment_name, :ip_address

    key :application_name,  String
    key :log_level,         String
    key :message,           String
    key :timestamp,         Time
    key :thread_name,       String
    key :stack_trace,       String
    key :environment_name,  String
    key :ip_address,        String

    timestamps!

end
