


KOBJ.proto = function() {
    if ("http:" != KOBJ.location('protocol') && "https:" != KOBJ.location('protocol'))
    {
        return "https://";
    }
    return (("https:" == KOBJ.location('protocol')) ? "https://" : "http://")
};

//this method is overridden in sandboxed environments
KOBJ.require = function(url, callback_params) {
    // This function is defined if we are in a browser plugin
    if (typeof(callback_params) == "undefined")
    {
        callback_params = {};
    }

    if (KOBJ.in_bx_extention)
    {
        var params = {};
        if (typeof(callback_params) != "undefined") {
            params = $KOBJ.extend({data_type : "js"}, callback_params, true);
        }
        async_url_request(url, "KOBJ.url_loaded_callback", params);
    }
    else if (KOBJ.in_bx_extention && callback_params.data_type == "other")
    {
        async_url_request(url, "KOBJ.url_loaded_callback", callback_params);
    }
    else if (!KOBJ.in_bx_extention && callback_params.data_type == "img")
    {
        var r = document.createElement("img");
        // This is the max url for a get in IE7  IE6 is 488 so we will break on ie6
        r.src = url.substring(0, 1500);
        //  We need to change to the protcol of the location url so that we do not
        // get security errors.
        r.src = KOBJ.proto() + r.src.substr(r.src.indexOf(":") + 2,r.src.length);
        var body = document.getElementsByTagName("body")[0] ||
                   document.getElementsByTagName("frameset")[0];
        body.appendChild(r);
    }
    else
    {
        var r = document.createElement("script");
        // This is the max url for a get in IE7  IE6 is 488 so we will break on ie6
        r.src = url.substring(0, 1500);
        //  We need to change to the protcol of the location url so that we do not
        // get security errors.
        r.src = KOBJ.proto() + r.src.substr(r.src.indexOf(":") + 2,r.src.length);
        r.type = "text/javascript";
        r.onload = r.onreadystatechange = KOBJ.url_loaded_callback;
        var body = document.getElementsByTagName("body")[0] ||
                   document.getElementsByTagName("frameset")[0];
        body.appendChild(r);
    }
};


KOBJ.getwithimage = function(url) {
    KOBJ.require(url, {data_type : "img"});
};


/* Sets up the call backs for "click" and "change" events */
KOBJ.obs = function(type, attr, txn_id, name, sense, rule, rid) {
    var elem;
    if (attr == 'class') {
        elem = '.' + name;
    } else if (attr == 'id') {
        elem = '#' + name;
    } else {
        elem = name;
    }
    if (type == 'click') {
        $KOBJ(elem).click(function(e1) {
            var tgt = $KOBJ(this);
            var b = tgt.attr('href') || '';
            KOBJ.logger("click",
                    txn_id,
                    name,
                    b,
                    sense,
                    rule,
                    rid
                    );
            if (b) {
                tgt.attr('href', '#KOBJ');
            }  // # gets replaced by redirect
        });

    } else if (type == 'change') {
        $KOBJ(elem).change(function(e1) {
            KOBJ.logger("change",
                    txn_id,
                    name,
                    '',
                    sense,
                    rule,
                    rid
                    );
        });
    }

};


/* Injects a javascript fragment into the page */
// TODO: Remove only used by the widget weather.pl
KOBJ.fragment = function(base_url) {
    var e = KOBJ.document.createElement("script");
    e.src = base_url;
    var body = KOBJ.document.getElementsByTagName("body")[0];
    body.appendChild(e);
};

/* Replaces the html contents of an element */
// TODO: Remove only used by the widget weather.pl
KOBJ.update_elements = function (params) {
    for (var mykey in params) {
        $KOBJ("#kobj_" + mykey).html(params[mykey]);
    }
};

// wrap some effects for use in embedded HTML
KOBJ.Fade = function (id) {
    $KOBJ(id).fadeOut();
};

KOBJ.BlindDown = function (id) {
    $KOBJ(id).slideDown();
};

KOBJ.BlindUp = function (id) {
    $KOBJ(id).slideUp();
};

KOBJ.BlindUp = function (id, speed) {
    $KOBJ(id).slideUp(speed);
};

KOBJ.hide = function (id) {
    $KOBJ(id).hide();
};

// TODO: Remove as I hate this
KOBJ.letitsnow = function(config) {
    $KOBJ(KOBJ.document).snowfall();
};

// TODO: Remove not used use side tab now
KOBJ.createPopIn = function(config, content) {

    var defaults = {
        "position": "left-center",
        "imageLocation": "http://k-misc.s3.amazonaws.com/actions/pop_in_feedback.jpg",
        "bg_color": "#FFFFFF",
        "link_color": "#FF0000",
        "overlay_color": "#000000"
    };
    if (typeof config === 'object') {
        jQuery.extend(defaults, config);
    }

    var side1;
    var side2;
    var distance;

    switch (defaults["position"])
    {
        case "top-left":
            side1 = "top";
            side2 = "left";
            distance = "10%";
            break;
        case "top-center":
            side1 = "top";
            side2 = "left";
            distance = "45%";
            break;
        case "top-right":
            side1 = "top";
            side2 = "right";
            distance = "10%";
            break;
        case "bottom-left":
            side1 = "bottom";
            side2 = "left";
            distance = "10%";
            break;
        case "bottom-center":
            side1 = "bottom";
            side2 = "left";
            distance = "45%";
            break;
        case "bottom-right":
            side1 = "bottom";
            side2 = "right";
            distance = "10%";
            break;
        case "left-top":
            side1 = "left";
            side2 = "top";
            distance = "10%";
            break;
        case "left-center":
            side1 = "left";
            side2 = "top";
            distance = "45%";
            break;
        case "left-bottom":
            side1 = "left";
            side2 = "bottom";
            distance = "10%";
            break;
        case "right-top":
            side1 = "right";
            side2 = "top";
            distance = "10%";
            break;
        case "right-center":
            side1 = "right";
            side2 = "top";
            distance = "45%";
            break;
        case "right-bottom":
            side1 = "right";
            side2 = "bottom";
            distance = "10%";
            break;
        default:
            side1 = "left";
            side2 = "top";
            distance = "45%";
            break;
    }

    $KOBJ('body').append('<div id="KOBJ_PopIn_Link" style="' + side1 + ': 0; ' + side2 + ':' + distance + '; -moz-border-radius-bottomright: 12px; -moz-border-radius-topright: 12px; background-color:' + defaults["link_color"] + '; display:block; margin-top:-45px; position: fixed;  z-index:100001;"><a href="javascript:KOBJ_create_pop_in()"><img src="' + defaults["imageLocation"] + '" alt="KOBJ_pop_in" border="none" /></a>');
    KOBJ_create_pop_in = function() {
        var OverlayPresent = $KOBJ('#KOBJ_PopIn_Overlay').length;
        var ContentPresent = $KOBJ('#KOBJ_PopIn_Dialog').length;

        if (OverlayPresent) {
            $KOBJ('#KOBJ_PopIn_Overlay').fadeIn('slow');
        }
        if (ContentPresent) {
            $KOBJ('#KOBJ_PopIn_Dialog').fadeIn('slow');
        }
        if (!OverlayPresent) {
            $KOBJ('body').append('<div id="KOBJ_PopIn_Overlay" style="display: block; position: fixed; background-color: ' + defaults["overlay_color"] + '; height: 100%; width: 100%; left: 0; filter:alpha(opacity=70); opacity: 0.7; top: 0; z-index: 100002; display: none;" />');
            $KOBJ('#KOBJ_PopIn_Overlay').fadeIn('slow');
        }
        if (!ContentPresent) {

            // TODO: Display is overridden remove which one?
            $KOBJ('body').append('<div id="KOBJ_PopIn_Dialog" style="top: 45%; right: 40%; -moz-border-radius: 5px; display: block; height: auto; width: 20%; position: fixed; margin: 0 auto; text-align: center; z-index: 100003; display: none; background: ' + defaults["bg_color"] + '; filter:alpha(opacity=85); opacity: .85; "><div class="close" id="KOBJ_Close" style="cursor: pointer; float: right; font-weight: bold; margin-right: 8px; margin-top: 5px;">x</div><div id="KOBJ_PopIn_Content" style="padding: 10px; ">' + content + '</div></div>');
            $KOBJ("#KOBJ_Close").click(function() {
                KOBJ_close_pop_in();
            });
            $KOBJ('#KOBJ_PopIn_Dialog').fadeIn('slow');
        }

    };

    KOBJ_close_pop_in = function() {

        $KOBJ('#KOBJ_PopIn_Overlay').fadeOut('slow');
        $KOBJ('#KOBJ_PopIn_Dialog').fadeOut('slow');

    };

};

// TODO: Broken as it resets defaults based on config.  It should copy the config
// and use the copied hash
KOBJ.statusbar = function(config, content) {

    var defaults = {


        "sticky": false,
        "width": "98.5%",
        "height": "30px",
        "id": "KOBJ_status_bar",
        "bg_color": "#222222",
        "delay": 3000,
        "position": "bottom",
        "opacity": ".8",
        "color": "#ffffff"

    };
    if (typeof config === 'object') {
        if (config["sticky"] === true) {
            config["delay"] = false;
        }
        jQuery.extend(defaults, config);

    }
    var side = "";
    var corners = "";
    var direction = "";

    switch (defaults["position"]) {
        case "top":
            side = "top";
            corners = "bottom";
            direction = "down";
            break;
        case "bottom":
            side = "bottom";
            corners = "top";
            direction = "up";
            break;
        default:
            side = "bottom";
            corners = "top";
            direction = "up";
            break;
    }


    $KOBJ('body').append('<div id="' + defaults["id"] + '_wrapper" style="display: none; position: fixed; ' + side + ': 0; width: 100%; height: ' + defaults["height"] + ';"><div id="' + defaults["id"] + '" style="color: ' + defaults["color"] + '; height: ' + defaults["height"] + '; background: ' + defaults["bg_color"] + '; opacity: ' + defaults["opacity"] + '; -moz-border-radius-' + corners + 'right: 5px; -moz-border-radius-' + corners + 'left: 5px; margin-left: 12px; margin-right: 30px;"><div class="close" style="float: right; font-weight: bold; font-size: 20px; cursor: pointer; margin-right: 10px; margin-top: 5px;">x</div><div class="KOBJ_statusbar_content" style="color: ' + defaults["color"] + ';">' + content + '</div></div>');
    $KOBJ('#' + defaults["id"] + '>.close').click(function() {
        KOBJ.statusbar_close(defaults["id"]);
    });
    $KOBJ('#' + defaults["id"] + '_wrapper').slideDown('slow');
    if (defaults["sticky"] === false) {
        setTimeout(function() {
            KOBJ.statusbar_close(defaults["id"]);
        }, defaults["delay"]);
    }


};

// Shortcut to do ajax request either sync or not.  If async then you must provide
// a call back function.  If sync the data will be returned at the end of the call.
KOBJ.ajax = function(url, async_request, callback)
{
    var result_data = null;
    $KOBJ.ajax({
        url:    url ,
        success: function(result) {
            if (!async_request)
            {
                result_data = result;
            }
            else
            {
                callback(result);
            }
        },
        async:   async_request
    });

    return result_data;
};

//TODO: Broken Assumes only one status base. Maybe that is ok.
KOBJ.statusbar_close = function(id) {
    $KOBJ('#' + id).fadeOut('slow');
};

//end new jessie actions



KOBJ.page_data_event = function (uniq, label, selectors ,config){
    var app = KOBJ.get_application(config.rid);

    var found_data = [];

    $KOBJ.each(selectors, function(name, selector) {
        var result = $KOBJ(selector["selector"]);
        if(selector["type"] == "text")
            result = result.text();
        else if( selector["type"] == "form" )
            result = result.val();
        else
            result = "invalid select type";


        found_data.push({name: name,value:result });
    });
    found_data.push({name: "label",value:label })


    var all_data = {"param_data":found_data};

    KOBJEventManager.add_out_of_bound_event(app,"page_data",true,all_data);

};


// helper functions used by float
KOBJ.buildDiv = function (uniq, pos, top, side,config) {
    var vert = top.split(/\s*:\s*/);
    var horz = side.split(/\s*:\s*/);
    var div_style = {
        position: pos,
        zIndex: '9999',
        
        display: 'none'
    };
    var class_name = "";
    if(typeof(config) != "undefined" && typeof(config.class_name)!= "undefined"  )
    {
        class_name =  config.class_name;
    }
    div_style[vert[0]] = vert[1];
    div_style[horz[0]] = horz[1];
    var id_str = 'kobj_' + uniq;
    var div = KOBJ.document.createElement('div');
    return $KOBJ(div).attr({'id': id_str}).css(div_style).addClass(class_name);
};

// return the host portion of a URL
KOBJ.get_host = function(s) {
    var h = "";
    try {
        h = s.match(/^(?:\w+:\/\/)?([\w-.]+)/)[1];
    } catch(err) {
    }
    return h;
};

// randomly pick a member of a list
KOBJ.pick = function(o) {
    if (o) {
        return o[Math.floor(Math.random() * o.length)];
    } else {
        return o;
    }
};

// attach a close event to an element inside a notification
KOBJ.close_notification = function(s) {
    $KOBJ(s).bind("click.kGrowl",
            function(e) {
                $KOBJ(this).unbind('click.kGrowl');
                $KOBJ(s).parents(".kGrowl-notification").trigger('kGrowl.beforeClose').animate({opacity: 'hide'}, "normal", "swing", function() {
                    $KOBJ(this).trigger('kGrowl.close').remove();
                });
            });
};


/*
 Called when one of our script is loaded including css links
 */
KOBJ.url_loaded_callback = function(loaded_url, response, callback_params) {


    if (typeof(loaded_url) != "undefined" && typeof(callback_params) != "undefined")
    {
        switch (callback_params.data_type) {
            case  "js":
                eval(response);
            case  "css":
                $KOBJ("head").append($KOBJ("<style>").text(response));
        }

        if (KOBJ.external_resources[loaded_url] != null)
        {
            KOBJ.external_resources[loaded_url].did_load();
        }
    }
    else
    {
        var done = false;
        if (!done && (!this.readyState || this.readyState === "loaded" || this.readyState === "complete"))
        {
            done = true;
            var url = null;
            // This would happen if we were in a browser sandbox.
            //            if (typeof(loaded_url) == "undefined")
            //            {
            if (typeof(this.src) != "undefined")
            {
                url = this.src;
            }
            else
            {
                url = this.href;
            }
            if (url == null)
            {
                return;
            }
            //            }
            //            else
            //            {
            //                url = loaded_url;
            //            }

            //        alert("Go callback for " + url);

            if (KOBJ.external_resources[url] != null)
            {
                //            alert("Found a resource and letting it know");
                KOBJ.external_resources[url].did_load();
            }
            //        alert("Done letting everyone know");

            this.onload = this.onreadystatechange = null;
        }
    }
};


/*
 Add a link tag to the head of the document
 url = URL to stylesheet
 */
KOBJ.load_style_sheet_link = function(url) {

    var head = KOBJ.document.getElementsByTagName('head')[0];
    var new_style_sheet = document.createElement("link");
    new_style_sheet.href = url;
    new_style_sheet.rel = "stylesheet";
    new_style_sheet.type = "text/css";
    head.appendChild(new_style_sheet);
};


KOBJ.siteIds = function()
{
    var siteid = [];
    $KOBJ.each(KOBJ.applications, function(index, app) {
        siteid[index] = app.app_id;
    });
    return siteid.join(";");
};



KOBJ.donotuse_getMethods = function(obj) {
  var result = [];
  for (var id in obj) {
    try {
      if (typeof(obj[id]) == "function") {
        result.push(id + ": " + obj[id].toString());
      }
    } catch (err) {
      result.push(id + ": inaccessible");
    }
  }
  return result;
}

//KOBJ.getStrackTrace = function(exception) {
//    var callstack = [];
//    var isCallstackPopulated = false;
//    if (exception.stack) { //Firefox
//        var lines = exception.stack.split('\n');
//        for (var i = 0, len = lines.length; i < len; i++) {
//            if (lines[i].match(/^\s*[A-Za-z0-9\-_\$]+\(/)) {
//                callstack.push(lines[i]);
//            }
//        }
//        //Remove call to printStackTrace()
//        callstack.shift();
//        isCallstackPopulated = true;
//    }
//    else if (window.opera && exception.message) { //Opera
//        var lines = exception.message.split('\n');
//        for (var i = 0, len = lines.length; i < len; i++) {
//            if (lines[i].match(/^\s*[A-Za-z0-9\-_\$]+\(/)) {
//                var entry = lines[i];
//                //Append next line also since it has the file info
//                if (lines[i + 1]) {
//                    entry += "at" + lines[i + 1];
//                    i++;
//                }
//                callstack.push(entry);
//            }
//        }
//        //Remove call to printStackTrace()
//        callstack.shift();
//        isCallstackPopulated = true;
//    }
//    if (!isCallstackPopulated) { //IE and Safari
//        var currentFunction = arguments.callee.caller;
//
//        alert("Caller : " + KOBJ.donotuse_getMethods(currentFunction).join("\n"));
//        alert("Callee : " + KOBJ.donotuse_getMethods(arguments.callee).join("\n"));
//        alert("Arguments : " + KOBJ.donotuse_getMethods(arguments).join("\n"));
//
//        while (currentFunction) {
//            var fn = currentFunction.toString();
//            alert(fn);
//            var fname = fn.substring(fn.indexOf("function") + 8, fn.indexOf('')) || 'anonymous';
//            callstack.push(fname);
//            currentFunction = currentFunction.caller;
//        }
//    }
//    return callstack.join('\n')
//};

KOBJ.errorstack_submit = function(key, e, rule_info) {
    // No key the ignore.
    if (key == null) {
        return;
    }
    var txt = "_s=" + key;

    if (KOBJ.in_bx_extention)
        txt += "&_r=json";
    else
        txt += "&_r=img";

    txt += "&Msg=" + escape(e.message ? e.message : e);

    var script_url = e.fileName ? e.fileName : (e.filename ? e.filename : null)
    if(!script_url)
    {
        script_url = (e.sourceURL ? e.sourceURL : "Browser does not support exception script url");
    }

    txt += "&ScriptURL=" + escape(script_url);
    txt += "&Agent=" + escape(navigator.userAgent);
    txt += "&PageURL=" + escape(document.location.href);
    txt += "&Line=" + (e.lineNumber ? e.lineNumber : (e.line ? e.line : "Browser does not support exception linenumber"));
    txt += "&Description=" + escape(e.description ? e.description : "");
    txt += "&Arguments=" + escape(e.arguments ? e.arguments : "Browser does not support exception arguments");
    txt += "&Type=" + escape(e.type ? e.type : "Browser does not support exception type");
    txt += "&name=" + escape(e.name ? e.name : e);
    //    txt += "&Platform=" + escape(navigator.platform);
    //    txt += "&UserAgent=" + escape(navigator.userAgent);
    if (typeof(rule_info) != "undefined")
    {
        txt += "&RuleName=" + escape(rule_info.name);
        txt += "&RuleID=" + escape(rule_info.id);
    }
    txt += "&stack=" + escape(e.stack ? e.stack : "Browser Does not support exception stacktrace");
    var datatype = null;
    if (KOBJ.in_bx_extention)
        datatype = "js";
    else
        datatype = "img";

    KOBJ.require("http://www.errorstack.com/submit?" + txt, {data_type: datatype});
};


KOBJ.location = function(part) {
    if (part == "href") return KOBJ.locationHref || KOBJ.document.location.href;
    if (part == "host") return KOBJ.locationHost || KOBJ.document.location.host;
    if (part == "protocol") return KOBJ.locationProtocol || KOBJ.document.location.protocol;
};

/* Hook to log data to the server */
KOBJ.logger = function(type, txn_id, element, url, sense, rule, rid) {
    var logger_url = KOBJ.callback_url + "?type=" +
                     type + "&txn_id=" + txn_id + "&element=" +
                     element + "&sense=" + sense + "&url=" + escape(url) + "&rule=" + rule;

    if (rid) logger_url += "&rid=" + rid;

    KOBJ.require(logger_url, {data_type: "other"});
};

/* Inject requested CSS via a style tag */
KOBJ.css = function(css) {
    var head = KOBJ.document.getElementsByTagName('head')[0];
    var style = KOBJ.document.createElement('style');
    var rules = KOBJ.document.createTextNode(css);

    style.type = 'text/css';
    style.id = 'KOBJ_stylesheet';

    var KOBJstyle = KOBJ.document.getElementById('KOBJ_stylesheet');
    if (KOBJstyle == null) {
        if (style.styleSheet) {
            style.styleSheet.cssText = rules.nodeValue;
        } else {
            style.appendChild(rules);
        }
        head.appendChild(style);
    } else {
        if (KOBJstyle.styleSheet) {
            KOBJstyle.styleSheet.cssText += rules.nodeValue;
        } else {
            KOBJstyle.appendChild(rules);
        }
    }
};

/* Logs data to the browsers windows console */
//alert("type" + typeof(KOBJ.log));
KOBJ.log = function(msg) {
    if (window.console != undefined && console.log != undefined) {
        console.log(msg);
    }
};


KOBJ.error = function(msg) {
    if (window.console != undefined && console.error != undefined) {
        console.error(msg);
    }
    else {
        KOBJ.log(msg);
    }
};

KOBJ.warning = function(msg) {
    if (window.console != undefined && console.warn != undefined) {
        console.warn(msg);
    }
    else {
        KOBJ.log(msg);
    }
};

KOBJ.trace = function(msg) {
    if (window.console != undefined && console.trace != undefined) {
        console.trace(msg);
    }
    else {
        KOBJ.log(msg);
    }
};

KOBJ.itrace = function(msg) {
    //    return;
    KOBJ.log(msg);
};

KOBJ.run_when_ready = function() {
    //see if page is already loaded (ex: tags planted AFTER dom ready) to know if we should wait for document onReady
    //this code block is adapted from swfObject code used for the same purpose
    if (typeof KOBJSandboxEnvironment === "undefined" || KOBJSandboxEnvironment !== true) { //sandbox bootstrap prevention
        if ((typeof document.readyState != "undefined" && document.readyState == "complete") ||
            ( typeof document.readyState == "undefined" && (document.getElementsByTagName("body")[0] || document.body))) {
            KOBJ.runit(); //dom ready
        } else {
            $KOBJ(KOBJ.runit); //dom not ready
        }
    }
};
