class UserGroup
  include MongoMapper::Document

  attr_accessible :name, :description

  key :name,        String
  key :description, String

  key :user_ids,    Array

  many :users,     :class_name => "User", :in => :user_ids

  validates :name,     :presence => true, :length => { :minimum => 3 }, :uniqueness => true

  timestamps!

end
