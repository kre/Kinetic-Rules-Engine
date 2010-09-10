KOBJDomWatch = {};

/*
 This hash will look like
 { ".class" : { pre_hash: 94949494, lastchecktime: 23343333}
 */
KOBJDomWatch.selector_data = {};


KOBJDomWatch.watch = function(selector, callback, app, change_delay) {
    KOBJ.loggers.domwatch.trace("Adding to Watcher" + selector);
    if (KOBJDomWatch.selector_data[selector] == null) {
        KOBJDomWatch.selector_data[selector] = {
            pre_hash :  KOBJEventManager.content_change_hashcode(selector),
            last_check: new Date().valueOf(),
            apps: {}
        };
    }

    if (KOBJDomWatch.selector_data[selector]["apps"][app.app_id] == null) {
        if (typeof(change_delay) == "undefined") {
            change_delay = 1000;
        }
        KOBJDomWatch.selector_data[selector]["apps"][app.app_id] = {
            app:app,
            callbacks: [callback],
            change_delay: change_delay
        };
    }
    else {
        KOBJDomWatch.selector_data[selector]["apps"][app.app_id]["callbacks"].push(callback);
    }
};

KOBJDomWatch.reset_selector_hash = function() {
    $KOBJ.each(KOBJDomWatch.selector_data, function(selector, selector_data) {
        KOBJ.loggers.domwatch.trace("Selector hash is B "  + selector + " - " + selector_data.pre_hash);
        selector_data.pre_hash = KOBJEventManager.content_change_hashcode(selector);
        KOBJ.loggers.domwatch.trace("Selector hash is A " + selector + " - "  + selector_data.pre_hash);
    });
};


KOBJDomWatch.timeout_watcher = function() {
    KOBJ.loggers.domwatch.trace("Running new domwatch");
    $KOBJ.each(KOBJDomWatch.selector_data, function(selector, selector_data) {
        current_hash = KOBJEventManager.content_change_hashcode(selector);
        KOBJ.loggers.domwatch.trace("Old hash: " + selector_data.pre_hash + " new Hash : " + current_hash);
        if (current_hash != selector_data.pre_hash) {
            $KOBJ.each(selector_data["apps"], function(app_id, app_data) {
                var cnt = 1;
                $KOBJ.each(app_data["callbacks"], function(index) {
                    KOBJ.loggers.domwatch.trace("Fire call back for " + app_id + " " + cnt);
                    this();
                    KOBJ.loggers.domwatch.trace("Call Back Completed " + app_id + " " + cnt);
                });
            });
        }
    });
    $KOBJ(document).ready(function() {
            KOBJDomWatch.reset_selector_hash();
            KOBJ.loggers.domwatch.trace("Setting new timer");
            setTimeout(KOBJDomWatch.timeout_watcher, 500);

    });
};

setTimeout(KOBJDomWatch.timeout_watcher, 500);
/*
 Some how need to know if a selector is a child of another selector. So that the parents will file the children callback.

 */