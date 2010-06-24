//(function(window, undefined) {
    // Define a local copy of jQuery
    KOBJEventManager = {};

//    KOBJEventManager.CLICK = "click";
//    KOBJEventManager.DOUBLECLICK = "doubleclick";
//    KOBJEventManager.MOUSEOUT = "mouseout";
//    KOBJEventManager.CHANGE = "change";
//    KOBJEventManager.MOUSEMOVE = "mousemove";
//    KOBJEventManager.SUBMIT = "submit";
//    KOBJEventManager.MOUSELEAVE = "mouseleave";
//    KOBJEventManager.RESIZE = "resize";
//    KOBJEventManager.SCROLL = "scroll";
//    KOBJEventManager.SELECT = "select";
//    KOBJEventManager.TOGGLE = "toggle";
//    KOBJEventManager.LOAD = "load";
//    KOBJEventManager.KEYUP = "keyup";
//    KOBJEventManager.KEYPRESS = "keypress";
//    KOBJEventManager.KEYDOWN = "keydown";
//    KOBJEventManager.FOCUSIN = "focusin";
//    KOBJEventManager.FOCUSOUT = "focusout";
//    KOBJEventManager.PAGEVIEW = "pageview";
//    KOBJEventManager.CONTENT_CHANGE = "content_change";
    /*
     * This generates a uniq id for event groups.  
     */
    KOBJEventManager.eid = function() {
        var adate = new Date();
        return adate.valueOf() + (Math.random() +"").substring(2);
    };


    KOBJEventManager.current_fires = {
        "click" : {},
        "doubleclick" : {},
        "mouseout" : {},
        "change" : {},
        "mousemove" : {},
        "submit" : {},
        "mouseleave" : {},
        "resize" : {},
        "scroll" : {},
        "select" : {},
        "toggle" : {},
        "load" : {},
        "keyup" : {},
        "keypress" : {},
        "keydown" : {},
        "focusin" : {},
        "focusout" : {},
        "pageview" : {},
        "content_change" : {}
    };

    KOBJEventManager.events = {
        "click" : {},
        "doubleclick" : {},
        "mouseout" : {},
        "change" : {},
        "mousemove" : {},
        "submit" : {},
        "mouseleave" : {},
        "resize" : {},
        "scroll" : {},
        "select" : {},
        "toggle" : {},
        "load" : {},
        "keyup" : {},
        "keypress" : {},
        "keydown" : {},
        "focusin" : {},
        "focusout" : {},
        "pageview" : {},
        "content_change" : {}
    };


    /*
     * This is the notification call back to let the event manager know that
     * an event was sent to the server and has come back.
     */
    KOBJEventManager.event_fire_complete = function(application, guid)
    {
        var event = KOBJEventManager.find_event_by_guid(guid);
        delete KOBJEventManager.current_fires[event][guid][application.app_id];
        KOBJ.itrace("Event Fire Complete " + application.app_id + " - " + guid);
        if ($KOBJ.isEmptyObject(KOBJEventManager.current_fires[event][guid]))
        {
            KOBJ.itrace("Remove Guid : " + guid);
            delete KOBJEventManager.current_fires[event][guid];
        }

        
    };

    KOBJEventManager.find_event_by_guid = function(guid)
    {
        var theevent = "" ;
        $KOBJ.each(KOBJEventManager.current_fires, function(event, event_data) {
            if(event_data[guid])
            {
                theevent = event;
            }

        });
        return theevent;
    };

    /*
     * This is the timeout call back function that get called every Xms to check for events in the queue.
     */
    KOBJEventManager.process_fires = function()
    {
        // Because hashes are really arrays we get the first thing in our current fire.
        $KOBJ.each(KOBJEventManager.current_fires, function(event, event_data) {
            $KOBJ.each(KOBJEventManager.current_fires[event], function(guid, guid_data)
            {
                $KOBJ.each(KOBJEventManager.current_fires[event][guid], function(app_id, app_data) {
                    if (!app_data["processing"])
                    {

                        KOBJ.itrace("Firing Event " + app_id + " - " + app_data["processing"]);
                        app_data["app"].fire_event(event,app_data,guid);
                        app_data.processing = true;
                    }
                });
                // Break out of this each loop.
                return false;
            });
        });

        KOBJEventManager.content_change_checker();
        setTimeout(KOBJEventManager.process_fires,500);

    };

    /*
     * Check if the event is a dup.  By that I mean no app can have to events of the same
     * type in the queue at any time.
     */
    KOBJEventManager.is_dup_event = function(event, selector, app)
    {
        var found_event = false;
        // Because hashes are really arrays we get the first thing in our current fire.
            $KOBJ.each(KOBJEventManager.current_fires[event], function(guid, guid_data)
            {
                $KOBJ.each(KOBJEventManager.current_fires[event][guid], function(app_id, app_data) {
                    if(app_data.selector == selector && app.app_id == app_id)
                    {
                        found_event = true;
                    }
                });
            });

        return found_event;
    };


    /*
     * Adds an event to be fired later in the queue. Events have to be queued up so that
     * they can be sorted out and not cause loops.
     */
    KOBJEventManager.add_to_fire_queue = function(guid, event, data, app)
    {
        if(KOBJEventManager.is_dup_event(event,data.selector,app))
        {
            KOBJ.itrace("Dup Event " +  event  + " : " + app.app_id);
            return;
        }
        // When adding to the queue we do not allow the same event for the same selector to
        // be added multiple times.  This could cause some freky loops
        if (!KOBJEventManager.current_fires[event][guid])
        {
            KOBJEventManager.current_fires[event][guid] = {};
        }
        KOBJEventManager.current_fires[event][guid][app.app_id] = {};
        KOBJEventManager.current_fires[event][guid][app.app_id]["app"] = app;
        KOBJEventManager.current_fires[event][guid][app.app_id]["processing"] = false;
        KOBJEventManager.current_fires[event][guid][app.app_id]["selector"] = data.selector;
        KOBJEventManager.current_fires[event][guid][app.app_id]["submit_data"] = data.submit_data;

    };

    /*
     * Used to check all the content change events and fire them as needed.
     */
    KOBJEventManager.content_change_checker = function()
    {
        $KOBJ.each(KOBJEventManager.events["content_change"],function(selector,selector_data) {
            // We have not yet looked at the data so we need to get it so we can check it next time.
           if(!selector_data["prior_data"]){
               selector_data["prior_data"] = $KOBJ(selector).text();
           }
           else {
               // If The element changed then fire the event.
               if(selector_data["prior_data"] != $KOBJ(selector).text() ) {
                  KOBJEventManager.event_handler({"type" : "content_change", "data" : { "selector" : selector}});
                   // Reset the data to the new value
                  selector_data["prior_data"] = $KOBJ(selector).text();
               }
           }
        });
    };

    /*
     * This is how a app register intested in an event.
     */
    KOBJEventManager.register_interest = function(event, selector, application, config) {

        if(typeof(config) != "undefined")
        {
            // We need to check to see if ANYONE registing has a form_submit true in
            // the config.  Then we need to make sure for the provided selector
            // we allow the form to submit.
            if(config["form_submit"] != null && config["form_submit"])
            {
                KOBJEventManager.events[event][selector]["form_submit"] = true;
            }
        }

        // Is there anything registered with this selector?  If so then do not register again.
        if ($KOBJ.isEmptyObject(KOBJEventManager.events[event][selector]))
        {
            KOBJEventManager.events[event][selector] = {};

            if(event != "content_change") {
                $KOBJ(selector).live(event + "." + selector, {"selector" : selector},
                    KOBJEventManager.event_handler);
            }
        }              
        KOBJEventManager.events[event][selector][application.app_id] = application;
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
     * page load events.
     */
    KOBJEventManager.add_out_of_bound_event = function(application,event)
    {
        KOBJEventManager.register_interest(event, "unknown", application);

        // We fake out a jquery event in order to reuse the code.
        KOBJEventManager.event_handler({"type" : event, "data" : { "selector" : "unknown"}});

        // Page View events can only happen one time so no need to keep them around.
        if(event == "pageview")
        {
          KOBJEventManager.deregister_interest(event, "unknown", application);
        }
    };

    /*
     * This is the call back for all events. It sorts out what kind of event and does the right thing.
     */
    KOBJEventManager.event_handler = function(event) {
        KOBJ.itrace("in event handle");
        var event_data = event.data;
        var current_guid = KOBJEventManager.eid();

        // Are we doing a submit then get the form data.
        if(event.type == "submit")
        {
            event_data["submit_data"] = $KOBJ(event_data.selector).serializeArray();
        }

        $KOBJ.each(KOBJEventManager.events["" + event.type][event_data.selector], function(app_id, application) {

            KOBJEventManager.add_to_fire_queue(current_guid, event.type, event_data, application);
        });

        if(event.type == "submit") {
            // We need to check if for this selector we should submit or not submit the form.
            if(KOBJEventManager.events[event.type][event_data.selector]["form_submit"] != null) {
                return true;
            }
            else {
                return false;
            }
        }
        return true;
    };

    /*
     * In some cases events do not get registered as a prior event registration of another
     * framework might have stopped the propagation of the event.  In that case this method
     * can be used to send the event just as if it was sent by registering it with javascript.
     * In order for this to work the application must have still registered interest in the event.
     */
//    KOBJEventManager.force_event = function(event_type,selector) {
//       KOBJEventManager.event_handler({ data: {selector : selector }, type: event_type})
//    };

//    window['KOBJEventManager'] = KOBJEventManager;

    setTimeout(KOBJEventManager.process_fires,100);

//})(window);

