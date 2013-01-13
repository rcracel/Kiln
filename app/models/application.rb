require "uuidtools"

class Application
    include MongoMapper::Document

    attr_accessible :name, :description

    key :name,                  String
    key :api_key,               String
    key :description,           String
    key :authorized_user_ids,   Array
    key :authorized_group_ids,  Array

    belongs_to :owner,          :class_name => "User"

    many :authorized_users,     :class_name => "User", :in => :authorized_user_ids
    many :authorized_groups,    :class_name => "UserGroup", :in => :authorized_group_ids

    validates :name,     :presence => true, :length => { :minimum => 3 }
    validates :owner,    :presence => true

    timestamps!

    before_create :generate_key

    def self.visible_by_user( user )
        if user.roles.include? :admin
            self.where
        else
            conditions = []

            # Search by owner and authorized users
            conditions << { :owner => user.id }
            conditions << { :authorized_users_ids => user.id }

            # If the user matched any authorized groups, add them to the query
            groups_for_user = UserGroup.where( { :user_ids => user.id } ).fields( :id ).collect { |g| g.id }
            conditions << { :authorized_group_ids => { :$in => groups_for_user } } unless groups_for_user.empty?

            self.where( { :$or => conditions } )
        end
    end

    def user_count
        count = authorized_users.length

        authorized_groups.each do |group|
            count += group.users.length
        end

        return count
    end

    def authorized?( user )
        authorized = user.roles.include? :admin

        authorized |= owner == user
        authorized |= authorized_users.include?( user )
        authorized |= ((authorized_groups.detect { |g| g.users.include? user }) != nil)

        authorized
    end

private

    def generate_key
        self.api_key = UUIDTools::UUID.random_create.to_s
    end

end
