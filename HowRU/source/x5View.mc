using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Sensor;
using Toybox.Application;
using Toybox.Application.Properties as Properties;

class x5View extends WatchUi.View 
{
    public static var appTitle = Application.getApp().getProperty("app_title");
    public static var cfgTitle = Application.getApp().getProperty("cfg_title");
    public static var geoTitle = Application.getApp().getProperty("geo_title");
    public static var disable_page_0 = Application.getApp().getProperty("disable_page_0");
    public static var disable_page_2 = Application.getApp().getProperty("disable_page_2");
    public static var disable_page_3 = Application.getApp().getProperty("disable_page_3");    
    
    public static var page0Top = "остановлен";
    public static var pageActive = 1;
    public static var page12more = 0;
    public static var page3more = 0;
    
    function initialize() 
    {		
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
    	
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    	
    }

    // Update the view
    function onUpdate(dc) {     	  
    	var run = x5App.x5Mc.IsRunning();
        if(run) { run = "включен"; } else { run = "отключен"; }
        var mTop = appTitle;
        var pageTop = "";
        var pageMiddle = "";
        var pageBottom = "";
        
        if(pageActive == 0) // старт/стоп 1
        {
        	pageTop = page0Top;
        	if(x5App.x5Mc.IsRunning())
        	{
        		pageMiddle = "нажмите стоп";
        		pageBottom = "для остановки";        		
        	}
        	else
        	{
        		pageMiddle = "нажмите старт";
        		pageBottom = "для запуска";
        	}
        } 
        
        if(pageActive == 1) // старт/стоп 2
        {
        	pageTop = page0Top;
        	pageMiddle = "всего отчетов";
        	if(x5App.x5Mc.LAST_OK_CN == 0)
        	{
        		pageBottom = "нет";
        	}
        	else
        	{
        		pageBottom = x5App.x5Mc.LAST_OK_CN;
        	}
        }    
        
        if(pageActive == 2) // координаты
        {
        	mTop = geoTitle;
        
        	var myPoc = Position.getInfo().position;
    		var myLoc = myPoc.toDegrees();
    		myLoc = [ConvertDegrees(myLoc[0],x5Delegate.geoFormatNum),ConvertDegrees(myLoc[1],x5Delegate.geoFormatNum)];
    		
        	pageTop = "Ш: " + myLoc[0];
        	pageMiddle = "Д: " + myLoc[1];    	
        }           
        
        if((pageActive == 1) || (pageActive == 2))
        {
        	if(page12more == 0)
        	{
        		if(pageActive == 1)
        		{	
        			if(x5App.x5Mc.LAST_OK_CN == 0)
        			{
        				pageMiddle = "последний был в";
        				if(Application.getApp().getProperty("last_ok") == null)
        				{
        					pageMiddle = "последнего отчета";
        				}
        			}
        			else
        			{
        				pageMiddle = "последний отчет";
        			}        			
        		}    
        		pageBottom = x5App.x5Mc.LAST_OK_DT;    		
        	}
        	else if(page12more == 1)
        	{
        		if(pageActive == 1)
        		{
        			pageMiddle = "всего отчетов";
        		}
        		if(x5App.x5Mc.LAST_OK_CN == 0)
        		{
        			pageBottom = "нет";
        		}
        		else
        		{
        			pageBottom = x5App.x5Mc.LAST_OK_CN;
        		}
        	}
        	else if(page12more == 2)
        	{
        		if(pageActive == 1)
        		{
        			pageMiddle = "текущее время";
        		}
        		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        		pageBottom = Lang.format("$1$:$2$:$3$",[today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]);
        	}
        	else if(page12more == 3)
        	{      
        		if(pageActive == 1)
        		{
        			pageMiddle = "скорость";
        		}
        		pageBottom = (Position.getInfo().speed * 3.6).format("%01d") + " км/ч";	
        	}
        	else if(page12more == 4)
        	{
        		if(pageActive == 1)
        		{
        			pageMiddle = "скорость";
        		}
        		pageBottom = Position.getInfo().speed.format("%01d") + " м/с";
        	}
        	else if(page12more == 5)
        	{
        		if(pageActive == 1)
        		{
        			pageMiddle = "заряд батареи";
        		}
        		pageBottom = System.getSystemStats().battery.format("%02d")+"%";
        	}
        	else if(page12more == 6)
        	{
        		if(pageActive == 1)
        		{
        			pageMiddle = "пульс";
        		}        						
				pageBottom = x5Main.string_HR + " уд/м";
        	}
        	else if(page12more == 7)
        	{
        		if(pageActive == 1)
        		{
        			pageMiddle = "шаги";
        		}
        		pageBottom = ActivityMonitor.getInfo().steps;
        	}
        }
        
        if(pageActive == 3) // info
        {
        	mTop = cfgTitle;
        	     	        	         
        	if(page3more == 0)
        	{
        		pageTop = x5Main.CALL_USER_ID;           		
        		pageMiddle = System.getDeviceSettings().partNumber; 		
        		pageBottom = "тел отклн";
        		if(System.getDeviceSettings().phoneConnected)
        		{
        			pageBottom = "тел подкл";
        		} 
        	}
        	else if(page3more == 1)
        	{
        		mTop = "последний отчет";   
        		pageTop = x5App.x5Mc.LAST_OK_DT;
        		pageMiddle = x5App.x5Mc.LAST_OK_ST;
        		pageBottom = x5App.x5Mc.LAST_OK_CN;         		
        	}
        	else if(page3more == 2)
        	{        		
        		mTop = "последний отклик";   
        		pageTop = x5App.x5Mc.LAST_RES_DT;
        		pageMiddle = x5App.x5Mc.LAST_RES_ST;
        		pageBottom = x5App.x5Mc.LAST_RES_CN;
        	} 
        	else if(page3more == 3)
        	{
        		mTop = "последняя ошибка";   
        		pageTop = x5App.x5Mc.LAST_BAD_DT;
        		pageMiddle = x5App.x5Mc.LAST_BAD_ST;
        		pageBottom = x5App.x5Mc.LAST_BAD_CN;
        	}  
        	else if(page3more == 4)
        	{
        		mTop = "последняя попытка";   
        		pageTop = "интервал " + x5Main.INTERVAL + " с";
        		pageMiddle = x5App.x5Mc.LAST_TRY_DT;
        		pageBottom = x5App.x5Mc.LAST_TRY_CN;
        	}
        } 
        var mMessage = mTop + "\n" + pageTop + "\n" + pageMiddle + "\n"+pageBottom;
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_SMALL, mMessage, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }
    
    function ConvertDegrees(dd,frm)
	{
		if(frm == 0) {
			return dd.format("%1.7f") + "°"; 
		} else {
    		var deg = Math.floor(dd);
	   		var exp = (dd - deg).abs();
	   		var mm = exp * 60;
	   		if(frm == 1) {
				return deg.format("%01d") + "° " + mm.format("%1.4f")+ "\"";
			} else {
				var min = Math.floor(mm);
				exp = (mm - min).abs();
				var ss = exp * 60; 
				if(frm == 2) {
					return deg.format("%01d") + "° " + min.format("%01d")+ "\" " + ss.format("%1.2f")+"'";
				} else
				{
					return deg.format("%01d") + "° " + min.format("%01d")+ "\" " + ss.format("%01d")+"'";
				}
			}
	   	}
	   	//var sec = frac * 3600 - min * 60;
	    //return deg + "d " + min + "' " + sec + "\"";
	}
}