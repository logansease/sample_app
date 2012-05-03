	//Fb_init();
    function Fb_Login() {
		FB.login(function(response) {  
  			if (response.authResponse) {  
  				    			
      			method ="post"; // Set method to post by default, if not specified.
				path ="/sessions/fb_signin";
				
   				 // The rest of this code assumes you are not using a library.
  				  // It can be made less wordy if you use one.
    			var form = document.createElement("form");
    			form.setAttribute("method", method);
   				form.setAttribute("action", path);

   			     var hiddenField = document.createElement("input");
       				 hiddenField.setAttribute("type", "hidden");
       				 hiddenField.setAttribute("name", "fb_id");
       				 hiddenField.setAttribute("value", response.authResponse.userID);
       				 form.appendChild(hiddenField);
       				 
       			var hiddenField2 = document.createElement("input");
       				 hiddenField2.setAttribute("type", "hidden");
       				 hiddenField2.setAttribute("name", "access_token");
       				 hiddenField2.setAttribute("value", response.authResponse.accessToken);
       				 form.appendChild(hiddenField2);
   			
    			document.body.appendChild(form);
    			form.submit();
   		 
  			} else {  
   		 		console.log('User cancelled login or did not fully authorize.');  
  			}  
			}, {scope: 'email'}); 
    	}
    	
function Fb_init()
{
	
	window.fbAsyncInit = function() {
    FB.init({
      appId      : '179989805389930', // App ID
      channelUrl : '//localhost:3000/public/channel.html', // Channel File
      status     : true, // check login status
      cookie     : true, // enable cookies to allow the server to access the session
      xfbml      : true  // parse XFBML
    });

    // Additional initialization code here
  };

  // Load the SDK Asynchronously
  (function(d){
     var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
     js = d.createElement('script'); js.id = id; js.async = true;
     js.src = "//connect.facebook.net/en_US/all.js";
     d.getElementsByTagName('head')[0].appendChild(js);
   }(document));
	
}
