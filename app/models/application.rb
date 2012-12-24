require "uuidtools"

class Application
  include MongoMapper::Document

    attr_accessible :name, :description

    key :name,              String
    key :api_key,           String
    key :description,       String

    belongs_to :owner,      :class_name => "User"

    validates :name,     :presence => true, :length => { :minimum => 3 }
    validates :owner,    :presence => true

    timestamps!

    before_create :generate_key

private

    def generate_key
        self.api_key = UUIDTools::UUID.random_create.to_s
    end

end
