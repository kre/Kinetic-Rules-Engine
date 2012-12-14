// This file is part of the Kinetic Rules Engine (KRE).
// Copyright (C) 2007-2011 Kynetx, Inc.
// Licensed under: GNU Public License version 2 or later

KOBJ.raise_event_action = function (uniq, event_name, config) {
    var app = KOBJ.get_application(config.rid);
    app.raise_event(event_name, config["parameters"], config["app_id"]);
};

KOBJ.page_content_event = function (uniq, label, selectors, config) {
    var app = KOBJ.get_application(config.rid);

    var found_data = {};

    $KOBJ.each(selectors, function(name, selector) {
        var result = $KOBJ(selector["selector"]);
        if (selector["type"] == "text")
            result = result.text();
        else if (selector["type"] == "form")
            result = result.val();
        else
            result = "invalid select type";


        found_data[name] = result;
    });
    found_data["label"] = label;


    var all_data = {"param_data":found_data};

    KOBJEventManager.add_out_of_bound_event(app, "page_content", true, all_data);

};


/*
 * This is a shortcut way to register interest for an event for a given application
 * id.
 */
KOBJ.watch_event = function(event, selector, config) {
    // Page views are special in that they do not have selectors
    var application = KOBJ.get_application(config["rid"]);
    if (event != "pageview") {
        KOBJEventManager.register_interest(event, selector, application, config);
    }
    else {
        KOBJEventManager.add_out_of_bound_event(application, "pageview");
    }
};


KOBJ.annotate_action = function(uniq, callback, config, name) {
    var ann = new KOBJAnnotateSearchResults(KOBJ.get_application(config.rid), name, config, callback);
    ann.annotate();
};

KOBJ.local_annotate_action = function(uniq, callback, config,name) {
    var ann = new KOBJAnnotateLocalSearchResults(KOBJ.get_application(config.rid), name, config, callback);
    ann.annotate();
};
