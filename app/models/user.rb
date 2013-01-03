class User

    include MongoMapper::Document
    include ActiveModel::SecurePassword

    attr_accessible :email, :password, :password_confirmation, :timezone, :first_name, :last_name

    key :first_name,      String
    key :last_name,       String

    key :email,           String
    key :roles,           Array
    key :password_digest, String

    key :timezone,        String

    timestamps!

    validates :email,     :presence => true, :length => { :minimum => 6 }, :uniqueness => true

    validates_inclusion_of :timezone, in: ActiveSupport::TimeZone.zones_map(&:name), :allow_nil => true

    has_secure_password

    def name
        name = "#{first_name} #{last_name}"
        name.blank? ? nil : name.strip
    end

end