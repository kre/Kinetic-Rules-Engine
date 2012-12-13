KOBJ.watchDOM = function(selector, callBackFunc, time, context) {

    if (typeof(context) == "undefined") {
        context = KOBJ.document;
    }

    if (!KOBJ.watcherRunning) {
        KOBJ.itrace("Starting the DOM Watcher");

        var KOBJ_setInterval = 0;
        if (typeof(setInterval_native) != "undefined") {
            KOBJ_setInterval = setInterval_native;
        } else {
            KOBJ_setInterval = setInterval;
        }
        if (KOBJ.watcherRunning) {
            clearInterval(KOBJ.watcherRunning);
        }

        KOBJ.watcherData = KOBJ.watcherData || [];

        KOBJ.itrace("DOM Watcher Callback for new selector " + selector + " added");
        if($KOBJ(selector + " :first", context).length === 0)
        {
            KOBJ.itrace("DOM Watcher selector not found NOT enabling " + selector );
            setTimeout(function() {KOBJ.watchDOM(selector,callBackFunc,time,context);},1000);
            return;
        }
        $KOBJ(selector + " :first", context).addClass("KOBJ_AjaxWatcher");
        var there = false;
        if ($KOBJ(selector + " :first", context).is(".KOBJ_AjaxWatcher")) {
            there = true;
        }

        KOBJ.watcherData.push({"selector": selector,"callBacks": [callBackFunc], "there": there, "context" : context});


        KOBJ.watcher = function() {
            $KOBJ(KOBJ.watcherData).each(function() {
                var data = this;
                var selectorExists = $KOBJ(data.selector, data.context).length;
                if (!selectorExists) {
                    return;
                }

                var hasNotChanged = $KOBJ(data.selector + " :first", data.context).is(".KOBJ_AjaxWatcher");

                if (!data.there) {
                    $KOBJ(data.selector + " :first", data.context).addClass("KOBJ_AjaxWatcher");
                    if ($KOBJ(data.selector + " :first", data.context).is(".KOBJ_AjaxWatcher")) {
                        data.there = true;
                    } else {
                        data.there = false;
                    }

                    hasNotChanged = false;

                }


                if (!hasNotChanged && data.there) {
                    $KOBJ(data.callBacks).each(function() {
                        // TODO: Should this be var?
                        callBack = this;
                        KOBJ.itrace("Running call back on selector " + data.selector);
                        callBack();
                    });
                    $KOBJ(data.selector + " :first", data.context).addClass("KOBJ_AjaxWatcher");
                }
            });
        };


        KOBJ.watcherRunning = KOBJ_setInterval(KOBJ.watcher, time || 500);


    } else {
        $KOBJ(KOBJ.watcherData).each(function() {
            var data = this;
            if (data.selector == selector && data.context == context) {
                data.callBacks.push(callBackFunc);
                $KOBJ(data.selector + " :first", data.context).addClass("KOBJ_AjaxWatcher");

                if ($KOBJ(data.selector + " :first", data.context).is(".KOBJ_AjaxWatcher")) {
                    data.there = true;
                } else {
                    data.there = false;
                }

                KOBJ.itrace("DOM Watcher Callback for previous selector " + selector + " added");
                return false;//breaks out of the loop.

            } else {
                var there = false;

                if ($KOBJ(selector + " :first", context).is(".KOBJ_AjaxWatcher")) {
                    there = true;
                }

                KOBJ.watcherData.push({"selector": selector,"callBacks": [callBackFunc], "there": there, "context" : context});
                $KOBJ(selector + " :first", context).addClass("KOBJ_AjaxWatcher");
                KOBJ.itrace("DOM Watcher Call for new selector " + selector + " added");
            }
        });//end each
    }//end if/else
};
