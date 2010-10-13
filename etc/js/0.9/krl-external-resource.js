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

    KOBJ.loggers.resources.trace("Resource think it is loaded?  ", this.url, this.loaded);
    return this.loaded;
};


/*
 * Sets the state of this resource as loaded so it will not
 * be loaded a second time.
 */
KrlExternalResource.prototype.did_load = function() {
    this.loaded = true;
    this.requested = false;
    KOBJ.loggers.resources.trace("Resource was told it was loaded ", this.url);


    $KOBJ.each(KOBJ.applications, function(index, app) {
        app.execute_pending_closures();
    });
};
