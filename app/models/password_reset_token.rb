class PasswordResetToken
  include MongoMapper::EmbeddedDocument

  key :token,   String
  key :expires, Time

end
