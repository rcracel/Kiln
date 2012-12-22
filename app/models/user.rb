class User

    include MongoMapper::Document
    include ActiveModel::SecurePassword

    attr_accessible :email, :password, :password_confirmation

    key :email,           String
    key :role,            String
    key :password_digest, String

    timestamps!

    validates :email,     :presence => true, :length => { :minimum => 6 }, :uniqueness => true

    has_secure_password

end