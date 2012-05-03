module UsersHelper              
  
  def gravatar_for(user, options = { :size => 50 })
    #if(user.fb_user_id.nil?)
     gravatar_image_tag(user.email.downcase, :alt => user.name, 
                                             :class => "gravatar",
                                             :gravatar => options)
    #else
      
    #end
  end
  
end
