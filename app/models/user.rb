class User

    include MongoMapper::Document
    include ActiveModel::SecurePassword

    attr_accessible :email, :password, :password_confirmation, :timezone

    key :email,           String
    key :role,            String
    key :password_digest, String

    key :timezone,        String

    timestamps!

    validates :email,     :presence => true, :length => { :minimum => 6 }, :uniqueness => true

    validates_inclusion_of :timezone, in: ActiveSupport::TimeZone.zones_map(&:name)

    has_secure_password

end