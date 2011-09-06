# The model has already been created by the framework, and extends Rhom::RhomObject
# You can add more methods here
class Tasks
  include Rhom::PropertyBag

  # Uncomment the following line to enable sync with Tasks.
  # enable :sync
  property :id, :integer 
  property :name, :string
  property :icebox, :boolean
  property :complete, :boolean 
  property :updated_at, :string
  property :created_at, :string 
  property :position=, :integer
  property :on_server, :integer
  

  #add model specifc code here
end
