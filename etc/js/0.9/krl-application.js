/*  -----------------------------------------
 This is the object that manages a dynamic load of JS or CSS
 ------------------------------------------ */
function KrlExternalResource(url)
{
    this.url = url;
    this.loaded = false;
    this.requested = false;
    this.type = null;
    this.css_selector = null;
}

/*
 * Allow request a external resource to be loaded.   If it is already
 * request this will do nothing.
 */
KrlExternalResource.prototype.load = function() {
    if (this.requested)
    {
        return;
    }
    if (this.type == "css") {
        // Style sheets are hard to know if they loaded so just say they did.
        KOBJ.load_style_sheet_link(this.url);
        this.did_load();
    }
    else
    {
        KOBJ.require(this.url);
    }
};

/*
 * Checks to see if a resource is loaded. In the case of a javascript we will
 * be called back by the browser and will know for sure it was loaded but in
 * the case of css we only can check to see if the link is there.
 */
KrlExternalResource.prototype.is_loaded = function() {
    if (this.type == "css")
    {
        this.loaded = true;
        return this.loaded;
        //        return KOBJ.did_stylesheet_load(this.url);
    }
    return this.loaded;
};


/*
 * Sets the state of this resource as loaded so it will not
 * be loaded a second time.
 */
KrlExternalResource.prototype.did_load = function() {
    this.loaded = true;
    this.requested = false;

    $KOBJ.each(KOBJ.applications, function(index, app) {
        app.execute_pending_closures();
    });
};

/*  -----------------------------------------
 This is the object that manages a dataset in the runtime
 ------------------------------------------ */

function KrlDataSet(config)
{
    this.name = config["name"];
    this.data = config["data"];
}


/*  -----------------------------------------
 This is the object that manages a single application in the runtime.
 ------------------------------------------ */
function KrlApplication(app)
{
    // This applications id
    this.app_id = app;

    this.data_set_load_requested = false;

    // List of external resources needed for this app
    this.external_resources = null;

    // Data sets registered fro this app
    this.data_sets = null;

    this.delay_execution = false;
    this.page_params = {};

    // Defaults for request to server
    this.version = "blue";

    this.app_vars = {};

    // Closures that will execute after all resources and data is loaded
    this.pending_closures = {};
}


KrlApplication.prototype.store_data_sets = function(datasetdata)
{
    this.data_sets = datasetdata;
    // Execute and closures pending because they were waiting for resources.
    this.execute_pending_closures();
};

/*
 Add what external resources we need for THIS app
 */
KrlApplication.prototype.add_external_resources = function(resources)
{
    var my_resources = this.external_resources || {};
    $KOBJ.each(resources, function (index) {
        var a_resource = resources[index];
        my_resources[a_resource.url] = a_resource;
    });
    this.external_resources = my_resources;
};

/*
 * Tells us if the datasets have been loaded
 */
KrlApplication.prototype.is_data_loaded = function()
{
    return this.data_sets != null;
};

/*
 * This basicly resets the application and submits the pageview event again.
 */
KrlApplication.prototype.reload = function()
{
    KOBJEventManager.add_out_of_bound_event(this, "pageview");
};


/*
 Reload the application some time later.
 */
KrlApplication.prototype.reload_later = function(delay)
{
    var func = "KOBJ.get_application('" + this.app_id + "').reload();";
    setTimeout(func, delay);
};


KrlApplication.prototype.raise_event = function(event_name,parameters,other_app_id)
{
    var other_app = null;
    if(typeof(other_app_id) != "undefined" && other_app_id != null)
    {
        // If we are doing an event on another app it must be registered in order to
        // work.  So find it and add it if needed
        other_app = KOBJ.get_application(other_app_id);
        if(other_app == null)
        {
            other_app = KOBJ.add_app_config({rids: [other_app_id]});
            other_app = KOBJ.get_application(other_app_id);
            other_app.clone_app_params(this);
        }
    }
    else
    {
        other_app = this;
    }

    var all_data = {};

    if(typeof(parameters)  != "undefined" && parameters != null) {
        var found_data = [];
        $KOBJ.each(parameters, function(name,v) {
            found_data.push({name: name,value:v });
        });
        all_data["param_data"] = found_data;
    }

    KOBJEventManager.add_out_of_bound_event(other_app, event_name, true, all_data);

};



KrlApplication.prototype.clone_app_params = function(app) {
    var other_app_id = app.app_id;

    var myself = this;
    // right now we only need to know about app version
    $KOBJ.each(app.page_params, function(k, v) {
        // Because of an issue where people were passing in comma seperated list of app version we need
        // to apply a rule that if dev is found then that will be used if not found then the first one will be used.

        if (k == other_app_id + ":kynetx_app_version")
        {
          if(v.indexOf("dev") != -1)
          {
              myself.page_params[myself.app_id + ":kynetx_app_version"] = "dev" ;
          }
          else
          {
              myself.page_params[myself.app_id + ":kynetx_app_version"] = v.split(",")[0] ;
          }
        }
    });

}

KrlApplication.prototype.page_vars_as_url = function() {
    var param_str = "";
    var our_app_id = this.app_id;

    $KOBJ.each(this.page_params, function(k, v) {
        // Because of an issue where people were passing in comma seperated list of app version we need
        // to apply a rule that if dev is found then that will be used if not found then the first one will be used.
       
        if (k == our_app_id + ":kynetx_app_version")
        {
          if(v.indexOf("dev") != -1)
          {
              param_str += "&" + k + "=dev" ;
          }
          else
          {
              param_str += "&" + k + "=" + v.split(",")[0];
          }
        }
        else
        {
            param_str += "&" + k + "=" + v;
        }
    });


    return param_str;
};


/*
 * This will return true if all the resources are loaded.
 */
KrlApplication.prototype.are_resources_loaded = function()
{
    var is_loaded = true;
    if (this.external_resources != null)
    {
        $KOBJ.each(this.external_resources, function(index, value) {
            if (!value.is_loaded()) {
                is_loaded = false;
            }
        });
    }
    return is_loaded;
};

/*
 * Request a closure be executed. If the needed resources or data have not
 * been loaded then it is stored in a pending state to be executed when the
 * resources are loaded.
 */

KrlApplication.prototype.execute_closure = function(guid, a_closure)
{
    if (!this.is_data_loaded() || !this.are_resources_loaded())
    {
        KOBJ.itrace("Adding closure to pending list " + this.app_id + " : " + guid);
        this.pending_closures[guid] = a_closure;
    }
    else
    {
        KOBJ.itrace("Executing closure " + this.app_id + " : " + guid);
        KOBJEventManager.event_fire_complete(this, guid);
        this.execute_pending_closures();
        a_closure($KOBJ);
    }

};

/*
 * Because closures can be delayed because of needed resources or data
 * we store them off.  This method will execute the pending closures.
 */
KrlApplication.prototype.execute_pending_closures = function()
{
    if (!this.is_data_loaded() || !this.are_resources_loaded())
    {
        return;
    }

    $KOBJ.each(this.pending_closures, function(guid, the_closure) {
        the_closure($KOBJ);
        KOBJEventManager.event_fire_complete(this, guid);
    });

    this.pending_closures = {};

};

KrlApplication.prototype.run = function()
{
    this.load_data_sets();
    KOBJEventManager.add_out_of_bound_event(this, "pageview");
};


KrlApplication.prototype.fire_event = function(event, data, guid,domain)
{
    this.load_data_sets();


    var url = [KOBJ.proto() +
               KOBJ.eval_host +
               KOBJ.kns_port,
        this.version,
        'event',
        domain,
        event,
        this.app_id,
        guid
    ].join("/");


    var all_vars = {};
    // If the old global kvars are defined add them
    if (typeof(kvars) != "undefined" || typeof(kvars) == "object") {
        $KOBJ.extend(true, all_vars, kvars)
    }
    $KOBJ.extend(true, all_vars, this.app_vars)

    params = [];

    // Someone want to put some extra parameters on the url.  This is used, for example
    // in the case of page_content events.
    if (data["param_data"] != null)
    {        
        params = params.concat(data["param_data"]);
    }

    // If we have form data we need to transalate it.
    if (data["submit_data"] != null)
    {
        // In order for the engine to know how to deal with form fields we need
        // to translate from "name" to "app_id:name".

        var this_app = this;
        $KOBJ.each(data["submit_data"], function(index) {
            value = data["submit_data"][index];
            params.push({ "name"  : (this_app.app_id + ":" + value["name"]),
                "value" :  value["value"]});
        });
    }

    if (event != "pageview") {
        params.push({name: "element", value: data.selector});
    }


    params.push({name: "kvars", value: $KOBJ.toJSON(all_vars)});
    params.push({name: "caller", value: KOBJ.location('href')});
    params.push({name: "referer", value: KOBJ.document.referrer});
    params.push({name: "title", value: KOBJ.document.title});

    /*    var event_url = url + "?" +
     $KOBJ.param(params) +
     this.page_vars_as_url();
     */
    var event_url = url + "?" +
                    $KOBJ.param(params) +
                    KOBJ.extra_page_vars_as_url() +
                    this.page_vars_as_url();


    KOBJ.require(event_url);
};


/*
 Execute the app by loading its javascript
 */
KrlApplication.prototype.fire_callbacks = function(guid)
{
    //TODO: Looks like callback_url is not used anywhere.
    //    KOBJ.callback_url = KOBJ.proto() + KOBJ.callback_host + KOBJ.kns_port + "/callback/" + KOBJ.siteIds();
};


/*
 Load up this applications datasets
 */
KrlApplication.prototype.load_data_sets = function()
{
    // We only try to load the data one time.  This is because if data is returned it would be
    // Cached by the browser for 24 hours.  Any data not to be cached for 24 hours or more will
    // not come back in this call anyway.
    if (!this.is_data_loaded() && !this.data_set_load_requested)
    {
        var data_url = KOBJ.proto() + KOBJ.init_host + KOBJ.kns_port + "/js/datasets/" + this.app_id + "/?t=t" +
                        this.page_vars_as_url();
        KOBJ.require(data_url);
    }
};


/*
 Reloads this apps configuration or create a new application from the config.
 */
KrlApplication.prototype.update_from_config = function(a_config)
{
    // TODO: this is here for backwards compatablity.
    if (a_config.delayExecution) {
        this.delay_execution = true
    }

    // Search for page parameters.  They start with the app_id
    var my_self = this;
    $KOBJ.each(a_config, function(key, value) {
        if (key.match("^" + my_self.app_id)) {
            my_self.page_params[key] = value;
        }
        else
        {
            KOBJ.add_extra_page_var(key, value);
        }
    });
};

