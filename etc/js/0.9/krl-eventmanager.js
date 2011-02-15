// Define a local copy of jQuery
KOBJEventManager = {};

/*
 * This generates a uniq id for event groups.
 */
KOBJEventManager.eid = function() {
    var adate = new Date();
    return adate.valueOf() + (Math.random() + "").substring(2);
};

KOBJEventManager.current_fires = {};
KOBJEventManager.events = { };
KOBJEventManager.content_changes_running = {};
KOBJEventManager.content_change_hashcodes = {};


// List of guids currently running for the content change event.
// If there are any in the list we do not start the timer until they are all done.
// We also need to reset the content hash value after they have all run so that we
// do not fire again prematurely.

// Change Current fires to  look
// {"aax":
//      {app:application,
//          events:
//              {"pageview":
//                  {data}
//              }
//      }
// }

// Second list of for direct guid access.
// This is a mapping of guid to app and event
// 'aaaddd':{app:application,"event":"pageview","selector":"#id"}
KOBJEventManager.guid_list = {

};

/*
 * This is the notification call back to let the event manager know that
 * an event was sent to the server and has come back.
 */
KOBJEventManager.event_fire_complete = function(guid,app)
{
    KOBJ.loggers.events.trace("Event Fire Complete " + guid);
    var guid_info = KOBJEventManager.guid_list[guid];

    if(!guid_info)
    {
        KOBJ.error("Event transaction id unknown ignoring for: " + app.app_id);
        return;
    }

    if(guid_info.app.app_id != app.app_id) {
        KOBJ.error("Event transaction id was not registered to app: " + app.app_id + " - " + guid);
        return;
    }

    delete KOBJEventManager.current_fires[guid_info.app.app_id][guid_info.event][guid_info.selector][guid];
    delete KOBJEventManager.guid_list[guid];

    if (guid_info.event == "content_change")
    {
        delete KOBJEventManager.content_changes_running[guid];
        KOBJEventManager.update_content_change_hash();
        if ($KOBJ.isEmptyObject(KOBJEventManager.content_changes_running))
        {
            setTimeout(KOBJEventManager.content_change_checker, 500);
        }
    }
};


/*
 * Check if the event is a dup.  By that I mean no app can have to events of the same
 * type in the queue at any time.
 */
KOBJEventManager.is_dup_event = function(event, selector, app)
{
    var found_event = false;

    if (event == "content_change" && KOBJEventManager.current_fires[app.app_id] != null)
    {
        var app_fire = KOBJEventManager.current_fires[app.app_id][event];
        if (app_fire != null && app_fire[selector])
        {
            found_event = true;
        }
    }

    return found_event;
};


/*
 * Adds an event to be fired later in the queue. Events have to be queued up so that
 * they can be sorted out and not cause loops.
 */
KOBJEventManager.add_to_fire_queue = function(guid, event, data, app)
{
    if (KOBJEventManager.is_dup_event(event, data.selector, app))
    {
        KOBJ.loggers.events.trace("Dup Event " + event + " : " + app.app_id);
        return;
    }
    KOBJ.loggers.events.trace("Adding Event " + event + " : " + app.app_id);

    // Build up the current fires has with the elements and data we need.
    if (KOBJEventManager.current_fires[app.app_id] == null)
    {
        KOBJEventManager.current_fires[app.app_id] = {};
    }
    if (KOBJEventManager.current_fires[app.app_id][event] == null)
    {
        KOBJEventManager.current_fires[app.app_id][event] = {};
    }
    if (KOBJEventManager.current_fires[app.app_id][event][data.selector] == null)
    {
        KOBJEventManager.current_fires[app.app_id][event][data.selector] = {};
    }
    KOBJEventManager.current_fires[app.app_id][event][data.selector][guid] = {};
    KOBJEventManager.current_fires[app.app_id][event][data.selector][guid]["submit_data"] = data.submit_data;
    KOBJEventManager.current_fires[app.app_id][event][data.selector][guid]["param_data"] = data.param_data;
    KOBJEventManager.current_fires[app.app_id][event][data.selector][guid]["selector"] = data.selector;

    var app_data = KOBJEventManager.current_fires[app.app_id][event][data.selector][guid];

    // Short cut way to get to app via guid
    KOBJEventManager.guid_list[guid] = {};
    KOBJEventManager.guid_list[guid]["app"] = app;
    KOBJEventManager.guid_list[guid]["event"] = event;
    KOBJEventManager.guid_list[guid]["selector"] = data.selector;

    if (event == "content_change")
    {
        KOBJEventManager.content_changes_running[guid] = app;
    }

    app.fire_event(event, app_data, guid, "web");
};


KOBJEventManager.hashCode = function(value) {
    var hash = 0;
    if (value.length === 0) return hash;
    for (var i = 0; i < value.length; i++) {
        var cha = value.charCodeAt(i);
        hash = 31 * hash + cha;
        hash = hash & hash; // Convert to 32bit integer
    }
    return hash;
};

// Ths computes the hash value for the text of a selector
KOBJEventManager.content_change_hashcode = function(selector)
{
    if($KOBJ(selector).length > 0)
    {
        return KOBJEventManager.hashCode($KOBJ(selector).text());
    }
    else
    {
        return -1;
    }
};

// This will look at all the content change selectors and update their hash values.
KOBJEventManager.update_content_change_hash = function()
{
//    KOBJ.itrace("Updating hashes");

    $KOBJ.each(KOBJEventManager.events["content_change"], function(selector, event_data) {
        if (!KOBJEventManager.content_change_hashcodes[selector])
        {
            KOBJEventManager.content_change_hashcodes[selector] = {};
        }

//        KOBJ.itrace("Before  hash [" + KOBJEventManager.content_change_hashcodes[selector]["prior_data_hash"] + "]");
        KOBJEventManager.content_change_hashcodes[selector]["prior_data_hash"] = KOBJEventManager.content_change_hashcode(selector);
//        KOBJ.itrace("After  hash [" + KOBJEventManager.content_change_hashcodes[selector]["prior_data_hash"] + "]");
    });
//    KOBJ.itrace("Done Updating hashes");
};

/*
 * Used to check all the content change events and fire them as needed.
 */
KOBJEventManager.content_change_checker = function()
{
//    KOBJ.itrace("In Content Change");
    // Just in any are running abort.
    if (!$KOBJ.isEmptyObject(KOBJEventManager.content_changes_running) )
    {
//        KOBJ.itrace("Content Chagne running");
        return;
    }

    var any_fired = false;
    $KOBJ.each(KOBJEventManager.events["content_change"], function(selector, event_data) {
        // We have not yet looked at the data so we need to get it so we can check it next time.
        if (!KOBJEventManager.content_change_hashcodes[selector])
        {
            KOBJEventManager.content_change_hashcodes[selector] = {};
        }
        var selector_data = KOBJEventManager.content_change_hashcodes[selector];
        if (!selector_data["prior_data_hash"]) {
            selector_data["prior_data_hash"] = KOBJEventManager.content_change_hashcode(selector);
        }
        else {
            // If The element changed then fire the event.
            if (selector_data["prior_data_hash"] != KOBJEventManager.content_change_hashcode(selector)) {

//                KOBJ.itrace("Data Change going to fire content change [" + selector_data["prior_data_hash"] + "] [" + KOBJEventManager.content_change_hashcode(selector) + "]");
                // Reset the data to the new value
                selector_data["prior_data_hash"] = KOBJEventManager.content_change_hashcode(selector);
                KOBJEventManager.event_handler({"type" : "content_change", "data" : { "selector" : selector }});
                any_fired = true;
            }
        }
    });

    if (!any_fired)
    {
//        KOBJ.itrace("Setting change look timer");
        setTimeout(KOBJEventManager.content_change_checker, 500);
    }

};

/*
 * This is how a app register intested in an event.
 */
KOBJEventManager.register_interest = function(event, selector, application, config) {
    var found_data = [];

    var start_content_timer = false;
    if($KOBJ.isEmptyObject(KOBJEventManager.events["content_change"]) && event == "content_change")
    {
        start_content_timer = true;
    }

    if (typeof(config) != "undefined")
    {
        // We need to check to see if ANYONE registing has a form_submit true in
        // the config.  Then we need to make sure for the provided selector
        // we allow the form to submit.
        if (config["form_submit"] != null && config["form_submit"])
        {
            KOBJEventManager.events[event][selector]["form_submit"] = true;
        }

        if (typeof(config.param_data) != "undefined" && config.param_data != null) {
//            found_data = config.param_data;

            $KOBJ.each(config.param_data, function(name, v) {
                found_data.push({name: name,value:v });
            });

        }
    }


    // With custom events we do not know the name so we just add them if they
    // are missing
    if (KOBJEventManager.events[event] == null)
    {
        KOBJEventManager.events[event] = {};
    }
    // Is there anything registered with this selector?  If so then do not register again.
    if ($KOBJ.isEmptyObject(KOBJEventManager.events[event][selector]))
    {
        KOBJEventManager.events[event][selector] = {};

        if (event != "content_change") {
            $KOBJ(selector).live(event + "." + selector, {"selector" : selector},
                    KOBJEventManager.event_handler);
        }
    }

    KOBJEventManager.events[event][selector][application.app_id] = {};
    KOBJEventManager.events[event][selector][application.app_id]["app"] = application;
    KOBJEventManager.events[event][selector][application.app_id]["data"] = { "param_data": found_data};

    if(start_content_timer)
    {
        setTimeout(KOBJEventManager.content_change_checker, 500);
    }
};


/*
 * This is how an application remove it self from the event manager.
 */
KOBJEventManager.deregister_interest = function(event, selector, application) {
    if (KOBJEventManager.events[event][selector] != null)
    {
        delete KOBJEventManager.events[event][selector][application.app_id];
        if (event != "pageview" && $KOBJ.isEmptyObject(KOBJEventManager.events[event][selector]))
        {
            $KOBJ(selector).unbind(event + "." + selector);
        }
    }
};


/*
 * Out of bound events are thing that are not really tied to an element. For example
 * page load events.   This is private do not access this from client code only for
 * internal use only
 */
KOBJEventManager.add_out_of_bound_event = function(application, event, auto_deregister, extra_data)
{
    KOBJEventManager.register_interest(event, "unknown", application, extra_data);

    // We fake out a jquery event in order to reuse the code.
    var data = {"type" : event, "data" : { "selector" : "unknown"}};

//    if (typeof(extra_data) != "undefined")
//    {
//        $KOBJ.extend(true, data["data"], extra_data);
//    }

    KOBJEventManager.event_handler(data);

    // Page View events can only happen one time so no need to keep them around.
    if (event == "pageview" || (typeof(auto_deregister) != null && auto_deregister ))
    {
        KOBJEventManager.deregister_interest(event, "unknown", application);
    }
};

/*
 * This is the call back for all events. It sorts out what kind of event and does the right thing.
 */
KOBJEventManager.event_handler = function(event) {
//    KOBJ.itrace("in event handle");
    var event_data = event.data;

    // Are we doing a submit then get the form data.
    if (event.type == "submit")
    {
        event_data["submit_data"] = $KOBJ(event_data.selector).serializeArray();
    }

    $KOBJ.each(KOBJEventManager.events["" + event.type][event_data.selector], function(app_id, app_info) {
        var current_guid = KOBJEventManager.eid();
        $KOBJ.extend(true,event_data,app_info.data);
        KOBJEventManager.add_to_fire_queue(current_guid, event.type, event_data, app_info.app);
    });

    if (event.type == "submit") {
        // We need to check if for this selector we should submit or not submit the form.
        if (KOBJEventManager.events[event.type][event_data.selector]["form_submit"] != null) {
            return true;
        }
        else {
            return false;
        }
    }
    return true;
};

//setTimeout(KOBJEventManager.content_change_checker, 500);

