using Toybox.WatchUi;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Sensor;
using Toybox.Application;
using Toybox.Application.Properties as Properties;

class x8View extends WatchUi.View {

	public static var appTitle = Application.getApp().getProperty("app_title");
    
    public static var page0Top = "остановлен";
    public static var page12more = 0;
    
    function initialize() {    	
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() 
    {
    }

    // Update the view
    function onUpdate(dc) {   
    	var mTop = appTitle;
        var pageTop = page0Top;
        
        var pageMiddle = "всего отчетов";
        var pageBottom = "";                  
        
        if(page12more == 0)
        {
        	if(x8App.x8Mc.LAST_OK_CN == 0)
        	{
        		pageMiddle = "последний был в";
        		if(Application.getApp().getProperty("last_ok") == null) {
        			pageMiddle = "последнего отчета";
        		}
        	} else {
        		pageMiddle = "последний отчет";
        	}    
        	pageBottom = x8App.x8Mc.LAST_OK_DT;    		
        }
        else if(page12more == 1)
        {
        	pageMiddle = "всего отчетов";
        	if(x8App.x8Mc.LAST_OK_CN == 0) {
        		pageBottom = "нет";
        	} else {
        		pageBottom = x8App.x8Mc.LAST_OK_CN;
        	}
        }      	
        else if(page12more == 2)
       	{
       		pageMiddle = "текущее время";
       		var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
       		pageBottom = Lang.format("$1$:$2$:$3$",[today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]);
       	}
       	else if(page12more == 3) // geo
       	{
       		var myPoc = Position.getInfo().position;
    		var myLoc = myPoc.toDegrees();
    		myLoc = [ConvertDegrees(myLoc[0],x8Delegate.geoFormatNum),ConvertDegrees(myLoc[1],x8Delegate.geoFormatNum)];
    	
        	pageMiddle = "Ш: " + myLoc[0];
        	pageBottom = "Д: " + myLoc[1];
        }
        else if(page12more == 4)
        {      
        	pageMiddle = "скорость";
        	pageBottom = (Position.getInfo().speed * 3.6).format("%01d") + " км/ч";	
        }
        else if(page12more == 5)
        {
        	pageMiddle = "скорость";
        	pageBottom = Position.getInfo().speed.format("%01d") + " м/с";
        }
        else if(page12more == 6)
        {
        	pageMiddle = "заряд батареи";
        	pageBottom = System.getSystemStats().battery.format("%02d")+"%";
        }
        else if(page12more == 7)
        {
        	pageMiddle = "пульс";     						
			pageBottom = x8Main.string_HR + " уд/м";
        }
        else if(page12more == 8)
        {
        	pageMiddle = "шаги";
        	pageBottom = ActivityMonitor.getInfo().steps;
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
	}
}
