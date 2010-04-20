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

KrlExternalResource.prototype.load = function() {
    if(this.requested)
    {
        return;
    }
    if(this.type == "css") {
        KOBJ.load_style_sheet_link(this.url);
    }
    else
    {
        KOBJ.require(this.url);
    }
};

KrlExternalResource.prototype.is_loaded = function() {
    if(this.type == "css")
    {
        return KOBJ.did_stylesheet_load(this.url);
    }
    return this.loaded;
};


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
    this.app_id = app;
    this.external_resources = null;
    this.data_sets = null;
    this.closure = null;
    this.completed = false;
    this.delay_execution = false;
    this.config_data = {};
    this.server_init = {};
    this.page_params = {};
    this.version = "blue";
    this.domain = "web";
    this.event_type = "pageview";
    this.load_started = false;
}

// Example config
//KOBJ_config= {'rids':['a93x7'],
//    'a93x7:kynetx_app_version':'dev',
//    init:{
//        eval_host:'cs.kobj.net',
//        callback_host:'log.kobj.net'
//    }
//};


KrlApplication.prototype.external_resource_loaded = function(url) {
    var my_resources = this.external_resources || {};
    $K.each(my_resources,function (key,value) {
        if(key == url ) {
            KOBJ.log("Resource marked as loaded:  " +url);
            value.did_load();
        }
    });
};
/*
 Add what external resources we need for THIS app
 */
KrlApplication.prototype.add_external_resources = function(resources)
{
    var my_resources = this.external_resources || {};
    $K.each(resources,function (index) {
        var a_resource = resources[index];
        my_resources[a_resource.url] = a_resource;
    });
    this.external_resources = my_resources;
};


KrlApplication.prototype.data_loaded = function()
{
    return this.data_sets != null;
};

KrlApplication.prototype.reload = function()
{
    this.completed = false;
    this.load_started = false;
    this.closure = null;
    this.run();
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

    $K.each(this.page_params, function(k, v) {
        param_str += "&" + k + "=" + v;
    });


    return param_str;
};


KrlApplication.prototype.resources_loaded = function()
{
    var is_loaded = true;
    if(this.external_resources != null)
    {
        $K.each(this.external_resources, function(index,value) {
           if(!value.is_loaded()){
                is_loaded = false;
           } 
        });
    }
    return is_loaded;
};


KrlApplication.prototype.run = function()
{
    /*
     * We do not allow rules to execute multiple times unless we are told to reload their config.
     */
    if(this.completed) {
        return;
    }
    if (this.load_started)
    {
        // If the resources are not loaded check in again in a little while.
        if(!this.resources_loaded())
        {
            KOBJ.log("Resources are not loaded waiting...");
            var func = "KOBJ.get_application('" + this.app_id + "').run();";
            setTimeout(func,200);
            return;
        }
        // We need the data and the closure to event think about executing
        if (this.data_sets != null && this.closure != null) {
            // TODO: This is here to allow some other kind of call back to delay the execution of a rule
            // What really needs to happen is a way for people to have rules way for other resources like
            // I made for css and js 
            if(this.delay_execution)
            {
                return;
            }

            this.closure();
            this.load_started = false;
            this.closure = null;
            this.completed = true;
        }
    }
    else
    {
        this.load_started = true;
        this.load_data_sets();
        this.fire_callbacks();

        var url = [KOBJ.proto() +
                   KOBJ.eval_host +
               KOBJ.kns_port,
               this.version,
                   'event',
               this.domain,
               this.event_type,
               KOBJ.site_id,
               ((new Date).getTime())
              ].join("/");

        var params = ["caller=" + escape(KOBJ.location('href')),
              "referer="+ escape(KOBJ.document.referrer),
              "kvars=" + escape(KOBJ.kvars_json),
              "title=" + encodeURI(KOBJ.document.title)
                 ];

        var event_url = url + "?" +  params.join("&") + KOBJ.extra_page_vars_as_url() + this.page_vars_as_url();

        // OLD Way before events
//        var url = KOBJ.proto() + KOBJ.eval_host + KOBJ.kns_port + "/ruleset/eval/" + this.app_id;
//        var eval_url = url +
//                       "/" +
//                       ((new Date).getTime()) +
//                       ".js?caller=" +
//                       escape(KOBJ.location('href')) +
//                       "&referer=" + escape(KOBJ.document.referrer) +
//                       "&kvars=" + escape(KOBJ.kvars_to_json()) +
//                       "&title=" + escape(KOBJ.document.title) +
//                       KOBJ.extra_page_vars_as_url() +
//                       this.page_vars_as_url();

        KOBJ.require(event_url);
    }
};

/*
 Execute the app by loading its javascript
 */
KrlApplication.prototype.fire_callbacks = function()
{
    //TODO: Looks like callback_url is not used anywhere.
    //    KOBJ.callback_url = KOBJ.proto() + KOBJ.callback_host + KOBJ.kns_port + "/callback/" + KOBJ.siteIds();
};


/*
 Load up this applicaitons datasets
 */
KrlApplication.prototype.load_data_sets = function()
{
    var data_url = KOBJ.proto() + KOBJ.init_host + KOBJ.kns_port + "/js/datasets/" + KOBJ.site_id + "/";
    KOBJ.require(data_url);
};


/*
 Reloads this apps configuration or create a new application from the config.
 */
KrlApplication.prototype.update_from_config = function(a_config)
{
    // Save of the server configuration
    if (typeof(a_config.init) == 'object')
    {
        this.server_init = a_config.init;
    }


    // TODO: this is here for backwards compatablity.
    if (a_config.delayExecution) {
        this.delay_execution = true
    }

    // Search for page parameters.  They start with the app_id

    var my_self = this;
    $K.each(a_config, function(key, value) {
        if (key.match("^" + my_self.app_id)) {
            my_self.page_params[key] = value;
        }
        else
        {
            KOBJ.add_extra_page_var(key, value);
        }
    });
};

