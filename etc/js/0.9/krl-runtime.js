KOBJ.get_application = function(name) {
    return KOBJ['applications'][name];
};


// Example config
//KOBJ_config= {'rids':['a93x7'],
//    'a93x7:kynetx_app_version':'dev',
//    init:{
//        eval_host:'cs.kobj.net',
//        callback_host:'log.kobj.net'
//    }
//};

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

    $K.each(KOBJ['extra_page_vars'], function(k, v) {
        param_str += "&" + k + "=" + v;
    });

    return param_str;
};

KOBJ.add_config_and_run = function(app_config) {
    KOBJ.add_app_config(app_config);
    KOBJ.run_when_ready();
};

KOBJ.add_app_configs = function(app_configs) {

    /* if someone messed up and did not send us the right data just ignore the request */
    if (typeof(app_configs) == "unknown") {
        return;
    }

    $K.each(app_configs, function(index) {
        KOBJ.add_app_config(app_configs[index]);
    });
};

KOBJ.eval = function(app_config) {
    KOBJ.add_app_config(app_config);
    KOBJ.runit();
};

KOBJ.add_app_config = function(app_config) {

    /* if someone messed up and did not send us the right data just ignore the request */
    if (typeof(app_config) == "unknown" || !app_config.rids) {
        return;
    }

    /* Override what server to talk to if ask to in config */
    if (typeof(app_config.init) == 'object')
    {
        $K.each(app_config.init, function(k, v) {
            KOBJ[k] = v;
        });
    }

    /*
     Look at each application defined in the config and add or update the known application
     list.
     */
    var app_id_s = [];
    $K.each(app_config.rids, function(index, value) {
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
            // TODO: This is the old way need here for backwords  compat
            KOBJ[value] = {};
        }
        app_id_s[index] = app.app_id;
    });

    // TODO: Not sure why we would join all the ids Ask Phil about this
    KOBJ.site_id = app_id_s.join(";");
    KOBJ.callback_url = KOBJ.proto() + KOBJ.callback_host + KOBJ.kns_port + "/callback/" + KOBJ.site_id;
}
        ;

// This does not call the setTimeout Directly on the KOBJ.eval as it would block
// so we add a script element to be executed at a later time.
// DEPRECATED use app.reload_later
KOBJ.reload = function(delay) {
    $K.each(KOBJ.applications, function(name, id) {
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
        return $K.toJSON(kvars);
    }

};

/*
 Add all external resources request here.  We do this so that we can
 attempt to stop double loading. Each resource may have multiple applications
 using it.
 */
KOBJ.registerExternalResources = function(rid, resources) {
    KOBJ.log("registering dataset " + rid);
    var resource_array = [];
    $K.each(resources, function (url, options) {
        if (KOBJ.external_resources[url] == null)
        {
            var a_resource = new KrlExternalResource(url);
            a_resource.css_selector = options["selector"];
            a_resource.type = options["type"];
            KOBJ.external_resources[url] = a_resource;
            resource_array.push(a_resource);
            a_resource.load();
        }
    });
    var app = KOBJ.get_application(rid);
    app.add_external_resources(resource_array);
    app.run();
};

//start closure and data registration code
KOBJ.registerDataSet = function(rid, datasets) {
    KOBJ.log("registering dataset " + rid);
    var app = KOBJ.get_application(rid);
    app.data_sets = datasets;
    app.run();
    //    KOBJ.executeWhenReady(rid);
};

KOBJ.clearExecutionDelay = function(rid) {
    var app = KOBJ.get_application(rid);
    if (app != null)
    {
        app.delay_execution = false;
    }
    app.run();
};

KOBJ.registerClosure = function(rid, closure) {
    KOBJ.log("registering closure " + rid);
    var app = KOBJ.get_application(rid);
    app.closure = closure;
    app.run();
    //    KOBJ.executeWhenReady(rid);
};
//end closure and data registration code


KOBJ.runit = function() {

    /*
     We need to look at each and find out if it has been loaded. If not then doit.
     */
    $K.each(KOBJ.applications, function(index, app) {
        app.run();
    });
};


KOBJ.logVerify = function(txn, appid, cluster) {
    KOBJ.getwithimage(KOBJ.proto() + "kverify.appspot.com/log?txn=" + txn + "&appid=" + appid + "&cluster=" + cluster);
};

