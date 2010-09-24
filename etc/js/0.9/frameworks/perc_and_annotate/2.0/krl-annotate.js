KOBJAnnotateSearchResults.true_change_condition = function()
{
    KOBJ.loggers.annotate.trace("Default change checker");
    return true;
}

KOBJAnnotateSearchResults.google_search_change_condition = function()
{
    KOBJ.loggers.annotate.trace("Google Instant Check");
    // If this is hidden then we are not in google instant
    if($KOBJ("#po-on-message",KOBJ.document).is(":hidden"))
    {
        KOBJ.loggers.annotate.trace("Google Instant not on");
        return true;
    }

    // For google instant if the url has a has that has a param of q and that matches
    // what is in the search form field. Then the person has stopped typing for a few seconds.
    var result = KOBJ.parseURL(KOBJ.document.location);
    var current_query = KOBJ.parseURLParams(KOBJ.parseURL(window.location).hash)

    // If there is not oq then instance has not even finished once.
    if(current_query.oq == "undefined")
    {
        return false;
    }

    if(KOBJ.urlDecode(current_query.oq) == $KOBJ("#tsf input[name='q']").val())
    {
        KOBJ.loggers.annotate.trace("They were the same");
        return true;
    }
    KOBJ.loggers.annotate.trace("Were not the same");

    return false;
};

KOBJAnnotateSearchResults.annotate_counter = 0;

function KOBJAnnotateSearchResults(an_app, an_name, an_config, an_callback) {
    KOBJ.loggers.annotate.trace("Initing Annotate " + name);

    this.defaults = {
        "sep": "<div style='padding-top: 13px'>|</div>",
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
            "www.google.com": { "selector": "li.g:not(.localbox), div.g", "modify": "div.s", "watcher": "#rso", "urlSel":".l", "change_condition": KOBJAnnotateSearchResults.google_search_change_condition },
            "www.bing.com": { "selector": "#results>ul>li", "modify": "p", "watcher": "","urlSel":".nc_tc a, .sb_tlst a", "change_condition": KOBJAnnotateSearchResults.true_change_condition },
            "search.yahoo.com": { "selector": "li div.res", "modify": "div.abstr", "watcher": "","urlSel":".yschttl", "change_condition": KOBJAnnotateSearchResults.true_change_condition }
        }
    };

    if(this.defaults.placement == "prepend")
    {
        this.defaults.wrapper_css.float = "left"
    }
    else if(this.defaults.placement == "append")
    {
        this.defaults.wrapper_css.float = "right"
    }
    else if(this.defaults.placement == "before")
    {
        this.defaults.wrapper_css.float = "left"
    }
    else if(this.defaults.placement == "after")
    {
        this.defaults.wrapper_css.float = "right"

    }

    this.entry = KOBJAnnotateSearchResults.annotate_counter++;
    this.name = an_name;
    this.app = an_app;
    this.maxURLLength = 1800;
    this.callback = an_callback;

    if (typeof an_config === 'object') {
        $KOBJ.extend(true, this.defaults, an_config);
    }

    this.lister = "";
    this.modify = "";
    this.watcher = "";
    this.change_condition = KOBJAnnotateSearchResults.true_change_condition;
    this.invalid = false;

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
    } else {
        this.invalid = true;
    }
    KOBJ.loggers.annotate.trace("Annotate Object Created");
}
;


KOBJAnnotateSearchResults.prototype.marker_name = function() {
    return this.name + "_" + this.entry + "_" + this.app.app_id;

};

KOBJAnnotateSearchResults.prototype.annotate = function() {
    if (this.invalid) {
        return;
    }
    KOBJ.loggers.annotate.trace("Annotate called and must have been some what valid");

    var runAnnotate = null;

    if (this.defaults["remote"]) {
       runAnnotate = this.annotate_remote_search();
    } else {
       runAnnotate = this.annotate_normal_search();
    }

    runAnnotate();

    // Watcher is the element which is being watched, runAnnotateLocal is the function to be run
    if (typeof(this.watcher) != "undefined") {
        KOBJ.loggers.annotate.trace("App ID is " + this.app.app_id);
        var dmw = KOBJDomWatch.get_dom_watch("search_annotate",this.change_condition,1000);
        dmw.watch(this.watcher, runAnnotate, KOBJ.get_application(this.app.app_id));
    }
};


KOBJAnnotateSearchResults.prototype.annotate_remote_search =  function() {
    var myself = this;

    KOBJ.loggers.annotate.trace("Remote Annotation Requested");

    var remote_url = this.defaults["remote"];
    KOBJ.loggers.annotate.trace("Remote URL", remote_url);

    KOBJAnnotateSearchResults.annotate_search_counter = KOBJAnnotateSearchResults.annotate_search_counter || 0;
    runAnnotate = function() {

        KOBJ.loggers.annotate.trace("In Remote Annoate Function");
        var resultslist = $KOBJ(myself.lister);

        if (resultslist.length === 0) {
            KOBJ.loggers.annotate.trace("Did not find any results");
            return;
        }

        var count = 0;
        var annotateInfo = {};
        resultslist.each(function() {
            var toAnnotate = this;

            if ($KOBJ(toAnnotate).hasClass(myself.marker_name() + "_anno")) {
                KOBJ.log("Already has marker will not re-annotate");
                return true;
            }

            var itemCounter = myself.marker_name() + "_" + (KOBJAnnotateSearchResults.annotate_search_counter += 1);
            $KOBJ(toAnnotate).addClass(itemCounter);
            $KOBJ(toAnnotate).addClass(myself.marker_name() + "_anno");
            KOBJ.log("Added tracking class");

            annotateInfo[itemCounter] = myself.annotate_search_extractdata(toAnnotate);
        });

        var annotateFunc =  myself.defaults.annotator;

        function annotateCB(data) {
            $KOBJ.each(data, function(key, data) {
                KOBJ.loggers.annotate.trace("Called back from Remote Data Call");
                var contents = annotateFunc(data);
                if (contents) {
                    if ($KOBJ("." + key).find('#' + myself.marker_name() + '_anno_list li').is('.' + myself.marker_name() + '_item')) {
                        $KOBJ("." + key).find('#' + myself.marker_name() + '_anno_list').append(mk_list_item(myself.defaults.sep)).append(myself.mk_list_item(contents));
                    } else {
                        $KOBJ("." + key).find(myself.modify)[myself.defaults.placement](myself.mk_outer_div(contents));
                    }
                }
                count++;
            });
        }


        if (!$KOBJ.isEmptyObject(annotateInfo)) {
            var annotateArray = myself.splitJSONRequest(annotateInfo, remote_url);
            $KOBJ.each(annotateArray, function(key, data) {
                var annotateString = $KOBJ.compactJSON(data);
                KOBJ.loggers.annotate.trace("Making Remote Data Call");
                $KOBJ.getJSON(remote_url, {'annotatedata':annotateString}, annotateCB);
            });


            KOBJ.logger('annotated_search_results', myself.defaults['txn_id'], count, '', 'success', myself.defaults['rule_name'], myself.defaults['rid']);
        }
        myself.callback();

    };
    return runAnnotate;
};

KOBJAnnotateSearchResults.prototype.annotate_normal_search = function() {
    var myself = this;

    KOBJ.loggers.annotate.trace("Local Callback Annotation Requested");
    var runAnnotate = function() {
        var count = 0;
        var already_annotated = 0;
        KOBJ.loggers.annotate.trace("Lister is   ", myself.lister);
        var resultslist = $KOBJ(myself.lister);
        if (resultslist.length === 0) {
            KOBJ.loggers.annotate.trace("Lister length 0");
            return;
        }


        resultslist.each(function() {
            KOBJ.loggers.annotate.trace("Working on result list local");

            var toAnnotate = this;

            if ($KOBJ(toAnnotate).hasClass(myself.marker_name() + "_anno")) {
                KOBJ.loggers.annotate.trace("Already annotated LOCAL");
                already_annotated++;
                return true;
            }

            var extractedData = myself.annotate_search_extractdata(toAnnotate);
            $KOBJ.each(extractedData, function(name, value) {
                $KOBJ(toAnnotate).data(name, value);
            });

            var contents = myself.defaults.annotator(toAnnotate);

            // This lets us know it has already been touched
            $KOBJ(toAnnotate).addClass(myself.marker_name() + "_anno");

            KOBJ.loggers.annotate.trace("Added tracking class");

            if (contents) {
                count++;

                if ($KOBJ(toAnnotate).find('div .' + myself.wrapper_div_class()).length == 0) {
                    KOBJ.loggers.annotate.trace("Add Wrapper Div");
                    var wrapper = $KOBJ("<div>").addClass(myself.wrapper_div_class());
                    wrapper.css(myself.defaults.wrapper_css);
                    $KOBJ(toAnnotate).find(myself.modify)[myself.defaults.placement](wrapper);
                }

                KOBJ.loggers.annotate.trace("Add Contents to wrapper");
                $KOBJ("." + myself.wrapper_div_class(), toAnnotate).append(contents);
            }
        });
        KOBJ.loggers.annotate.trace("About to log");
        if (count > 0) {
            KOBJ.logger('annotated_search_results', myself.defaults['txn_id'], count, '', 'success', myself.defaults['rule_name'],
                    myself.defaults['rid']);
        }
        KOBJ.loggers.annotate.trace("Calling Callback");

        myself.callback();
    };
    return runAnnotate;
};


KOBJAnnotateSearchResults.prototype.wrapper_div_class = function() {
   return this.name + '_anno_item';
};


//KOBJAnnotateSearchResults.prototype.mk_list_item = function(i) {
//    return $KOBJ("<li class='" + this.marker_name() + "_item'>").css(this.defaults.li_css).append(i);
//};
//
//KOBJAnnotateSearchResults.prototype.mk_outer_div = function(anchor) {
//    var name = this.app.app_id;
//    var logo_item = this.mk_list_item(anchor);
//    var logo_list = $KOBJ('<ul>').css(this.defaults.ul_css).attr("id", name + "_anno_list").append(logo_item);
//    var inner_div = $KOBJ('<div>').css(this.defaults.inner_div_css).append(logo_list);
//    if (this.defaults['tail_image']) {
//        inner_div.css({
//            "background-image": "url(" + this.defaults['tail_image'] + ")",
//            "background-repeat": "no-repeat",
//            "background-position": "right top"
//        });
//    }
//    var outer_div = $KOBJ('<div>').css(this.defaults.outer_div_css).append(inner_div);
//    if (this.defaults['head_image']) {
//        outer_div.css({
//            "background-image": "url(" + this.defaults['head_image'] + ")",
//            "background-repeat": "no-repeat",
//            "background-position": "left top"
//        });
//    }
//    return outer_div;
//};


KOBJAnnotateSearchResults.prototype.splitJSONRequest = function(json, url) {

    var jsonString = $KOBJ.compactJSON(json);
    var numOfRequests = Math.ceil((jsonString.length + url.length) / this.maxURLLength);
    KOBJ.loggers.annotate.trace("The number of requests to be made is: " + numOfRequests);
    if (numOfRequests > 1) {
        KOBJ.loggers.annotate.trace("The length of the annotation request would be too large. Splitting into " + numOfRequests + " requests.");
        var toReturn = [];
        var count = 1;
        $KOBJ.each(json, function(index) {
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


// Extracts the data from the element
KOBJAnnotateSearchResults.prototype.annotate_search_extractdata = function(toAnnotate) {

    var annotateData = {};
    var urlSelector = this.defaults.domains[window.location.host].urlSel;
    var urlTemp = $KOBJ(toAnnotate).find(urlSelector).attr("href");
    // ".l" is for Google, ".nc_tc, .sb_tlst" are for Bing, .yschttl is for Yahoo

    if (!urlTemp) {
        urlTemp = $KOBJ(toAnnotate).find(".url, cite").attr("href");
        // Failsafe
    }

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


