using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;


using Toybox.Application;
using Toybox.Communications;
using Toybox.Time;
using Toybox.Time.Gregorian;
using Toybox.Position;
using Toybox.Sensor;
using Toybox.ActivityMonitor;
using Toybox.Timer;
using Toybox.Ant;

class x8App extends Application.AppBase 
{
	public static var x8Mc;

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    	x8Mc = new x8Main();
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    // Return the initial view of your application here
    function getInitialView() {
        return [ new x8View(), new x8Delegate() ];
    }
}