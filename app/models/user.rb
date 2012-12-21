class User

    include MongoMapper::Document

    attr_accessible :username, :email, :password, :password_confirmation
    attr_accessor   :password, :password_confirmation

    key :username,      String
    key :email,         String

    key :roles,         Array, :default => [ "user" ]


    key :password_hash, String
    key :password_salt, String

    timestamps!

    validates :username,  :presence => true, :length => { :minimum => 4 }, :uniqueness => true
    validates :email,     :presence => true, :length => { :minimum => 6 }, :uniqueness => true
    validates :name_first,:presence => true, :length => { :minimum => 2 }
    validates :name_last, :presence => true, :length => { :minimum => 2 }

    before_save :encrypt_password

    def self.authenticate? username, password
        user = self.find_by_username( username )

        return user if Digest::SHA256.hexdigest( password + user.password_salt ) == user.password_hash

        return nil
    end

    private

    def encrypt_password
        if not password.nil?
            self.password_salt = (0...8).map{ ('a'..'z').to_a[rand(26)] }.join
            self.password_hash = Digest::SHA256.hexdigest( password + password_salt )
        end
    end

end