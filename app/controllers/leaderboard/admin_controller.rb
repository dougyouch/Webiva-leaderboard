
class Leaderboard::AdminController < ModuleController

  component_info 'Leaderboard', :description => 'Leaderboard support', 
                              :access => :public
                              
  # Register a handler feature
  register_permission_category :leaderboard, "Leaderboard" ,"Permissions related to Leaderboard"
  
  register_permissions :leaderboard, [ [ :manage, 'Manage Leaderboard', 'Manage Leaderboard' ],
                                  [ :config, 'Configure Leaderboard', 'Configure Leaderboard' ]
                                  ]
  cms_admin_paths "options",
     "Leaderboard Options" => { :action => 'index' },
     "Options" => { :controller => '/options' },
     "Modules" => { :controller => '/modules' }

  permit 'leaderboard_config'

  public 
 
  def options
    cms_page_path ['Options','Modules'],"Leaderboard Options"
    
    @options = self.class.module_options(params[:options])
    
    if request.post? && @options.valid?
      Configuration.set_config_model(@options)
      flash[:notice] = "Updated Leaderboard module options".t 
      redirect_to :controller => '/modules'
      return
    end    
  
  end
  
  def self.module_options(vals=nil)
    Configuration.get_config_model(Options,vals)
  end
  
  class Options < HashModel
   # Options attributes 
   # attributes :attribute_name => value
  
  end

end
