using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Communications;
using Toybox.Application;

var last_key = null;
var last_behavior = null;
var buttons_pressed = null;
var buttons_expected = null;

class x5Delegate extends WatchUi.BehaviorDelegate {

	public static var disable_menu_ss = Application.getApp().getProperty("disable_menu_ss");  
	public static var geoFormatNum = Application.getApp().getProperty("geo_format");  

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
    	
    	var menu = new WatchUi.CustomMenu(45,Graphics.COLOR_BLACK,{:focusItemHeight=>65});
    	if(!disable_menu_ss)
    	{
    		if(!x5App.x5Mc.IsRunning()) {
	        	menu.addItem(new CustomItem(:start, "Старт", 1001));
	        } else {
        		menu.addItem(new CustomItem(:stop, "Стоп", 1002));
        	}
        }
    	menu.addItem(new CustomItem(:once, "Одиночный отчет", 1003));
    	menu.addItem(new CustomItem(:item9, "Формат координат", 1004));
    	menu.addItem(new CustomItem(:cfgmenu, "Параметры", 1005));
    	WatchUi.pushView(menu, new x5MenuDelegate(), WatchUi.SLIDE_UP );        
        return true;
    }

	function onKey(evt) {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            onEnter();
        } else if (evt.getKey() == WatchUi.KEY_LIGHT) {
            
        } else if (evt.getKey() == WatchUi.KEY_DOWN) {
          	onPage(1);
        } else if (evt.getKey() == WatchUi.KEY_MENU) {
            
        } else if (evt.getKey() == WatchUi.KEY_UP) {
            onPage(-1);
        }
        WatchUi.requestUpdate();
        return false;
    }
    
    function onEnter()
    {
    	if((x5View.pageActive == 0))
    	{
    		if(x5App.x5Mc.IsRunning())
    		{
    			x5App.x5Mc.Stop();
    		}
    		else
    		{
    			x5App.x5Mc.Start();
    		}
    	}
    	else if((x5View.pageActive == 1) || (x5View.pageActive == 2))
    	{
    		x5View.page12more++;
    		if(x5View.page12more == 8)
    		{
    			x5View.page12more = 0;
    		}	
    	}
    	else if(x5View.pageActive == 3)
    	{
    		x5View.page3more++;
    		if(x5View.page3more == 5)
    		{
    			x5View.page3more = 0;
    		}
    	}
    }
    
    function onPage(np)
    {
    	x5View.page3more = 0;
    	if(np == 1)
    	{
    		x5View.pageActive++;
    		if((x5View.pageActive == 2) && (x5View.disable_page_2))
    		{
    			x5View.pageActive++;
    		}
    		if((x5View.pageActive == 3) && (x5View.disable_page_3))
    		{
    			x5View.pageActive++;
    		}
    		if(x5View.pageActive > 3)
    		{
    			if(x5View.disable_page_0)
    			{
    				x5View.pageActive = 1;
    			}
    			else
    			{
    				x5View.pageActive = 0;
    			}
    		}	
    	}
    	else
    	{
    		x5View.pageActive--;
    		if((x5View.pageActive == 3) && (x5View.disable_page_3))
    		{
    			x5View.pageActive--;
    		}
    		if((x5View.pageActive == 2) && (x5View.disable_page_2))
    		{
    			x5View.pageActive--;
    		}
    		if((x5View.pageActive == 0) && (x5View.disable_page_0))
    		{
    			x5View.pageActive--;
    		}
    		if(x5View.pageActive < 0)
    		{
    			x5View.pageActive = 4;
    			onPage(-1);
    		}	
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
            x5App.x5Mc.Start(); 
            WatchUi.popView(WatchUi.SLIDE_DOWN);        
        } 
        else if (item.mId == 1002) 
        {
            x5App.x5Mc.Stop();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        else if (item.mId == 1003) 
        {
            x5App.x5Mc.Once();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        else if (item.mId == 1005) 
        {
        	var customMenu = new WatchUi.CustomMenu(45,Graphics.COLOR_BLACK,{:focusItemHeight=>65});
        	customMenu.addItem(new CustomItem(:item1, "Версия приложения", 1));
        	customMenu.addItem(new CustomItem(:item2, "Идентиф польз", 2));
    		customMenu.addItem(new CustomItem(:item3, "Провер код польз", 3));
    		customMenu.addItem(new CustomItem(:item4, "Интервал отчетов", 4));
    		customMenu.addItem(new CustomItem(:item5, "Пуск только из меню", 5));
    		customMenu.addItem(new CustomItem(:item6, "Старт/Стоп в меню", 6));
    		customMenu.addItem(new CustomItem(:item7, "Экран Где Ты?", 7));
    		customMenu.addItem(new CustomItem(:item8, "Экран Кто Ты?", 8)); 
    		customMenu.addItem(new CustomItem(:item9, "Сервер отчетов", 9)); 
    		if(x5Main.CALL_SERVICE == 2) {  		
    			customMenu.addItem(new CustomItem(:item10, "Big Brother GPS", 10)); }
    		WatchUi.pushView(customMenu, new x5MenuDelegate(), WatchUi.SLIDE_UP );
        }  
        else if (item.mId == 1004)
        {
        	x5Delegate.geoFormatNum++;        	 
        	if(x5Delegate.geoFormatNum > 3) { x5Delegate.geoFormatNum = 0; }
        	Application.getApp().setProperty("geo_format", x5Delegate.geoFormatNum); 
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
        		txt += "\n" + x5Main.AppVersion;
        	} else if(mId == 2) {
        		txt += "\n" + x5Main.CALL_USER_ID;
        	} else if(mId == 3) {
        		txt += "\n" + x5Main.CALL_USER_CODE;
        	} else if(mId == 4) {
        		txt += "\n" + x5Main.INTERVAL + " сек";
        	} else if(mId == 5) {
        		if(x5View.disable_page_0) {
	        		txt += "\nда";
	        	} else {
	        		txt += "\nнет";
	        	}
        	} else if(mId == 6) {
        		if(x5Delegate.disable_menu_ss) { 
	        		txt += "\nскрывать";
	        	} else {
	        		txt += "\nпоказывать";
	        	}
        	} else if(mId == 7) {
        		if(x5View.disable_page_2) {
	        		txt += "\nскрывать";
	        	} else {
	        		txt += "\nпоказывать";
	        	}
        	} else if(mId == 8) {
        		if(x5View.disable_page_3) {
	        		txt += "\nскрывать";
	        	} else {
	        		txt += "\nпоказывать";
	        	}
        	}  else if(mId == 9) {
        		if(x5Main.CALL_SERVICE == 0) {
	        		txt += "\nNavicom Call";
	        	} else if(x5Main.CALL_SERVICE == 1) {
	        		txt += "\nOruxPals MMT";
	        	} else if(x5Main.CALL_SERVICE == 2) {
	        		txt += "\nLive GPS Tracks";
	        	}
        	} else if(mId == 10) {
        		txt += "\n" + x5Main.CALL_USER_ID + "_" + x5Main.CALL_USER_CODE;
        	} else if(mId == 1001) {
        		txt += "\nпериодичн отчетов";
        	} else if(mId == 1002) {
        		txt += "\nпериодичн отчетов";
        	} else if(mId == 1003) {
        		txt = "Отправить\nодиночный отчет";
        	} else if(mId == 1004) {
        		var geoFormatText = "ГГ.ГГГГГГГ°";
        		if(x5Delegate.geoFormatNum == 1) {
        			geoFormatText = "ГГ° ММ.ГГГГ\""; 
        		} else if(x5Delegate.geoFormatNum == 2) {
        			geoFormatText = "ГГ° ММ\" СС.СС'"; 
        		} if(x5Delegate.geoFormatNum == 3) {
        			geoFormatText = "ГГ° ММ\" СС'"; 
        		} 
        		txt += "\n" + geoFormatText;
        	} else if(mId == 1005) {
        		txt += "\nотправки отчетов";
        	}
        	if(((mId >= 0) && (mId < 1000)) || (mId == 1005)) {
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