using Toybox.Application;
using Toybox.Communications;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Position;
using Toybox.Sensor;
using Toybox.ActivityMonitor;
using Toybox.Timer;
using Toybox.Ant;

class x5Main 
{	
	public static var AppVersion = "0.0.11";
	public static var CALL_SVC =
	[ 
		"http://127.0.0.1/call_fenix",
		"http://127.0.0.1/oruxpals/m/",
		"http://livegpstracks.com/bbg.php"
	];
	public static var CALL_SERVICE = Application.getApp().getProperty("call_service");
    public static var CALL_APP_ID = Application.getApp().getProperty("appId");
    public static var CALL_USER_ID = Application.getApp().getProperty("user_id");
    public static var CALL_USER_CODE = Application.getApp().getProperty("user_code");
    public static var CALL_USER_MMT = "";
    public static var INTERVAL = Application.getApp().getProperty("update_interval");
    
    private var running = false;
    private var timer =  null;
    private var counter = 0;
    public static var string_HR = "--";
    public static var string_TS = "--";
    public static var string_PS = "--";
    
    public var LAST_TRY_DT = "не было";
    public var LAST_TRY_CN = 0;
    public var LAST_RES_DT = "не было";
    public var LAST_RES_CN = 0;
    public var LAST_RES_ST = "нет статуса";
    public var LAST_BAD_DT = "не было";
    public var LAST_BAD_CN = 0;
    public var LAST_BAD_ST = "нет статуса";
    public var LAST_OK_DT  = "не было";
    public var LAST_OK_CN  = 0;
    public var LAST_OK_ST = "нет статуса";
    
    public function IsRunning() { return running; }
    
    function initialize()
    {
    	CALL_USER_MMT = StringUtil.encodeBase64(CALL_USER_ID + ":" + CALL_USER_CODE);
    	if(x5View.disable_page_0 && x5Delegate.disable_menu_ss)
   		{
   			x5View.page0Top = "всегда остановлен";
   		}
   		else
   		{
    		x5View.page0Top = "остановлен";
    	}
    	
    	Sensor.setEnabledSensors( [Sensor.SENSOR_HEARTRATE] );
    	Sensor.setEnabledSensors( [Sensor.SENSOR_TEMPERATURE] );
    	Sensor.enableSensorEvents( method(:onSensor) );
    
    	timer = new Timer.Timer();
        timer.start(method(:onTimer), 1000, true);
    
    	LoadParams();    	    	             
    }

    public function Once()
    {   	
    	System.println("Send Once");
    	WebCall(0);
    }
    
    public function Start()
    {
    	if(running) {
    		return;
    	 } else {
    		running = true;
    		SaveParams();
    		if(x5View.disable_page_0 && x5Delegate.disable_menu_ss)
    		{
    			x5View.page0Top = "всегда запущен";
    		}
    		else
    		{
    			x5View.page0Top = "запущен";
    		}
    		System.println("Start"); 
         }
    }
    
    public function Stop()
    {
    	if(!running) {
    		return;
    	 } else {
    		running = false;
    		SaveParams();
    		counter = 0;
    		x5View.page0Top = "остановлен";
    		System.println("Stop"); 
         }
    }
    
    public function LoadParams()
    {
    	var isr = Application.getApp().getProperty("running");
    	if(isr == true) 
    	{ 
    		Start();
    	} 
    	else 
    	{ 
    		running = false; 
    	}
    	var last = Application.getApp().getProperty("last_ok");
    	if (last != null)
    	{
    		LAST_OK_DT = last; 
    	}    	
    }
    
    public function SaveParams()
    {
    	Application.getApp().setProperty("running", running);
    	Application.getApp().setProperty("last_ok",  LAST_OK_DT);
    }
    
    function onTimer()
    {
    	WatchUi.requestUpdate();
    	if(!running) 
    	{
    		return;
    	}
    	if((counter == 0) || (counter == INTERVAL))
    	{
    		counter = 0;
    		WebCall(1);
    		Bgrnd();
    	}
    	counter++;     	
    }
       
    function onReceive(responseCode, data) 
    {
       var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);		
	   var dateTime = Lang.format("$5$:$6$:$7$ $3$.$2$", [today.year.format("%04d"),  today.month.format("%02d"), today.day.format("%02d"), today.day_of_week, today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]);
       	
       LAST_RES_ST = responseCode;
       LAST_RES_CN++;
       LAST_RES_DT = dateTime;       
       //Application.getApp().setProperty("last_res", LAST_RES_DT);
       
       var cont =  true;
       if((responseCode == -1) || (responseCode == -2) || (responseCode == 3) || (responseCode == -5) || (responseCode == -101) || (responseCode == -103) || (responseCode == -104) || (responseCode == -300) || (responseCode == -1003) || (responseCode == -1004))
       {
            cont = false;             
       } 
   	   	
       if(cont)
       {          	
       		LAST_OK_ST = responseCode;
            LAST_OK_CN++;
            LAST_OK_DT = dateTime;
            Application.getApp().setProperty("last_ok", LAST_OK_DT);  
            	
       		System.println("Web Call OK"); 
       		WatchUi.requestUpdate();     
       	}
       	else
       	{
       		LAST_BAD_ST = responseCode;
       		LAST_BAD_CN++;
       		LAST_BAD_DT = dateTime;
       		//Application.getApp().setProperty("last_bad", LAST_BAD_DT);
       		       		       		
       		System.println("Web Call BAD"); 
       	}       	
    }
    
    public function GetGeoNow()
    {
    	var myPoc = Position.getInfo().position;
    	var myLoc = myPoc.toDegrees();
    	var myGeo = Lang.format("$1$,$2$",myLoc);
    	return myGeo;
    }
    
    public function GetStepsNow()
    {
    	var info = ActivityMonitor.getInfo();
		var steps = info.steps;
		//var calories = info.calories;
		return steps;
    }
    
    public function GetAccNow()
    {
    	var info = Sensor.getInfo();
    	var xAccel = 0;
    	var yAccel = 0;
    	var xMag = 0;
    	var yMag = 0;

        if (info has :accel && info.accel != null) 
        {
            var accel = info.accel;
            xAccel = accel[0];
            yAccel = accel[1];                   
        }
        if (info has :mag && info.mag != null) 
        {
            var mag = info.mag;
            xMag = mag[0];
            yMag = mag[1];
        }
        return Lang.format("$1$;$2$;$3$;$4$",[xAccel,yAccel,xMag,yMag]);
    }
    
    public function WebCall(cType)
    {
    	if(CALL_SERVICE == 0) {
    		WebCall_Navicom(cType);
    	} else if(CALL_SERVICE == 1) {
    		WebCall_MapMyTracks();
    	} else if(CALL_SERVICE == 2) {
    		WebCall_BigBrotherGPS();
    	}
    }
    
    private function WebCall_BigBrotherGPS()
    {
        var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);	
        var ttimme = Lang.format("$1$-$2$-$3$T$5$:$6$:$7$.00", [today.year.format("%04d"),  today.month.format("%02d"), today.day.format("%02d"), today.day_of_week, today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]);
       
    	var myPoc = Position.getInfo().position;
    	var myLoc = myPoc.toDegrees();
    	
    	var params = {    
        	  "latitude" => myLoc[0],
        	  "longitude" => myLoc[1],
        	  "accuracy" => Position.getInfo().accuracy,
        	  "altitude" => Position.getInfo().altitude,
        	  "provider" => "network",
        	  "bearing" => (Position.getInfo().heading * 180 / Math.PI),
        	  "speed" => (Position.getInfo().speed  * 3.6),
        	  "time" => ttimme                                                   
        	};     
        
        var options = {
           		:method => Communications.HTTP_REQUEST_METHOD_POST,
           		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
       		};
       		
       var dateTime2 = Lang.format("$5$:$6$:$7$ $3$.$2$", [today.year.format("%04d"),  today.month.format("%02d"), today.day.format("%02d"), today.day_of_week, today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]);	
       		
       LAST_TRY_CN++;
       LAST_TRY_DT = dateTime2;
       
       var responseCallback = method(:onReceive);
       var url = CALL_SVC[CALL_SERVICE] + "?imei=" + CALL_USER_ID + "_" + CALL_USER_CODE;
       Communications.makeWebRequest(url, params, options, responseCallback);
    }
    
    private function WebCall_MapMyTracks()
    {
    	var myPoc = Position.getInfo().position;
    	var myLoc = myPoc.toDegrees();
    	
    	var params = {    
        	  "request" => "update_activity",
        	  "points" => Lang.format("$1$ $2$ $3$ $4$", [myLoc[0], myLoc[1], Position.getInfo().altitude, Time.now().value()])                                                       
        	};     
        
        var options = {
           		:method => Communications.HTTP_REQUEST_METHOD_POST,
           		:headers => 
           			{ "Authorization" => Lang.format("Basic $1$", [CALL_USER_MMT] ) },
           		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
       		};
       		
       var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);	
       var dateTime2 = Lang.format("$5$:$6$:$7$ $3$.$2$", [today.year.format("%04d"),  today.month.format("%02d"), today.day.format("%02d"), today.day_of_week, today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]);
       LAST_TRY_CN++;
       LAST_TRY_DT = dateTime2;
       
       var responseCallback = method(:onReceive);
       Communications.makeWebRequest(CALL_SVC[CALL_SERVICE], params, options, responseCallback);
    }
    
    private function WebCall_Navicom(cType)
    {
    	var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);		
		var dateTime = Lang.format("$1$-$2$-$3$T$5$:$6$:$7$", [today.year.format("%04d"),  today.month.format("%02d"), today.day.format("%02d"), today.day_of_week, today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]);

        var params = {    
        	  "cType" => cType,                                         
              "appId" => CALL_APP_ID,
              "userId" => CALL_USER_ID,
              "userCode" => CALL_USER_CODE,
              "dateTime" => dateTime,
              "unixTime" => Time.now().value(),
              "latLon" => GetGeoNow(),
              "speed" => (Position.getInfo().speed  * 3.6),
              "alt" => Position.getInfo().altitude,
              "heading" => (Position.getInfo().heading * 180 / Math.PI),
              "fix" => Position.getInfo().accuracy,
              "headrtRate" => string_HR,
              "steps" => GetStepsNow(),
              "temperature" => string_TS,
              "pressure" => string_PS,
              "accelerate" => GetAccNow(),
              "device" => System.getDeviceSettings().uniqueIdentifier,
              "phoneConn" =>  System.getDeviceSettings().phoneConnected,
              "partNo" => System.getDeviceSettings().partNumber,
              "battery" => System.getSystemStats().battery,
              "charging" => System.getSystemStats().charging,
              "LSRC" => LAST_RES_ST,
              "interval" => INTERVAL
        	};
        
        var options = {
           		:method => Communications.HTTP_REQUEST_METHOD_POST,
           		:headers => 
           			{ "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON,
           			  "ApplicationID" => CALL_APP_ID },
           		:responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_TEXT_PLAIN
       		};
       
       var dateTime2 = Lang.format("$5$:$6$:$7$ $3$.$2$", [today.year.format("%04d"),  today.month.format("%02d"), today.day.format("%02d"), today.day_of_week, today.hour.format("%02d"), today.min.format("%02d"), today.sec.format("%02d")]);
       LAST_TRY_CN++;
       LAST_TRY_DT = dateTime2;
       
       var responseCallback = method(:onReceive);
       Communications.makeWebRequest(CALL_SVC[CALL_SERVICE], params, options, responseCallback);
    }
    
    function onSensor(sensor_info)
    {
        var HR = sensor_info.heartRate;
        if( HR != null )
        {
            string_HR = HR.toString();
        }
        else
        {
            string_HR = "--";
        }
        var TS = sensor_info.temperature;
        if( TS != null )
        {
            string_TS = TS.toString();
        }
        else
        {
            string_TS = "--";
        }
        var PS = sensor_info.pressure;
        if( PS != null )
        {
            string_PS = PS.toString();
        }
        else
        {
            string_PS = "--";
        }
    }
    
    function Bgrnd()
    {
        Background.deleteTemporalEvent();     
    	var td = new Time.Duration(5 * 60); // 5 minutes minimum
     	td = Time.now().add(td);
     	Background.registerForTemporalEvent(td);
    }
}