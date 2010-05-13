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
        KOBJ.load_style_sheet_link(this.url);
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
        return KOBJ.did_stylesheet_load(this.url);
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
    this.domain = "web";

    this.app_vars = {};

    // Closures that will execute after all resources and data is loaded
    this.pending_closures = {};
}


/*
 * This is called when a resource was loaded and the browser has
 * notified us.  If the resource is not for this application nothing
 * will happen.
 */
KrlApplication.prototype.external_resource_loaded = function(url) {
    var my_resources = this.external_resources || {};
    $KOBJ.each(my_resources, function (key, value) {
        if (key == url) {
            KOBJ.log("Resource marked as loaded:  " + url);
            value.did_load();
        }
    });
    // Execute and closures pending because they were waiting for resources.
    this.execute_pending_closures();
};

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


KrlApplication.prototype.page_vars_as_url = function() {
    var param_str = "";

    $KOBJ.each(this.page_params, function(k, v) {
        param_str += "&" + k + "=" + v;
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
        this.pending_closures[guid] = a_closure;
    }
    else
    {
        KOBJEventManager.event_fire_complete(this, guid);
        this.execute_pending_closures();
        a_closure;
    }

};

/*
 * Because closures can be delayed because of needed resources or data
 * we store them off.  This method will execute the pending closures.
 */
KrlApplication.prototype.execute_pending_closures = function()
{
    if ($KOBJ.isEmptyObject(this.pending_closures))
    {
        return;
    }

    $KOBJ.each(this.pending_closures, function(guid, the_closure) {
        the_closure();
        KOBJEventManager.event_fire_complete(this, guid);
    });

    this.pending_closures();
};

KrlApplication.prototype.run = function()
{
    this.load_data_sets();
    KOBJEventManager.add_out_of_bound_event(this, "pageview");
};


KrlApplication.prototype.fire_event = function(event, data, guid)
{
    this.load_data_sets();

    var url = [KOBJ.proto() +
               KOBJ.eval_host +
               KOBJ.kns_port,
        this.version,
        'event',
        this.domain,
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

    // If we have form data we need to transalate it.
    if(data["submit_data"] != null)
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
        var data_url = KOBJ.proto() + KOBJ.init_host + KOBJ.kns_port + "/js/datasets/" + KOBJ.site_id + "/";
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

