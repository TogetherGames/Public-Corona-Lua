-- config.lua

if system.getInfo("model") == "iPad" then
    application =
    {
    	content =
    	{
    		width = 768,
    		height = 1024,
    		scale = "letterbox"
    	},
		
		notification =
		{
			ipad =
			{
				types =
				{
					"badge", "sound", "alert"
				}
			},
			
			iphone =
        	{
            	types =
           		{
                	"badge", "sound", "alert"
            	}
        	}
		}
    }
else
    application =
    {
        content =
        {
            width = 480,
            height = 720,
            scale = "letterbox"
        },
		
		notification =
		{
			iphone =
			{
				types =
				{
					"badge", "sound", "alert"
				}
			},
			
			ipad =
        	{
            	types =
            	{
                	"badge", "sound", "alert"
            	}
        	}
		}
    }
end
