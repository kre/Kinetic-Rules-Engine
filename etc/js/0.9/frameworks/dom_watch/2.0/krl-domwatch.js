KOBJDomWatch = {};

KOBJDomWatch.scopes = {};

KOBJDomWatch.get_dom_watch = function(name,condition_callback,change_delay) {
    if (typeof(name) == "undefined") {
        name = "general";
    }

    if(typeof(condition_callback) == "undefined" || condition_callback == null)
    {
        condition_callback = function() { return true; };
    }

    var watcher = KOBJDomWatch.scopes[name];
    if (watcher != null) {
         KOBJ.loggers.domwatch.trace("Dom watch already exist for ",name);
        return watcher;
    }
    watcher = new KOBJDomWatchWatcher(name,condition_callback,change_delay);
    KOBJDomWatch.scopes[name] = watcher;
    // Start it up
    KOBJ.loggers.domwatch.trace("Timeout set to  " +  watcher.change_deplay);
    setTimeout(function() { watcher.timeout_watcher(); }, watcher.change_deplay);

    return watcher;
};


function KOBJDomWatchWatcher(name, condition_callback, change_delay) {
    this.name = name;
    this.condition_callback = condition_callback;
    if(typeof(change_delay) != "undefined")
    {
        this.change_deplay =  change_delay;
    }
    else
    {
        this.change_deplay =  500;
    }
    /*
     This hash will look like
     { ".class" : { pre_hash: 94949494, lastchecktime: 23343333}
     */
    this.selector_data = {};
}

KOBJDomWatchWatcher.prototype.dwatch = function(selector, callback, app) {
    KOBJ.loggers.domwatch.trace("Adding to Watcher ", this.name, selector);
    if (this.selector_data[selector] == null) {
        this.selector_data[selector] = {
            pre_hash :  KOBJEventManager.content_change_hashcode(selector),
            last_check: new Date().valueOf(),
            apps: {}
        };
    }

    if (this.selector_data[selector]["apps"][app.app_id] == null) {
        this.selector_data[selector]["apps"][app.app_id] = {
            app:app,
            callbacks: [callback]
        };
    }
    else {
        this.selector_data[selector]["apps"][app.app_id]["callbacks"].push(callback);
    }
    var myself = this;
};

KOBJDomWatchWatcher.prototype.reset_selector_hash = function() {
    var myself = this;
    $KOBJ.each(this.selector_data, function(selector, selector_info) {
        KOBJ.loggers.domwatch.trace("Selector hash is B " + selector + " - " + selector_info.pre_hash);
        selector_info.pre_hash = KOBJEventManager.content_change_hashcode(selector);
        KOBJ.loggers.domwatch.trace("Selector hash is A " + selector + " - " + selector_info.pre_hash);
    });
};


KOBJDomWatchWatcher.prototype.timeout_watcher = function() {
    var myself = this;
    KOBJ.loggers.domwatch.trace("Running new domwatch");
    $KOBJ.each(this.selector_data, function(selector, selector_info) {
        current_hash = KOBJEventManager.content_change_hashcode(selector);
        KOBJ.loggers.domwatch.trace("Old hash: " + selector_info.pre_hash + " new Hash : " + current_hash);
        if (current_hash != selector_info.pre_hash) {
            // If there is a conditional call back then we need to have it say true in order
            // to say something changed.
            if (myself.condition_callback && myself.condition_callback()) {
                $KOBJ.each(selector_info["apps"], function(app_id, app_data) {
                    var cnt = 1;
                    $KOBJ.each(app_data["callbacks"], function(index) {
                        KOBJ.loggers.domwatch.trace("Fire call back for " + app_id + " " + cnt);
                        this();
                        KOBJ.loggers.domwatch.trace("Call Back Completed " + app_id + " " + cnt);
                    });
                });
            }
        }
    });
    $KOBJ(KOBJ.document).ready(function() {
        // If the condition did not say something changed then we need to not reset so we can
        // try again next time.
        if (myself.condition_callback && myself.condition_callback()) {
            myself.reset_selector_hash();
        }
        KOBJ.loggers.domwatch.trace("Timeout set to  " +  myself.change_deplay);
        setTimeout(function() { myself.timeout_watcher(); }, myself.change_deplay);

    });
};

