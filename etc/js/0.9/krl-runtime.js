KOBJ.get_application = function(name) {
    return KOBJ['applications'][name];
};


KOBJ.add_extra_page_var = function(key, value)
{
    /* Ignore if the key is rids, init or has a : which means there is an app id */
    if (key.match(":") == null &&
        key != 'rids' &&
        key != 'init')
    {
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

KOBJ.configure_kynetx = function(config)
{
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
    if (typeof(app_config.init) == 'object')
    {
        $KOBJ.each(app_config.init, function(k, v) {
            KOBJ[k] = v;
        });
    }

    /*
     Look at each application defined in the config and add or update the known application
     list.
     */
    //    var app_id_s = [];
    $KOBJ.each(app_config.rids, function(index, value) {
        var app = KOBJ.get_application(value);
        if (app != null)
        {
            app.update_from_config(app_config);
        }
        else
        {
            app = new KrlApplication(value);
            app.update_from_config(app_config);
            KOBJ.applications[value] = app;
            // TODO: This is the old way need here for backwards  compat
            KOBJ[value] = {};
        }
        //        app_id_s[index] = app.app_id;
    });

    // TODO: Not sure why we would join all the ids Ask Phil about this
    //    KOBJ.site_id = app_id_s.join(";");
    KOBJ.callback_url = KOBJ.proto() + KOBJ.callback_host + KOBJ.kns_port + "/callback/" + KOBJ.site_id();
}
        ;


KOBJ.site_id = function() {
    var ids = [];
    $KOBJ.each(KOBJ.applications, function(key, value)
    {
        ids.push(key);
    });
    return ids.join(";");
}

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

KOBJ.kvars_to_json = function() {
    if (typeof(kvars) == "undefined" || typeof(kvars) != "object")
    {
        return "";
    }
    else
    {
        return $KOBJ.toJSON(kvars);
    }

};

KOBJ.named_resources = {
    "jquery_ui_js" : "https://kresources.kobj.net/jquery_ui/1.8/jquery_ui_1.8.2.js",
    "jquery_ui_darkness_css" : "https://kresources.kobj.net/jquery_ui/1.8/css/ui_darkness/jquery-ui-1.8.2.custom.css",
    "jquery_ui_lightness_css" : "https://kresources.kobj.net/jquery_ui/1.8/css/ui_lightness/jquery-ui-1.8.2.custom.css",
    "jquery_ui_smoothness_css" : "https://kresources.kobj.net/jquery_ui/1.8/css/ui_smoothness/jquery-ui-1.8.2.custom.css"
};

/*
 Add all external resources request here.  We do this so that we can
 attempt to stop double loading. Each resource may have multiple applications
 using it.
 */
KOBJ.registerExternalResources = function(rid, resources) {
    KOBJ.itrace("Registering external resources " + rid);
    var resource_array = [];
    $KOBJ.each(resources, function (url, options) {

        // We are doing a named resource not a url.
        if (url.indexOf("http") == -1)
        {
            url = KOBJ.named_resources[url];
        }
        
        if (url && KOBJ.external_resources[url] == null)
        {
            if (typeof(options["type"]) != "undefined")
            {
                var a_resource = new KrlExternalResource(url);
                a_resource.css_selector = options["selector"];
                a_resource.type = options["type"];
                KOBJ.external_resources[url] = a_resource;
                resource_array.push(a_resource);
                a_resource.load();
            }
        }
    });
    var app = KOBJ.get_application(rid);
    app.add_external_resources(resource_array);
};

/*
 * This is a shortcut way to register interest for an event for a given application
 * id.
 */
KOBJ.watch_event = function(event, selector, config)
{
    // Page views are special in that they do not have selectors
    var application = KOBJ.get_application(config["rid"]);
    if (event != "pageview") {
        KOBJEventManager.register_interest(event, selector, application, config);
    }
    else {
        KOBJEventManager.add_out_of_bound_event(application, "pageview");
    }
};

//start closure and data registration code
KOBJ.registerDataSet = function(rid, datasets) {
    //    KOBJ.log("registering dataset " + rid);
    var app = KOBJ.get_application(rid);
    app.store_data_sets(datasets);
};

KOBJ.clearExecutionDelay = function(rid) {
    var app = KOBJ.get_application(rid);
    if (app != null)
    {
        app.delay_execution = false;
    }
    app.run();
};

KOBJ.registerClosure = function(rid, data, guid) {
    //    KOBJ.log("Registering external resources " + rid);
    var app = KOBJ.get_application(rid);
    app.execute_closure(guid, data);
};

KOBJ.runit = function() {

    /*
     We need to look at each and find out if it has been loaded. If not then doit.
     */
    $KOBJ.each(KOBJ.applications, function(index, app) {
        app.run();
    });
};


KOBJ.logVerify = function(txn, appid, cluster) {
    KOBJ.getwithimage(KOBJ.proto() + "kverify.appspot.com/log?txn=" + txn + "&appid=" + appid + "&cluster=" + cluster);
};

