using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Communications;
using Toybox.Application;

var last_key = null;
var last_behavior = null;
var buttons_pressed = null;
var buttons_expected = null;

class x8Delegate extends WatchUi.BehaviorDelegate {

	public static var disable_menu_ss = Application.getApp().getProperty("disable_menu_ss");  
	public static var geoFormatNum = Application.getApp().getProperty("geo_format");  
	
	public static var repPage = 0;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
    	
    	var menu = new WatchUi.CustomMenu(45,Graphics.COLOR_BLACK,{:focusItemHeight=>65});
    	if(!disable_menu_ss)
    	{
    		if(!x8App.x8Mc.IsRunning()) {
	        	menu.addItem(new CustomItem(:start, "Старт", 1001));
	        } else {
        		menu.addItem(new CustomItem(:stop, "Стоп", 1002));
        	}
        }
    	menu.addItem(new CustomItem(:once, "Одиночный отчет", 1003));
    	menu.addItem(new CustomItem(:item9, "Формат координат", 1004));
    	menu.addItem(new CustomItem(:cfgmenu, "Параметры", 1005));
    	menu.addItem(new CustomItem(:reports, "Обзор отчетов", 1006));
    	WatchUi.pushView(menu, new x5MenuDelegate(), WatchUi.SLIDE_UP );        
        return true;
    }

	function onKey(evt) {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            onEnter();
        } else if (evt.getKey() == WatchUi.KEY_LIGHT) {
            
        } else if (evt.getKey() == WatchUi.KEY_DOWN) {
          	
        } else if (evt.getKey() == WatchUi.KEY_MENU) {
            
        } else if (evt.getKey() == WatchUi.KEY_UP) {
            
        }
        WatchUi.requestUpdate();
        return false;
    }
    
    function onEnter()
    {
    	x8View.page12more++;
    	if(x8View.page12more == 9)
    	{
    		x8View.page12more = 0;
    	}	
    }    
}

class x5MenuDelegate extends WatchUi.MenuInputDelegate {
    function initialize() {
        WatchUi.MenuInputDelegate.initialize();
    }
    
    function onSelect(item) 
    {
    	if (item.mId == 1001) 
        {               
            x8App.x8Mc.Start(); 
            WatchUi.popView(WatchUi.SLIDE_DOWN);        
        } 
        else if (item.mId == 1002) 
        {
            x8App.x8Mc.Stop();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        else if (item.mId == 1003) 
        {
            x8App.x8Mc.Once();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        else if (item.mId == 1005) 
        {
        	var customMenu = new WatchUi.CustomMenu(45,Graphics.COLOR_BLACK,{:focusItemHeight=>65});
        	customMenu.addItem(new CustomItem(:item1, "Версия виджета", 1));
        	customMenu.addItem(new CustomItem(:item2, "Идентиф польз", 2));
    		customMenu.addItem(new CustomItem(:item3, "Провер код польз", 3));
    		customMenu.addItem(new CustomItem(:item4, "Интервал отчетов", 4));
    		customMenu.addItem(new CustomItem(:item6, "Старт/Стоп в меню", 6));
    		customMenu.addItem(new CustomItem(:item9, "Сервер отчетов", 9));
    		if(x8Main.CALL_SERVICE == 2) {  		
    			customMenu.addItem(new CustomItem(:item10, "Big Brother GPS", 10)); }
    		WatchUi.pushView(customMenu, new x5MenuDelegate(), WatchUi.SLIDE_UP );
        }  
        else if (item.mId == 1006) 
        {
        	var customMenu = new WatchUi.CustomMenu(45,Graphics.COLOR_BLACK,{:focusItemHeight=>65});
        	customMenu.addItem(new CustomItem(:item2001, "Последний отчет", 2001));
        	customMenu.addItem(new CustomItem(:item2002, "Последний отклик", 2002));
    		customMenu.addItem(new CustomItem(:item2003, "Последняя ошибка", 2003));
    		customMenu.addItem(new CustomItem(:item2004, "Последняя попытка", 2004));
    		WatchUi.pushView(customMenu, new x5MenuDelegate(), WatchUi.SLIDE_UP );
        } 
        else if (item.mId == 1004)
        {
        	x8Delegate.geoFormatNum++;        	 
        	if(x8Delegate.geoFormatNum > 3) { x8Delegate.geoFormatNum = 0; }
        	Application.getApp().setProperty("geo_format", x8Delegate.geoFormatNum); 
        	WatchUi.requestUpdate();
        } 
        else if ((item.mId == 2001) || (item.mId == 2002) || (item.mId == 2003) || (item.mId == 2004))
        {
        	x8Delegate.repPage++;
        	if(x8Delegate.repPage > 2) { x8Delegate.repPage = 0; }
        	WatchUi.requestUpdate();
        }
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onWrap(key) {
        return false;
    }
}

class CustomItem extends WatchUi.CustomMenuItem {
    public var mLabel;
    public var mId;

    function initialize(id, label, mid) {
        CustomMenuItem.initialize(id, {});
        mLabel = label;
        mId = mid;
    }

    function draw(dc) {
    	var txt = mLabel;
    	if( isFocused() ) 
    	{
    		if(mId == 1) {
        		txt += "\n" + x8Main.AppVersion;
        	} else if(mId == 2) {
        		txt += "\n" + x8Main.CALL_USER_ID;
        	} else if(mId == 3) {
        		txt += "\n" + x8Main.CALL_USER_CODE;
        	} else if(mId == 4) {
        		txt += "\n" + x8Main.INTERVAL + " сек";
        	} else if(mId == 6) {
        		if(x8Delegate.disable_menu_ss) {  
	        		txt += "\nскрывать";
	        	} else {
	        		txt += "\nпоказывать";
	        	}
        	}  else if(mId == 9) {
        		if(x8Main.CALL_SERVICE == 0) {
	        		txt += "\nNavicom Call";
	        	} else if(x8Main.CALL_SERVICE == 1) {
	        		txt += "\nOruxPals MMT";
	        	} else if(x8Main.CALL_SERVICE == 2) {
	        		txt += "\nLive GPS Tracks";
	        	}
        	} else if(mId == 10) {
        		txt += "\n" + x8Main.CALL_USER_ID + "_" + x8Main.CALL_USER_CODE;
        	} else if(mId == 1001) {
        		txt += "\nпериодичн отчетов";
        	} else if(mId == 1002) {
        		txt += "\nпериодичн отчетов";
        	} else if(mId == 1003) {
        		txt = "Отправить\nодиночный отчет";
        	} else if(mId == 1004) {
        		var geoFormatText = "ГГ.ГГГГГГГ°";
        		if(x8Delegate.geoFormatNum == 1) {
        			geoFormatText = "ГГ° ММ.ГГГГ\""; 
        		} else if(x8Delegate.geoFormatNum == 2) {
        			geoFormatText = "ГГ° ММ\" СС.СС'"; 
        		} if(x8Delegate.geoFormatNum == 3) {
        			geoFormatText = "ГГ° ММ\" СС'"; 
        		} 
        		txt += "\n" + geoFormatText;
        	} else if(mId == 1005) {
        		txt += "\nотправки отчетов";
        	} else if(mId == 1006) {
        		txt = "Обзор данных\nпо отчетам";
        	} else if(mId == 2001) {
        		if(x8Delegate.repPage == 0) {
	        		txt += "\n" + x8App.x8Mc.LAST_OK_DT;
	        	} else if(x8Delegate.repPage == 1) {
	        		txt += "\n" + x8App.x8Mc.LAST_OK_ST;
	        	} else {
	        		txt += "\n" + x8App.x8Mc.LAST_OK_CN;
	        	}
        	} else if(mId == 2002) {
        		if(x8Delegate.repPage == 0) {
	        		txt += "\n" + x8App.x8Mc.LAST_RES_DT;
	        	} else if(x8Delegate.repPage == 1) {
	        		txt += "\n" + x8App.x8Mc.LAST_RES_ST;
	        	} else {
	        		txt += "\n" + x8App.x8Mc.LAST_RES_CN;
	        	}
        	} else if(mId == 2003) {
        		if(x8Delegate.repPage == 0) {
	        		txt += "\n" + x8App.x8Mc.LAST_BAD_DT;
	        	} else if(x8Delegate.repPage == 1) {
	        		txt += "\n" + x8App.x8Mc.LAST_BAD_ST;
	        	} else {
	        		txt += "\n" + x8App.x8Mc.LAST_BAD_CN;
	        	}
        	} else if(mId == 2004) {
        		if(x8Delegate.repPage == 0) {
	        		txt += "\n" + x8App.x8Mc.LAST_TRY_DT;
	        	} else if(x8Delegate.repPage == 1) {
	        		txt += "\n" + "интервал " + x8Main.INTERVAL + " с";
	        	} else {
	        		txt += "\n" + x8App.x8Mc.LAST_TRY_CN;
	        	}
        	}
        	if(((mId >= 0) && (mId < 1000)) || ((mId >= 2000) && (mId < 3000)) || (mId == 1005) || (mId == 1006)) {
	        	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
	        } else if((mId >= 1000) && (mId <= 2000)) {
	        	dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_RED);
	        }
            dc.clear();
        }
		
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_SMALL, txt, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.drawLine(0, 0, dc.getWidth(), 0);
        dc.drawLine(0, dc.getHeight() - 1, dc.getWidth(), dc.getHeight() - 1);
    }
}