using Toybox.Application;
using Toybox.System;
using Toybox.Background;
using Toybox.WatchUi;

(:background)
class x5App extends Application.AppBase {
  
    public static var x5Mc;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) { 
      	x5Mc = new x5Main();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }
    
    // Return the initial view of your application here
    function getInitialView() {
   		 return [ new x5View(), new x5Delegate() ];
    }

}

(:background)
class x5Bgrnd extends System.ServiceDelegate 
{
    function initialize() {
        ServiceDelegate.initialize();
    }

    function onTemporalEvent()
    {
        System.println("onTemporalEvent");  
        Background.requestApplicationWake("Запустите КАК ТЫ?");
        Background.exit(true);
    }        
}

