require "uuidtools"

class Application
    include MongoMapper::Document

    attr_accessible :name, :description

    key :name,                  String
    key :api_key,               String
    key :description,           String
    key :authorized_users_ids,  Array

    belongs_to :owner,          :class_name => "User"

    many :authorized_users,     :class_name => "User", :in => :authorized_users_ids

    validates :name,     :presence => true, :length => { :minimum => 3 }
    validates :owner,    :presence => true

    timestamps!

    before_create :generate_key

    def self.visible_by_user( user )
        condition = {}

        condition[ :$or ] = [ { :owner => user.id }, { :authorized_users_ids => user.id } ] unless user.roles.include? :admin

        self.where( condition )
    end

private

    def generate_key
        self.api_key = UUIDTools::UUID.random_create.to_s
    end

end
