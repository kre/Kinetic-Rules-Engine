/* Fancybox plugin, used for the lightbox.

Available at http:\/\/fancybox.net/ */

(function (b) { var a = { width: 800, height: 600, overlayOpacity: 0.85, id: "modal", src: function (c) { return jQuery(c).attr("href") }, fadeInSpeed: 0, fadeOutSpeed: 0 }; b.modal = function (c) { return _modal(this, c) }; b.modal.open = function () { _modal.open() }; b.modal.close = function () { _modal.close() }; b.fn.modal = function (c) { return _modal(this, c) }; _modal = function (c, d) { this.options = { parent: null, overlayOpacity: null, id: null, content: null, width: null, height: null, modalClassName: null, imageClassName: null, closeClassName: null, overlayClassName: null, src: null }; this.options = b.extend({}, options, _defaults); this.options = b.extend({}, options, a); this.options = b.extend({}, options, d); this.close = function () { jQuery("." + options.modalClassName + ", ." + options.overlayClassName).fadeOut(a.fadeOutSpeed, function () { jQuery(this).unbind().remove() }) }; this.open = function () { if (typeof options.src == "function") { options.src = options.src(c) } else { options.src = options.src || _defaults.src(c) } var e = /^.+\.((jpg)|(gif)|(jpeg)|(png)|(jpg))$/i; var f = ""; if (e.test(options.src)) { f = '<div class="' + options.imageClassName + '"><img src="' + options.src + '"/></div>' } else { f = '<iframe width="' + options.width + '" height="' + options.height + '" frameborder="0" scrolling="no" allowtransparency="true" src="' + options.src + '"></iframe>' } options.content = options.content || f; if (jQuery("." + options.modalClassName).length && jQuery("." + options.overlayClassName).length) { jQuery("." + options.modalClassName).html(options.content) } else { $overlay = jQuery((_isIE6()) ? '<iframe src="BLOCKED SCRIPT\'<html></html>\';" scrolling="no" frameborder="0" class="' + options.overlayClassName + '"></iframe><div class="' + options.overlayClassName + '"></div>' : '<div class="' + options.overlayClassName + '"></div>'); $overlay.hide().appendTo(options.parent); $modal = jQuery('<div id="' + options.id + '" class="' + options.modalClassName + '" style="width:' + options.width + "px; height:" + options.height + "px; margin-top:-" + (options.height / 2) + "px; margin-left:-" + (options.width / 2) + 'px;">' + options.content + "</div>"); $modal.hide().appendTo(options.parent); $close = jQuery('<a class="' + options.closeClassName + '"></a>'); $close.appendTo($modal); var g = _getOpacity($overlay.not("iframe")) || options.overlayOpacity; $overlay.fadeTo(0, 0).show().not("iframe").fadeTo(a.fadeInSpeed, g); $modal.fadeIn(a.fadeInSpeed); $close.click(function () { jQuery.modal().close() }); $overlay.click(function () { jQuery.modal().close() }) } }; return this }; _isIE6 = function () { if (document.all && document.getElementById) { if (document.compatMode && !window.XMLHttpRequest) { return true } } return false }; _getOpacity = function (c) { $sender = jQuery(c); opacity = $sender.css("opacity"); filter = $sender.css("filter"); if (filter.indexOf("opacity=") >= 0) { return parseFloat(filter.match(/opacity=([^)]*)/)[1]) / 100 } else { if (opacity != "") { return opacity } } return "" }; _defaults = { parent: "body", overlayOpacity: 85, id: "modal", content: null, width: 800, height: 600, modalClassName: "modal-window", imageClassName: "modal-image", closeClassName: "close-window", overlayClassName: "modal-overlay", src: function (c) { return jQuery(c).attr("href") } } })($K);

/* End fancybox... */


/* Start of slide out plugin. Should be minified...

Available at http:\/\/wpaoli.building58.com/2009/09/jquery-tab-slide-out-plugin/ */

(function($){
    $.fn.tabSlideOut = function(callerSettings) {
        var settings = $.extend({
            tabHandle: '.handle',
            speed: 300,
            action: 'click',
            tabLocation: 'left',
            topPos: '200px',
            leftPos: '20px',
            fixedPosition: false,
            positioning: 'absolute',
            pathToTabImage: null,
            imageHeight: null,
            imageWidth: null,
            onLoadSlideOut: false                       
        }, callerSettings||{});

        settings.tabHandle = $(settings.tabHandle);
        var obj = this;
        if (settings.fixedPosition === true) {
            settings.positioning = 'fixed';
        } else {
            settings.positioning = 'absolute';
        }
        
        //ie6 doesn't do well with the fixed option
        if ($.browser.msie && $.browser.version.substr(0,1)<7) {
            settings.positioning = 'absolute';
        }
        

        
        //set initial tabHandle css
        
        if (settings.pathToTabImage !== null) {
            settings.tabHandle.css({
            'background' : 'url('+settings.pathToTabImage+') no-repeat',
            'width' : settings.imageWidth,
            'height': settings.imageHeight
            });
        }
        
        settings.tabHandle.css({ 
            'display': 'block',
            'textIndent' : '-99999px',
            'outline' : 'none',
            'position' : 'absolute'
        });
        
        obj.css({
            'line-height' : '1',
            'position' : settings.positioning
        });

        
        var properties = {
                    containerWidth: parseInt(obj.outerWidth(), 10) + 'px',
                    containerHeight: parseInt(obj.outerHeight(), 10) + 'px',
                    tabWidth: parseInt(settings.tabHandle.outerWidth(), 10) + 'px',
                    tabHeight: parseInt(settings.tabHandle.outerHeight(), 10) + 'px'
                };

        //set calculated css
        if(settings.tabLocation === 'top' || settings.tabLocation === 'bottom') {
            obj.css({'left' : settings.leftPos});
            settings.tabHandle.css({'right' : 0});
        }
        
        if(settings.tabLocation === 'top') {
            obj.css({'top' : '-' + properties.containerHeight});
            settings.tabHandle.css({'bottom' : '-' + properties.tabHeight});
        }

        if(settings.tabLocation === 'bottom') {
            obj.css({'bottom' : '-' + properties.containerHeight, 'position' : 'fixed'});
            settings.tabHandle.css({'top' : '-' + properties.tabHeight});
            
        }
        
        if(settings.tabLocation === 'left' || settings.tabLocation === 'right') {
            obj.css({
                'height' : properties.containerHeight,
                'top' : settings.topPos
            });
            
            settings.tabHandle.css({'top' : 0});
        }
        
        if(settings.tabLocation === 'left') {
            obj.css({ 'left': '-' + properties.containerWidth});
            settings.tabHandle.css({'right' : '-' + properties.tabWidth});
        }

        if(settings.tabLocation === 'right') {
            obj.css({ 'right': '-' + properties.containerWidth});
            settings.tabHandle.css({'left' : '-' + properties.tabWidth});
            
            $('html').css('overflow-x', 'hidden');
        }

        //functions for animation events
        
        settings.tabHandle.click(function(event){
            event.preventDefault();
        });
        
        var slideIn = function() {
            
            if (settings.tabLocation === 'top') {
                obj.animate({top:'-' + properties.containerHeight}, settings.speed).removeClass('open');
            } else if (settings.tabLocation === 'left') {
                obj.animate({left: '-' + properties.containerWidth}, settings.speed).removeClass('open');
            } else if (settings.tabLocation === 'right') {
                obj.animate({right: '-' + properties.containerWidth}, settings.speed).removeClass('open');
            } else if (settings.tabLocation === 'bottom') {
                obj.animate({bottom: '-' + properties.containerHeight}, settings.speed).removeClass('open');
            }    
            
        };
        
        var slideOut = function() {
            
            if (settings.tabLocation == 'top') {
                obj.animate({top:'-3px'},  settings.speed).addClass('open');
            } else if (settings.tabLocation == 'left') {
                obj.animate({left:'-3px'},  settings.speed).addClass('open');
            } else if (settings.tabLocation == 'right') {
                obj.animate({right:'-3px'},  settings.speed).addClass('open');
            } else if (settings.tabLocation == 'bottom') {
                obj.animate({bottom:'-3px'},  settings.speed).addClass('open');
            }
        };

        var clickScreenToClose = function() {
            obj.click(function(event){
                event.stopPropagation();
            });
            
            $(document).click(function(){
                slideIn();
            });
        };
        
        var clickAction = function(){
            settings.tabHandle.click(function(event){
                if (obj.hasClass('open')) {
                    slideIn();
                } else {
                    slideOut();
                }
            });
            
            clickScreenToClose();
        };
        
        var hoverAction = function(){
            obj.hover(
                function(){
                    slideOut();
                },
                
                function(){
                    slideIn();
                });
                
                settings.tabHandle.click(function(event){
                    if (obj.hasClass('open')) {
                        slideIn();
                    }
                });
                clickScreenToClose();
                
        };
        
        var slideOutOnLoad = function(){
            slideIn();
            setTimeout(slideOut, 500);
        };
        
        //choose which type of action to bind
        if (settings.action === 'click') {
            clickAction();
        }
        
        if (settings.action === 'hover') {
            hoverAction();
        }
        
        if (settings.onLoadSlideOut) {
            slideOutOnLoad();
        }
        
    };
})($K);


/* End of slideout */

/* Start of tab manager

ToDo:

- Add a "delete tab" function that automatically moves the tabs up.

- Add checks into addNow to see if I can place a tab above the current tabs.

- Add a notification system.

*/

KOBJ.tabManager = KOBJ.tabManager || {};

KOBJ.tabManager.tabs = KOBJ.tabManager.tabs || [];

KOBJ.tabManager.defaults = {
	"backgroundColor": "white",
	"divCSS": {},
	"tabClass": "handle",
	"pathToTabImage": "http:\/\/k-misc.s3.amazonaws.com/actions/schedule.png",
	"tabLocation": "right",
	"speed": "300",
	"action": "click",
	"fixedPosition": true,
	"imageHeight": "122px",
	"imageWidth": "40px",
	"topPos": 100,
	"width": 250,
	"padding": 10,
	"contentClass": "KOBJ_tab_content",
	"measurementUnit": "px",
	"mode": "slideout",
	"url": "",
	"height": 250,
	"linkContent": "Content",
	"notificationDefaults":{
		"notifyClass": "notification",
		"leftPadding": "10px",
		"topPadding": "2px",
		"rightPadding": "10px",
		"bottomPadding": "2px",
		"divCSS": {
			"text-indent":"0px",
			"background-color":"red",
			"-moz-border-radius": "20px",
			"-webkit-border-radius": "20px",
			"-khtml-border-radius": "20px",
			"border-radius": "20px",
			"text-align": "center",
			"z-index": 10000,
			"min-width": "15px",
			"padding": "2px"
		}
	},

	"linkCSS": {"cursor":"pointer"}
};

/* Nasty notifications
 * I hate making this kind of stuff.
 * It makes my brain hurt.
 * 
 * KOBJ.tabManager.notification
 *
 * changeTo is what the contents of the notification should be. Can be a number, HTML, letter, etc. Width and height is automatic.
 * config is the configuration options.
 *
 *
 * In the config, a "semi" required argument is the name. If you don't specify a name, it just uses the first tab.
 * You can also set the notification settings when creating the tab.
 *
 * Returns true when everything goes well or false when it pukes.
 * 
 */

KOBJ.tabManager.notification = function(config){

	var toAlter, alterNum;
	// Trying to find the right tab. I may change the KOBJ.tabManager.tabs
	// to a hash so I do not need to loop, but the speed hit from this is not major
	$K.each(KOBJ.tabManager.tabs,function(num){
		var object = this;
		if(object['name'] == config['name']){
			toAlter = object;
			alterNum = num;
			return false;
		}
	});
	
	// Grab the first tab if the name was wrong
	
	if(!toAlter){
		alterNum = 0;
		toAlter = KOBJ.tabManager.tabs[0];
	}


	// Test to see if I could find SOME tab. If not, exit.
	if(!toAlter){
		return false;
	}
	
	// Get the defaults stored within KOBJ.tabManager.defaults
	var defaults = $K.extend(true, {}, toAlter['notificationDefaults']);

	// Extend the defaults with the config passed in
	if(typeof config === 'object'){
		$K.extend(true, defaults, config);
	}

	if(defaults.message){
		var changeTo = defaults.message;
	} else {
		return false;
	}

	// Try's are good... It allows me to catch errors
	try {
		// notification is the class which the notification *should* have...
		// If it's there, I change it's contents and apply CSS. otherwise, I add the div.

		var notification = $K(toAlter.tabContentClass + " ." + defaults.notifyClass);
		if(notification.length){
			// If it's there and if I need to change it to nothing, delete the div
			if(changeTo === 0 || changeTo == ''){
				$K(notification).hide();
				return true;
			}
			
			// Otherwise, set the contents and CSS
			$K(notification).html(changeTo).css(defaults.divCSS).show();
			return true;
		}


		var tab = $K(toAlter.tabContentClass);
		var objCSS = $K.extend(true,{},defaults.divCSS);

		// This next block splits the "px" or what not away from the number.
		// This lets me add the numbers later on
		var splitArray = ["imageHeight","imageWidth","topPos","leftPadding","rightPadding","topPadding","bottomPadding"];
		$K.each(splitArray,function(){
			var tempToSplit = this;
			var toSplit = toAlter[tempToSplit];

			if(!toSplit){
				toSplit = defaults[tempToSplit];
				var inDefaults = true;
			}

			if(!toSplit){
				return;
			}

			if(!toSplit.number){
				var number = parseInt(toSplit.replace(/(\d+).*/,"$1"),10);
				var unit = toSplit.replace(/.*\d+(.*)/,"$1");
			}

			if(inDefaults){
				defaults[tempToSplit] = {"number": number, "unit": unit};
			} else {
				toAlter[tempToSplit] = {"number": number, "unit": unit};
			}

		});

		// Aight, where should I put the div? Calculates the height/width of the image to place it in the corner (top inner corner)

		if(toAlter.tabLocation == "left"){
			objCSS.left = (toAlter.imageWidth.number - defaults.leftPadding.number) + defaults.leftPadding.unit;
			objCSS.top = (toAlter.topPos.number - defaults.topPadding.number) + defaults.topPadding.unit;
		}
		if(toAlter.tabLocation == "right"){
			objCSS.right = (toAlter.imageWidth.number - defaults.rightPadding.number) + defaults.rightPadding.unit;
			objCSS.top = (toAlter.topPos.number - defaults.topPadding.number) + defaults.topPadding.unit;
		}
		if(toAlter.tabLocation == "top"){
			objCSS.top = (toAlter.imageHeight.number - defaults.topPadding.number) + defaults.topPadding.unit;
			objCSS.right = (toAlter.topPos.number - defaults.rightPadding.number) + defaults.rightPadding.unit;
		}
		if(toAlter.tabLocation == "bottom"){
			objCSS.bottom = (toAlter.imageHeight.number - defaults.topPadding.number) + defaults.bottomPadding.unit;
			objCSS.right = (toAlter.topPos.number - defaults.rightPadding.number) + defaults.rightPadding.unit;
		}

		// Fixed position?

		if(toAlter.fixedPosition === true) {
			objCSS.position = "fixed";
		} else {
			objCSS.position = "absolute";
		}

		//ie6 doesn't do well with the fixed option
		if ($K.browser.msie && $K.browser.version.substr(0,1)<7) {
			objCSS.position = "absolute";
		}

		// Adds the div and sets all the CSS and classes needed
		var notification = $K("<div>").html(changeTo).css(objCSS).addClass(defaults.notifyClass);
		$K(toAlter.tabHandle).append(notification);

		// Yay!! It worked!
		return true;
	} catch(error) {

		// Oh poo, it broke!

		KOBJ.log(error);
		return false;
	}
};

KOBJ.tabManager.addNew = function(config){


	var defaults = $K.extend(true, {}, KOBJ['tabManager']['defaults']);

	// Extend the defaults
	if(typeof config === 'object') {
		jQuery.extend(true, defaults, config);
	}
	
	console.log(defaults);	

	// Add "px" or other measurement to elements which are sizes
	var toAddUnit = ["topPos","width","padding"];
	$K.each(toAddUnit, function(key,object){
		defaults[object] = defaults[object] + defaults['measurementUnit'];
	});

	// Make a random class
	var classToAdd = "KOBJ_tab_" + Math.floor(Math.random()*9999999);

	var tabs = KOBJ.tabManager.tabs;
	var posToBe = parseInt(defaults['topPos'], 10);
	
	// Sets the top position of each element based upon height of the other elements.
	$K.each(tabs,function(key,object){
		if(object['tabLocation'] == defaults['tabLocation']){
			posToBe = posToBe + parseInt(object['imageHeight'].replace(/(\d+).*/,"$1"), 10) + parseInt(object['padding'], 10);
		}
	});

	// Adds "px" or whatnot
	defaults['topPos'] = posToBe + defaults['measurementUnit'];

	var link = "";



	// Check for content
	if(defaults.message){
		var message = defaults.message;
	} else if(!defaults.url) {
		return false;
	}

	// Do different stuff if it's a lightbox...
	if(defaults['mode'] == "lightbox"){

		// The lightbox will display content if it's passed in or iframe if there's a URL
		if(defaults.url){
			defaults['src'] = defaults.url;
			defaults['type'] = 'iframe';
		} else {
			defaults['content'] = message;
		}

		// Function to bind later on.
		var action = function(){ $K(this).modal(defaults).open(); return false; };
		
		// Makes an anchor, adds CSS, binds the above function to it, and then adds the class

		link = $K('<a>').css(defaults['linkCSS']).bind(defaults['action'],action).addClass(classToAdd);
		var img = $K('<img>').attr('src',defaults['pathToTabImage']);
		var obj = $K(link).html(img);

		if(defaults['tabLocation'] === 'top' || defaults['tabLocation'] === 'bottom') {
	            obj.css({'right': defaults['topPos']});
	        }
	        
	        if(defaults['tabLocation'] === 'top') {
	           obj.css({'top': 0, 'position': 'fixed'});
	        }
	
	        if(defaults['tabLocation'] === 'bottom') {
	            obj.css({'bottom' : '0', 'position' : 'fixed'});
	        }
	        
	        if(defaults['tabLocation'] === 'left' || defaults['tabLocation'] === 'right') {
	            obj.css({
	                'top' : defaults['topPos'],
			'position': 'fixed'
	            });
	        }
	        
	        if(defaults['tabLocation'] === 'left') {
	            obj.css({ 'left': 0, 'position': 'fixed'});
	        }
	
	        if(defaults['tabLocation'] === 'right') {
	            obj.css({ 'right': 0, 'position': 'fixed'});
	            $K('html').css('overflow-x', 'hidden');
	        }

		$K('body').append(obj);

	} else {
		if(defaults.url){
			var tempMessage = $K('<div>').addClass(defaults['contentClass']).css({"width": defaults['width'], "background-color": defaults['backgroundColor']}).css(defaults['divCSS']);
			link = $K('<a>').addClass(defaults['tabClass']).html(defaults['linkContent']).css(defaults['linkCSS']);
			message = $K('<iframe>').attr('src',defaults.url).css({"width": defaults.width, "height": defaults.height});
			message = $K(tempMessage).append(link).append(message);
			message = $K(message).addClass(classToAdd);
		} else {
			var tempMessage = $K('<div>').addClass(defaults['contentClass']).css({"width": defaults['width'], "background-color": defaults['backgroundColor']}).css(defaults['divCSS']);
			link = $K('<a>').addClass(defaults['tabClass']).html(defaults['linkContent']).css(defaults['linkCSS']);
			message = $K(tempMessage).append(link).append(message);
			message = $K(message).addClass(classToAdd);
		}
	}

	defaults['tabClass'] = '.' + defaults['tabClass'];
	defaults['tabContentClass'] = '.' + classToAdd;

	if(defaults['mode'] != "lightbox"){
		defaults['tabHandle'] = defaults['tabContentClass'] + ">" + defaults['tabClass'];
		$K("body").append(message);
		$K(defaults['tabContentClass']).tabSlideOut(defaults);
	} else {
		defaults['tabHandle'] = defaults['tabContentClass'];
	}

	defaults.message = message;

	KOBJ.tabManager.tabs.push(defaults);
};

KOBJ.css('.modal-overlay {	position: fixed;	top: 0;	right: 0;	bottom: 0;	left: 0;	height: 100%;	width: 100%;	margin: 0;	padding: 0;	background: #131313;	opacity: .85;	filter: alpha(opacity=85);	z-index: 101; } .modal-window { 	position: fixed; 	top: 50%; 	left: 50%; 	margin: 0; 	padding: 0; 	z-index: 102;	background: #fff;	border: solid 8px #000;	-moz-border-radius: 8px;	-webkit-border-radius: 8px;} .close-window {	position: absolute;	width: 47px;	height: 47px;	right: -23px;	top: -23px;	background: transparent url(http:\/\/grigglee.com/random/fancybox/fancy_close.png) no-repeat scroll right top;	text-indent: -99999px;	overflow: hidden;	cursor: pointer;}');

