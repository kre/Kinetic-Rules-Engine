// This file is part of the Kinetic Rules Engine (KRE).
// Copyright (C) 2007-2011 Kynetx, Inc.
// Licensed under: GNU Public License version 2 or later

KOBJ.past_apps = [];
KOBJ.pending_apps = [];
KOBJ.rid_count = 0;

KOBJ.get_application = function(name) {
    return KOBJ['applications'][name];
};


KOBJ.add_extra_page_var = function(key, value) {
    /* Ignore if the key is rids, init or has a : which means there is an app id */
    if (key.match(":") == null &&
            key != 'rids' &&
            key != 'init') {
        KOBJ['extra_page_vars'][key] = value;
    }
};

KOBJ.extra_page_vars_as_url = function() {
    var param_str = "";

    $KOBJ.each(KOBJ['extra_page_vars'], function(k, v) {
        param_str += "&" + k + "=" + v;
    });

    return param_str;
};

KOBJ.add_config_and_run = function(app_config) {
    //    alert("adding config" +app_config);
    KOBJ.add_app_config(app_config);
    // Only execute apps passed in not every single one registered.
    $KOBJ.each(app_config.rids, function(index, value) {
        var app = KOBJ.get_application(value);
        app.reload();
    });
};

KOBJ.add_configs_and_run = function (app_configs) {
	/* if someone messed up and did not send us the right data just ignore the request */
    if (typeof(app_configs) == "unknown") {
        return;
    }

    $KOBJ.each(app_configs, function(index) {
        KOBJ.add_config_and_run(app_configs[index]);
    });
};

KOBJ.add_app_configs = function(app_configs) {

    /* if someone messed up and did not send us the right data just ignore the request */
    if (typeof(app_configs) == "unknown") {
        return;
    }

    $KOBJ.each(app_configs, function(index) {
        KOBJ.add_app_config(app_configs[index]);
    });
};

KOBJ.eval = function(app_config) {
    KOBJ.log("!!!!! KOBJ.eval will be deprecated soon please change to. KOBJ.add_app_configs({config});KOBJ.get_application('appid').reload();");
    KOBJ.add_app_config(app_config);
    // Only execute apps passed in not every single one registered.

    $KOBJ.each(app_config.rids, function(index, value) {
        var app = KOBJ.get_application(value);
        app.reload();
    });
};

KOBJ.configure_kynetx = function(config) {
    /* Override what server to talk to if ask to in config */
    $KOBJ.each(config, function(k, v) {
        KOBJ[k] = v;
    });
}
        ;

KOBJ.add_app_config = function(app_config) {

    /* if someone messed up and did not send us the right data just ignore the request */
    if (typeof(app_config) == "unknown" || !app_config.rids) {
        return;
    }

    /* Override what server to talk to if ask to in config */
    if (typeof(app_config.init) == 'object') {
        $KOBJ.each(app_config.init, function(k, v) {
            KOBJ[k] = v;
        });
    }

    app_config.serial_nos = app_config.serial_nos || [];

    /*
     Look at each application defined in the config and add or update the known application
     list.
     */
    //    var app_id_s = [];
    $KOBJ.each(app_config.rids, function(index, value) {
      var rid = value;
      var serial_no = app_config.serial_nos[index] || '';

      var new_app_name = '';

      if (typeof(KOBJ[rid]) === "object") { // already defined
	new_app_name = rid + '_' + serial_no;
      } else {
	new_app_name = rid;
      }


      var app = KOBJ.get_application(new_app_name);
      if (app != null) {
        app.update_from_config(app_config);
      } else {
        app = new KrlApplication(rid);
	app.update_from_config(app_config);
	app.secondary_run = (serial_no === '') ? false : true;
	app.app_name = new_app_name;
	KOBJ.applications[new_app_name] = app;
	// TODO: This is the old way need here for backwards  compat
	KOBJ[new_app_name] = {};
      }
      KOBJ.pending_apps.push(new_app_name);

        //        app_id_s[index] = app.app_id;
    });

    // TODO: Not sure why we would join all the ids Ask Phil about this
    //    KOBJ.site_id = app_id_s.join(";");
    KOBJ.callback_url = KOBJ.proto() + KOBJ.callback_host + KOBJ.kns_port + "/callback/" + KOBJ.site_id();
}
        ;


// This does not call the setTimeout Directly on the KOBJ.eval as it would block
// so we add a script element to be executed at a later time.
// DEPRECATED use app.reload_later
KOBJ.reload = function(delay) {
    KOBJ.log("!!!!! KOBJ.reload will be deprecated soon please change to. KOBJ.get_application('appid').reload();");
    $KOBJ.each(KOBJ.applications, function(name, id) {
        var app = KOBJ.get_application(name);
        app.reload_later(delay);
    });
};

KOBJ.named_resources = {

    "jquery_ui_js" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/jquery-ui-1.8.4.custom.min.js",
    "jquery_ui_darkness_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_darkness/jquery-ui-1.8.4.custom.css",
    "jquery_ui_lightness_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_lightness/jquery-ui-1.8.4.custom.css",
    "jquery_ui_smoothness_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_smoothness/jquery-ui-1.8.4.custom.css",
    "jquery_ui_start_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_start/jquery-ui-1.8.4.custom.css",
    "jquery_ui_redmond_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_redmond/jquery-ui-1.8.4.custom.css",
    "jquery_ui_sunny_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_sunny/jquery-ui-1.8.4.custom.css",
    "jquery_ui_overcast_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_overcast/jquery-ui-1.8.4.custom.css",
    "jquery_ui_le_frog_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_le_frog/jquery-ui-1.8.4.custom.css",
    "jquery_ui_flicker_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_flicker/jquery-ui-1.8.4.custom.css",
    "jquery_ui_pepper_grinder_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_pepper_grinder/jquery-ui-1.8.4.custom.css",
    "jquery_ui_eggplan_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_eggplan/jquery-ui-1.8.4.custom.css",
    "jquery_ui_dark_hive_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_dark_hive/jquery-ui-1.8.4.custom.css",
    "jquery_ui_cupertino_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_cupertino/jquery-ui-1.8.4.custom.css",
    "jquery_ui_south_street_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_south_street/jquery-ui-1.8.4.custom.css",
    "jquery_ui_blitzer_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_blitzer/jquery-ui-1.8.4.custom.css",
    "jquery_ui_humanity_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_humanity/jquery-ui-1.8.4.custom.css",
    "jquery_ui_hot_sneaks_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_hot_sneaks/jquery-ui-1.8.4.custom.css",
    "jquery_ui_excite_bike_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_excite_bike/jquery-ui-1.8.4.custom.css",
    "jquery_ui_vader_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_vader/jquery-ui-1.8.4.custom.css",
    "jquery_ui_dot_lov_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_dot_lov/jquery-ui-1.8.4.custom.css",
    "jquery_ui_mint_choc_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_mint_choc/jquery-ui-1.8.4.custom.css",
    "jquery_ui_black_tie_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_black_tie/jquery-ui-1.8.4.custom.css",
    "jquery_ui_trontastic_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_trontastic/jquery-ui-1.8.4.custom.css",
    "jquery_ui_swanky_purse_css" : "https://kns-resources.s3.amazonaws.com/jquery_ui/1.8/css/ui_swanky_purse/jquery-ui-1.8.4.custom.css"
};

/*
 Add all external resources request here.  We do this so that we can
 attempt to stop double loading. Each resource may have multiple applications
 using it.
 */
KOBJ.registerExternalResources = function(rid, resources) {
     KOBJ.loggers.resources.trace("Registering external resources ", rid, resources);
     var resource_array = [];
     $KOBJ.each(resources, function (url, options) {

         var name = null;
         // We are doing a named resource not a url.
         if (url.indexOf("http") == -1 || url.match(/^\[[a-zA-Z0-9 ]*\]/)) {
             // TODO : Remove this when we can do alias hack to get GM Resoruces to work
             if (url.match(/^\[[a-zA-Z0-9 ]*\]/)) {
                 name = url.match(/\[[a-zA-Z0-9 ]*\]/)[0]
                 name = name.substring(1, name.length - 1);
                 url = url.substring(url.indexOf("]") + 1, url.length);

             }
             else
             {
                 url = KOBJ.named_resources[url];
             }
         }

         url = KOBJ.proto() + url.substr(url.indexOf(":") + 3, url.length);

         if (url && KOBJ.external_resources[url] == null) {
             if (typeof(options["type"]) != "undefined") {
                 var a_resource = new KrlExternalResource(url);
                 a_resource.name = name;
                 a_resource.css_selector = options["selector"];
                 a_resource.type = options["type"];
                 KOBJ.external_resources[url] = a_resource;
                 resource_array.push(a_resource);
                 a_resource.load();
             }
         }
         else {
             resource_array.push(KOBJ.external_resources[url]);
         }
     });
     var app = KOBJ.get_application(rid);
     if (app) {
         app.add_external_resources(resource_array);
     }
     else {
         KOBJ.add_app_config({rids:[rid]});
         var app = KOBJ.get_application(rid);
         app.add_external_resources(resource_array);
         app.load_data_sets();
//         KOBJ.error("Ignoring Resource registration for app " + rid + " App was not registered with runtime");
     }
 };




//start closure and data registration code
KOBJ.registerDataSet = function(rid, datasets) {
    //    KOBJ.log("registering dataset " + rid);
    var app = KOBJ.get_application(rid);
    if (app) {
        app.store_data_sets(datasets);
    }
    else {
        KOBJ.error("Ignoring Dataset for app " + rid + " App was not registered with runtime");
    }
  console.log("Decrementing RID counter");
  if(KOBJ.rid_count > 0) { KOBJ.rid_count--; } // stop at 0
  if(KOBJ.rid_count == 0) {
    KOBJ.runit();
  }
};

KOBJ.clearExecutionDelay = function(rid) {
    var app = KOBJ.get_application(rid);
    if (app != null) {
        app.delay_execution = false;
    }
    app.run();
};

function getRandomInt (min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
}


KOBJ.registerClosure = function(rid, data, guid) {
    //    KOBJ.log("Registering external resources " + rid);

  console.log("Registering closure for " + rid);

    // [PJW] Hacking this to make each closure registration look like a
    // new application... The first one needs to be just the RID

  var app_id = '';
  var serial_no = '';
  if (typeof(KOBJ[rid]) === "object") { // already defined
    serial_no = getRandomInt(0,99999999);
    app_id = rid + '_' + serial_no;
  } else {
    app_id = rid;
    console.log("Incrementing RID counter");
    // used to ensure all data loaded
    KOBJ.rid_count++;
  }

  console.log("  Using app_id " + app_id );

  var app = KOBJ.get_application(app_id);
  // If we do not have the app then ignore the result

  // the exec_id is used to store pending closures. Randomize to avoid overwriting previous closures
  var exec_id = guid + getRandomInt(0,99999999);
  if (app) {
    app.execute_closure(exec_id, data);
  } else {
    KOBJ.add_app_config({rids:[rid], serial_nos:[serial_no]});
    var app = KOBJ.get_application(app_id);
    app.execute_closure(exec_id, data);
    app.load_data_sets();
//        KOBJ.error("Ignoring Closure for app " + rid + " App was not registered with runtime")
  }

};

KOBJ.runit = function() {

    /*
     We need to look at each and find out if it has been loaded. If not then doit.
     */
    console.log("Running pending_apps");
    $KOBJ.each(KOBJ.pending_apps, function(index, app_name) {
      console.log("Running " + app_name);
      KOBJ.applications[app_name].execute_pending_closures();
      KOBJ.past_apps.push(app_name);
    });
    KOBJ.pending_apps = [];
};


KOBJ.logVerify = function(txn, appid, cluster) {
    KOBJ.getwithimage(KOBJ.proto() + KOBJ.kverify_domain+"/log?txn=" + txn + "&appid=" + appid + "&cluster=" + cluster);
};

KOBJ.proto = function() {
    if ("http:" != KOBJ.location('protocol') && "https:" != KOBJ.location('protocol')) {
        return "https://";
    }
    return (("https:" == KOBJ.location('protocol')) ? "https://" : "http://")
};

KOBJ.proto_elevate = function(src){
	if( KOBJ.location('protocol') == "https:" ) {
		//if running on https, make sure the resource url is https also.
		return "https://" + src.substr(src.indexOf(":") + 3, src.length);
	}
	return src;
};

//this method is overridden in sandboxed environments
KOBJ.require = function(url, callback_params) {
    // This function is defined if we are in a browser plugin
    if (typeof(callback_params) == "undefined") {
        callback_params = {};
    }
    if (KOBJ.in_bx_extention && callback_params.data_type == "other") {
        // This is here for backwards compat.  People need to chagne to KOBJ.async_url_request
        if(typeof(KOBJ.async_url_request) != "undefined")
            KOBJ.async_url_request(url, "KOBJ.url_loaded_callback", callback_params);
        else
          async_url_request(url, "KOBJ.url_loaded_callback", callback_params);
    } else if (KOBJ.in_bx_extention) {
        var params = {};
        if (typeof(callback_params) != "undefined") {
            params = $KOBJ.extend({data_type : "js"}, callback_params, true);
        }
        if(typeof(KOBJ.async_url_request) != "undefined")
            KOBJ.async_url_request(url, "KOBJ.url_loaded_callback", params);
        else
          async_url_request(url, "KOBJ.url_loaded_callback", params);
    }
    else if (!KOBJ.in_bx_extention && callback_params.data_type == "img") {
        var r = document.createElement("img");
        // This is the max url for a get in IE7  IE6 is 488 so we will break on ie6
        r.src = url.substring(0, KOBJ.max_url_length());
        //  We need to change to the protcol of the location url so that we do not
        // get security errors.
        r.src = KOBJ.proto_elevate(r.src);
        var body = document.getElementsByTagName("body")[0] ||
                document.getElementsByTagName("frameset")[0];
        if (body == null) {
            KOBJ.error("Document body missing.  Browser is reloading page.");
            return;
        }
        body.appendChild(r);
    }
    else {
        var r = document.createElement("script");
        // This is the max url for a get in IE7  IE6 is 488 so we will break on ie6
        r.src = url.substring(0, KOBJ.max_url_length());
        //  We need to change to the protcol of the location url so that we do not
        // get security errors.
        r.src = KOBJ.proto_elevate(r.src);
        r.type = "text/javascript";
        r.onload = r.onreadystatechange = KOBJ.url_loaded_callback;
        var body = document.getElementsByTagName("body")[0] ||
                document.getElementsByTagName("frameset")[0];
        if (body == null) {
            //  This happens sometime in firefox where for some reason the body of the page goes bye bye
            //  I think this is caused by the browser still running the javascript for the prior page
            KOBJ.error("Document body missing.  Browser is reloading page.");
            return;
        }
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
    } else if (attr == 'selector') {
        elem = name;
    } else {
        elem = name;
    }
    if (type == 'click') {
//        alert("You are calling me with " + elem);
        $KOBJ(elem).live("click", function(e1) {
            var tgt = $KOBJ(this);
            var b = tgt.attr('href') || '';
            KOBJ.logger("click", txn_id, name, b, sense, rule, rid);
//            if (b) {
//                tgt.attr('href', '#KOBJ');
//            }  // # gets replaced by redirect
            return true;
        });

    } else if (type == 'change') {
        $KOBJ(elem).live("change", function(e1) {
            KOBJ.logger("change", txn_id, name, '', sense, rule, rid);
            return true;
        });
    }

};

// Shortcut to do ajax request either sync or not.  If async then you must provide
// a call back function.  If sync the data will be returned at the end of the call.
KOBJ.ajax = function(url, async_request, callback) {
    var result_data = null;
    $KOBJ.ajax({
        url:    url ,
        success: function(result) {
            if (!async_request) {
                result_data = result;
            }
            else {
                callback(result);
            }
        },
        async:   async_request
    });

    return result_data;
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

/*
 Called when one of our script is loaded including css links
 */
KOBJ.url_loaded_callback = function(loaded_url, response, callback_params) {


       if (typeof(loaded_url) != "undefined" && typeof(callback_params) != "undefined") {
//        KOBJ.log("Call back data type was " + callback_params.data_type);

           if (callback_params.base64 != null) {
               response = Base64.decode(response);
           }

           switch (callback_params.data_type) {
               case  "js":
//                 KOBJ.log("Because js eval it now");
                   eval(response);
                   break;
               case  "css":
//                KOBJ.log("Because css head it now");
                   $KOBJ("head").append($KOBJ("<style>").text(response));
                   break;
               case "other":
                   if (KOBJ.external_resources[loaded_url] != null) {
                       KOBJ.external_resources[loaded_url].data = response;
                   }
                   break;
           }

           if (KOBJ.external_resources[loaded_url] != null) {
               KOBJ.external_resources[loaded_url].did_load();
           }
       }
       else {
           var done = false;
           if (!done && (!this.readyState || this.readyState === "loaded" || this.readyState === "complete")) {
               done = true;
               var url = null;
               // This would happen if we were in a browser sandbox.
               //            if (typeof(loaded_url) == "undefined")
               //            {
               if (typeof(this.src) != "undefined") {
                   url = this.src;
               }
               else {
                   url = this.href;
               }
               if (url == null) {
                   return;
               }


               if (KOBJ.external_resources[url] != null) {
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


KOBJ.siteIds = function() {
    return KOBJ.site_id();
};


KOBJ.site_id = function() {
    var ids = [];
    $KOBJ.each(KOBJ.applications, function(key, value) {
        ids.push(key);
    });
    return ids.join(";");
};


KOBJ.errorstack_submit = function(key, e, rule_info) {
    try {


        // No key the ignore.
        if (key == null) {
            return;
        }
        var prefix_text = "_s=" + key;

        prefix_text += "&_id=" + KOBJEventManager.eid();

        if (KOBJ.in_bx_extention)
            prefix_text += "&_r=json";
        else
            prefix_text += "&_r=img";


        var browser_info = KRLSnoop.browser_info();
        var exception_info = KRLSnoop.exception_info(e);


        var st_url = {};

        st_url.Msg = escape(KOBJ.safe_substring(exception_info.message, 500));
        st_url.ScriptURL = escape(KOBJ.safe_substring(exception_info.script_url, 500));
        st_url.UserAgent = escape(browser_info.nav.userAgent);
        st_url.URL = escape(KOBJ.safe_substring(KOBJ.document.location.href, 500));
        st_url.Line = exception_info.lineNumber;
        st_url.Description = escape(KOBJ.safe_substring(exception_info.description, 500));
        st_url.Arguments = escape(KOBJ.safe_substring(exception_info.arguments, 500));
        st_url.Type = escape(exception_info.type);
        st_url.name = escape(exception_info.name);
        if (typeof(rule_info) != "undefined") {
            st_url.RuleName = escape(rule_info.name);
            st_url.RuleID = escape(rule_info.id);
        }
        st_url.stack = escape(KOBJ.safe_substring(exception_info.stack, 500));
        st_url.Platform = escape("JRT-" + window['kobj_ts']);
        st_url.AgtAppCodeName = escape(browser_info.nav.appCodeName);
        st_url.AgtAppName = escape(browser_info.nav.appName);
        st_url.AgtAppVer = escape(browser_info.nav.appVersion);
        st_url.AgtLang = escape(browser_info.nav.language);
        st_url.AgtCookiesEnable = escape(browser_info.nav.cookiesEnabled);
        st_url.AgtSysLanguage = escape(browser_info.nav.systemLanguage);
        st_url.AgtUsrLanguage = escape(browser_info.nav.userLanguage);
        st_url.ScrAHeight = escape(browser_info.screen.availHeight);
        st_url.ScrColorDepth = escape(browser_info.screen.colorDepth);
        st_url.ScrHeight = escape(browser_info.screen.height);
        st_url.ScrWidth = escape(browser_info.screen.width);
        st_url.ScrAWidth = escape(browser_info.screen.availWidth);
        st_url.ScrPixDep = escape(browser_info.screen.pixelDepth);

        var datatype = null;

        if (KOBJ.in_bx_extention)
            datatype = "js";
        else
            datatype = "img";

        // If the url is to long loop over it and keep calling require with each part.
        var urls = KOBJ.url_from_hash(st_url, 200);
        $KOBJ.each(urls, function(index) {
            KOBJ.require("http://www.errorstack.com/submit?" + prefix_text + urls[index], {data_type: datatype});
        });
    }
    catch(badex) {
        KOBJ.loggers.general.error("Could not submit to errorstack ", e, badex);
    }
};

KOBJ.location = function(part) {
  try {
    if (part == "href") return KOBJ.locationHref || KOBJ.document.location.href;
    if (part == "host") return KOBJ.locationHost || KOBJ.document.location.host;
    if (part == "protocol") return KOBJ.locationProtocol || KOBJ.document.location.protocol;
    if (part == "hash") return KOBJ.locationHash || KOBJ.document.location.hash;
  } catch (e) { return part + "-unavailable"; }
};

/* Hook to log data to the server */
KOBJ.logger = function(type, txn_id, element, url, sense, rule, rid) {
    var logger_url = KOBJ.callback_url + "?type=" +
            type + "&txn_id=" + txn_id + "&element=" +
            element + "&sense=" + sense + "&url=" + escape(url) + "&rule=" + rule;

    if (rid) {
        logger_url += "&rid=" + rid;
        var app = KOBJ.get_application(rid);
        if (app != null)
            logger_url += app.page_vars_as_url();
    }

    KOBJ.require(logger_url, {data_type: "other"});
};


/* Logs data to the browsers windows console */
//alert("type" + typeof(KOBJ.log));
KOBJ.log = function() {
    KOBJ.loggers.general.log(KOBJ.log4js.Level.INFO, arguments);
};

KOBJ.error = function() {
    KOBJ.loggers.general.log(KOBJ.log4js.Level.ERROR, arguments);
};

KOBJ.warning = function() {
    KOBJ.loggers.general.log(KOBJ.log4js.Level.WARN, arguments);
};

KOBJ.trace = function() {
    KOBJ.loggers.general.log(KOBJ.log4js.Level.TRACE, arguments);
};

KOBJ.itrace = function() {
    KOBJ.loggers.general.log(KOBJ.log4js.Level.TRACE, arguments);
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
