# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class User
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Product.
  # enable :sync
  property :login, :string
  property :api_key, :string
  
  def self.logged_in
    if User.find(:all).count == 0
      return false
    else
      return true
    end
  end
end
