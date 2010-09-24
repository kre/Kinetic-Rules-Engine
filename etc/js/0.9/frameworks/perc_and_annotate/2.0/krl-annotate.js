/*
  In the case of google instance just because a page changed does not mean it is in a
  stable state.   Because of that we need to check out  a number of things on the page to
  know when the user has stopped typing according to google.  This is not full proof as once
  we find the page is stage the user could start typing again.
 */
KOBJAnnotateSearchResults.google_search_change_condition = function() {
    KOBJ.loggers.annotate.trace("Google Instant Check");
    // If this is hidden then we are not in google instant
    if ($KOBJ("#po-on-message", KOBJ.document).is(":hidden")) {
        KOBJ.loggers.annotate.trace("Google Instant not on");
        return true;
    }

    // For google instant if the url has a hash tag that has a param of lq and that matches
    // what is in the search form field. Then the person has stopped typing for a few seconds.
    var result = KOBJ.parseURL(KOBJ.document.location);
    var current_query = KOBJ.parseURLParams(KOBJ.parseURL(window.location).hash)

    // If there is not oq then instance has not even finished once.
    if (current_query.oq == "undefined") {
        return false;
    }

    var about_to_be_typed =  $KOBJ("#tsf input[name='q']").prev().text();
    var search_field = $KOBJ("#tsf input[name='q']").val();

    if (   KOBJ.urlDecode(current_query.oq) == search_field || KOBJ.urlDecode(current_query.q) == search_field ||
           KOBJ.urlDecode(current_query.oq) == about_to_be_typed || KOBJ.urlDecode(current_query.q) == about_to_be_typed) {
        KOBJ.loggers.annotate.trace("They were the same");
        return true;
    }
    KOBJ.loggers.annotate.trace("Were not the same");

    return false;
};


/* For the pages we support annotation out of the box this method will extract the wanted
    "data" elements and store them so that the annotating function can use it to figure
    out what should be annotated.
*/
KOBJAnnotateSearchResults.annotate_search_extractdata = function(toAnnotate) {

    var annotateData = {};
    var urlSelector = this.defaults.domains[window.location.host].urlSel;
    var urlTemp = $KOBJ(toAnnotate).find(urlSelector).attr("href");


    if (!urlTemp) {
        urlTemp = $KOBJ(toAnnotate).find(".url, cite").attr("href");
        // Failsafe
    }

    KOBJ.loggers.annotate.trace("Temp URL ", urlTemp);

    // Yahoo sometime put tracking url befor ethe real url.   We strip the tracking url out here.
    if (window.location.host == "search.yahoo.com" && urlTemp.indexOf("**http") != -1) {
        urlTemp = urlTemp.replace(/.*\*\*/, "");
        urlTemp = urlTemp.replace(/%3a/, ":");
    }

    if (urlTemp) {
        annotateData["url"] = urlTemp;
        annotateData["domain"] = KOBJ.get_host(urlTemp);
    } else {
        annotateData["url"] = "";
        annotateData["domain"] = "";
    }
    return annotateData;
};

/*

Defaults:
    maxURLLength : This is the max url we will send with a jsonp request.
    scope :  Is the case where there are multiple annotations from the same application we need
           a way to keep them unique so  we know what have an attempted to annotate.  So if
           an app wants multiple annotate actions they need to specify this option/
           ex   with scope = "third_anno_call"
     wrapper_css:  This are css style tags that will be added to the wrapper class for the annotation.
     placement: Allows the placement to be:
            before - before the element being annotated
            after - after the element being annotated
            prepend - Inside the element but prepened to the content of that element
            append - Inside the element but appended to the content of that element
     result_lister
     domains: This is where we match domains to defaults we know about
            selector:  Selector to find the items we are looking to annotate
            modify:  Selector to find the element inside the above selector that we will modify
            watcher: If continuous checking of the page for changes is want this is the elements content
                    that will be watched for changes.
            urlSel: In the case that this is annotating something with url this is the selector to find that url
            change_condition: If watcher is specified that this will work in conjunction and verify that the change to
                    the page is complete.
            extract_function:  When extracting data from the item being annotated this function is called to do the
                    data extraction.
 */

function KOBJAnnotateSearchResults(an_app, an_name, an_config, an_callback) {
    KOBJ.loggers.annotate.trace("Init Annotate " + name);

    this.defaults = {
        "scope": "",
        "maxURLLength" : 1800,
        "wrapper_css" : {
            "color": "#CCC",
            "width": "auto",
            "height": "40px",
            "font-size": "12px",
            "line-height": "normal",
            "left-margin": "15px",
            "right-padding": "15px",
            "font-family": "Verdana, Geneva, sans-serif"
        },
        "placement" : 'prepend',
        "results_lister" : "",
        "element_to_modify" : "div.s,div.abstr,p",
        "domains": {
            "www.google.com": {
                "selector": "li.g:not(.localbox), div.g",
                "modify": "div.s",
                "watcher": "#rso",
                "urlSel":".l",
                "change_condition": KOBJAnnotateSearchResults.google_search_change_condition,
                "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
            },
            "www.bing.com": {
                "selector": "#results>ul>li",
                "modify": "p",
                "watcher": "",
                "urlSel":".nc_tc a, .sb_tlst a",
                "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
            },
            "search.yahoo.com": {
                "selector": "li div.res",
                "modify": "div.abstr",
                "watcher": "",
                "urlSel":".yschttl",
                "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
            }
        }
    };

    if (this.defaults.placement == "prepend" || this.defaults.placement == "before") {
        this.defaults.wrapper_css.float = "left"
    }
    else if (this.defaults.placement == "append" || this.defaults.placement == "after") {
        this.defaults.wrapper_css.float = "right"
    }

    // Used as part of the marker to make a unique id for the search result so that
    // remote anno has a way to refernece the element they want to alter.
    this.annotate_search_counter = 0;

    // Use as part of the marker for the wrapper div inside the item we are annotating.
    // This allow a way to reference the same wrapper across multiple apps
    this.name = an_name;

    // This is a reference to the application wanting to do the annotation.
    this.app = an_app;


    // This the callback passed to us by the engine so that actions can log what they are doing.
    this.callback = an_callback;

    // Lets merge our defaults  and with what comes in the config
    if (typeof an_config === 'object') {
        $KOBJ.extend(true, this.defaults, an_config);
    }

    // What get the list of things to annotate
    this.lister = "";
    // What element are we going to change
    this.modify = "";
    // What on the page do we watch to know if it changed
    this.watcher = "";

    this.change_condition = KOBJAnnotateSearchResults.true_change_condition;
    this.extract_function = KOBJAnnotateSearchResults.annotate_search_extractdata;

    // Simple var to know if we have the data we need to annotate.
    this.invalid = false;


    // TODO : Allow way to just say what the lister watch and such are in cases were the domain does not matter.
    if (this.defaults["results_lister"]) {
        this.lister = this.defaults["results_lister"];
        this.watcher = "";
        this.modify = this.defaults["element_to_modify"];
    } else if (this.defaults["domains"][window.location.hostname]) {
        // Gets selectors for both DOM watcher and the element
        this.lister = this.defaults["domains"][window.location.hostname]["selector"];
        this.watcher = this.defaults["domains"][window.location.hostname]["watcher"];
        this.modify = this.defaults["domains"][window.location.hostname]["modify"];
        this.change_condition = this.defaults["domains"][window.location.hostname]["change_condition"];
        this.extract_function =    this.defaults["domains"][window.location.hostname]["extract_function"];
    } else {
        this.invalid = true;
    }
    KOBJ.loggers.annotate.trace("Annotate Object Created");
}
;


/*
Used to name the annotated item with a marker that allow use to know if it has already been
looked at for  anno.
 */
KOBJAnnotateSearchResults.prototype.app_marker = function() {
//   KOBJ.loggers.annotate.trace("Name",this.name);
//    KOBJ.loggers.annotate.trace("Scope",this.defaults.scope);
//    KOBJ.loggers.annotate.trace("AppID", this.app.app_id);
    return this.name + "_" + this.defaults.scope + "_" + this.app.app_id + "_anno";
};

/*
 Used to name the annotated item with a marker that allow use to uniquely label each item so that
  remote annotations can say what item is to be annotated in their results.
*/
KOBJAnnotateSearchResults.prototype.app_marker_count = function() {
    return this.app_marker() + "_" +  (this.annotate_search_counter += 1);
};

/*
For the wrapper that we put on the page to put the annotation content in we label it with this name.
 */
KOBJAnnotateSearchResults.prototype.anno_item = function() {
    return this.name + "_item";
};

KOBJAnnotateSearchResults.prototype.annotate = function() {
    if (this.invalid) {
        KOBJ.loggers.annotate.trace("Annotate was not configure correctly.");
        return;
    }

    KOBJ.loggers.annotate.trace("Annotate called and must have been some what valid");

    var runAnnotate = null;

    if (this.defaults["remote"]  == "event") {
        runAnnotate = this.annotate_event_search();
    } else if(this.defaults["remote"]) {
        runAnnotate = this.annotate_remote_search();
    } else {
        runAnnotate = this.annotate_normal_search();
    }

    runAnnotate();

    if (typeof(this.watcher) != "undefined") {
        KOBJ.loggers.annotate.trace("App ID is " + this.app.app_id);
        var dmw = KOBJDomWatch.get_dom_watch("search_annotate", this.change_condition, 1000);
        dmw.watch(this.watcher, runAnnotate, KOBJ.get_application(this.app.app_id));
    }
};

/*
 This function first looks for all elements that can be annotated then extracts the
 data to be sent back to the remote server or local annotation function.
 The result is in the format of
 { unique_element_id : { data : hash of data as key values return from the extract data call
 element : result of the elements found by the result list.
 }
 }
 */
KOBJAnnotateSearchResults.prototype.collect_and_label = function() {
    var myself = this;
    var annotateInfo = {};

    KOBJ.loggers.annotate.trace("Lister ", myself.lister);

    $KOBJ.each($KOBJ(myself.lister), function() {
        var toAnnotate = this;


        if ($KOBJ(toAnnotate).hasClass(myself.app_marker())) {
            KOBJ.loggers.annotate.trace("Already has marker will not re-annotate");
            return true;
        }

        $KOBJ(toAnnotate).addClass(myself.app_marker());

        var item_counter = myself.app_marker_count();
        $KOBJ(toAnnotate).addClass(item_counter);

        // Here we create the content wrapper for where the annotation will go.
        if ($KOBJ(toAnnotate).find('div .' + myself.anno_item()).length == 0) {
            KOBJ.loggers.annotate.trace("Add Wrapper Div");
            var wrapper = $KOBJ("<div>").addClass(myself.anno_item());
            wrapper.css(myself.defaults.wrapper_css);
            $KOBJ(toAnnotate).find(myself.modify)[myself.defaults.placement](wrapper);
        }

        var extract_data = myself.extract_function(toAnnotate);

        // We attached the extracted data to the element for easy access later.
        $KOBJ.each(extract_data, function(name, value) {
            $KOBJ(toAnnotate).data(name, value);
        });

        annotateInfo[item_counter] = {
            data: extract_data,
            element: toAnnotate
        };
    });

    return     annotateInfo;
};

KOBJAnnotateSearchResults.prototype.annotate_remote_search = function() {
    var myself = this;
    KOBJ.loggers.annotate.trace("Remote Annotation Requested ");

    var runAnnotate = function() {
        KOBJ.loggers.annotate.trace("In Remote Annotate Function");

        var remote_url = myself.defaults["remote"];
        var annotateInfo = myself.collect_and_label();
        var count = 0;

        function jsonPCallback(data) {
             myself.annotate_data(data);
        }

        if (!$KOBJ.isEmptyObject(annotateInfo)) {
            var annotateArray = myself.splitJSONRequest(annotateInfo, remote_url);
            $KOBJ.each(annotateArray, function(key, data) {
                var annotateString = $KOBJ.compactJSON(data);
                KOBJ.loggers.annotate.trace("Making Remote Data Call");
                $KOBJ.getJSON(remote_url, {'annotatedata':annotateString}, jsonPCallback);
            });
        }
        myself.callback();
    };

    return runAnnotate;

};


/*
Data should look like
{ item_id : {data attributes} }
 */
KOBJAnnotateSearchResults.prototype.annotate_data = function(data) {
    var count = 0;
    var myself = this;

    // Here item_id is the unique id we put on the item we are annotating.
    $KOBJ.each(data, function(item_id, item_data) {
        KOBJ.loggers.annotate.trace("Working on result list local");
        count++;
        var toAnnotate = $KOBJ("." + item_id);
        var container = $KOBJ("." + myself.anno_item(), toAnnotate);
        myself.defaults.annotator(toAnnotate, container, item_data);
    });

    KOBJ.logger('annotated_search_results', myself.defaults['txn_id'], count, '', 'success', myself.defaults['rule_name'], myself.defaults['rid']);
};

KOBJAnnotateSearchResults.prototype.annotate_normal_search = function() {
    var myself = this;

    KOBJ.loggers.annotate.trace("Local Callback Annotation Requested");

    var runAnnotate = function() {
        var annotateInfo = myself.collect_and_label();

        myself.annotate_data(myself.data_only(annotateInfo));
        myself.callback();
    };

    return runAnnotate;
};

/*
Yes bad method name but so what.  This will take the data structure from collect and label and
convert it to just item => data
 */
KOBJAnnotateSearchResults.prototype.data_only = function(annotateInfo) {
    var annotate_data = {};

    $KOBJ.each(annotateInfo, function(item_id, item_data) {
        KOBJ.loggers.annotate.trace("int");
        annotate_data[item_id] = item_data.data;
    });


    KOBJ.loggers.annotate.trace(annotate_data);
    return annotate_data;
};

KOBJAnnotateSearchResults.prototype.splitJSONRequest = function(json, url) {

    var to_compact =  this.data_only(json);
    var jsonString = $KOBJ.compactJSON(to_compact);
    var numOfRequests = Math.ceil((jsonString.length + url.length) / this.defaults.maxURLLength);

    KOBJ.loggers.annotate.trace("The number of requests to be made is: " + numOfRequests);
    if (numOfRequests > 1) {
        KOBJ.loggers.annotate.trace("The length of the annotation request would be too large. Splitting into " + numOfRequests + " requests.");
        var toReturn = [];
        var count = 1;
        $KOBJ.each(to_compact, function(index) {
            var object = this;
            var number = count++ % (numOfRequests);
            toReturn[number] = toReturn[number] || {};
            toReturn[number][index] = object;
        });
        return toReturn;
    } else {
        return [json];
    }
};
