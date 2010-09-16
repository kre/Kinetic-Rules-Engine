function KOBJAnnotateSearchResults(app, config, callback) {
    KOBJ.loggers.annotate.trace("Initing Annotate");

    this.defaults = {
        "name": "KOBJ",
        "sep": "<div style='padding-top: 13px'>|</div>",
        "text_color": "#CCC",
        "height": "40px",
        "left_margin": "15px",
        "right_padding": "15px",
        "font_size": "12px",
        "font_family": "Verdana, Geneva, sans-serif",
        "placement" : 'prepend',
        "results_lister" : "",
        "element_to_modify" : "div.s,div.abstr,p",
        "domains": {
            "www.google.com": { "selector": "li.g:not(.localbox), div.g", "modify": "div.s", "watcher": "#rso", "urlSel":".l" },
            "www.bing.com": { "selector": "#results>ul>li", "modify": "p", "watcher": "","urlSel":".nc_tc a, .sb_tlst a" },
            "search.yahoo.com": { "selector": "li div.res", "modify": "div.abstr", "watcher": "","urlSel":".yschttl" }
        }
    };

    this.defaults["outer_div_css"] = {
        "float": "right",
        "width": "auto",
        "height": this.defaults.height,
        "font-size": this.defaults.font_size,
        "line-height": "normal",
        "font-family": this.defaults.font_family
    };

    this.defaults["li_css"] = {
        "float": "left",
        "margin": "0",
        "vertical-align": "middle",
        "padding-left": "4px",
        "color": this.defaults.text_color,
        "white-space": "nowrap",
        "text-align": "center"
    };
    this.defaults["ul_css"] = {
        "margin": "0",
        "padding": "0",
        "list-style": "none"
    };
    this.defaults["inner_div_css"] = {
        "float": "left",
        "display": "inline",
        "height": this.defaults.height,
        "margin-left": this.defaults.left_margin,
        "padding-right": this.defaults.right_padding
    };


    this.app = app;
    this.maxURLLength = 1800;
    this.callback = callback;

    KOBJ.loggers.annotate.trace("Ext Annotate");

    if (typeof config === 'object') {
        $KOBJ.extend(true, this.defaults, config);
    }

    KOBJ.loggers.annotate.trace("DExt Annotate");

    this.lister = "";
    this.modify = "";
    this.watcher = "";
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
    } else {
        this.invalid = true;
    }
    KOBJ.loggers.annotate.trace("Annotate Object Created");
}
;


KOBJAnnotateSearchResults.prototype.annotate = function(datasetdata) {
    if (this.invalid) {
        return;
    }
    KOBJ.loggers.annotate.trace("Annotate called and must have been some what valid");

    var runAnnotate = null;
    var myself = this;

    if (this.defaults["remote"]) {
        KOBJ.loggers.annotate.trace("Remote Annotation Requested");

        var remote_url = this.defaults["remote"];

        KOBJAnnotateSearchResults.annotate_search_counter = KOBJAnnotateSearchResults.annotate_search_counter || 0;
        runAnnotate = function() {

            var resultslist = $KOBJ(this.lister);
            if (resultslist.length === 0) {
                return;
            }
            var count = 0;
            var annotateInfo = {};
            resultslist.each(function() {
                var toAnnotate = this;
                var itemCounter = myself.defaults['name'] + (KOBJAnnotateSearchResults.annotate_search_counter += 1);

                annotateInfo[itemCounter] = myself.annotate_search_extractdata(toAnnotate, myself.defaults);
                $KOBJ(toAnnotate).addClass(itemCounter);
            });

            var annotateFunc = function() {
            };

            if (myself.annotate) {
                annotateFunc = myself.annotate;
            } else {
                annotateFunc = function(data) {
                    return data;
                };
            }

            function annotateCB(data) {
                $KOBJ.each(data, function(key, data) {
                    var contents = annotateFunc(data);
                    if (contents) {
                        if ($KOBJ("." + key).find('#' + myself.defaults.name + '_anno_list li').is('.' + myself.defaults.name + '_item')) {
                            $KOBJ("." + key).find('#' + myself.defaults.name + '_anno_list').append(mk_list_item(myself.defaults.sep)).append(mk_list_item(contents));
                        } else {
                            $KOBJ("." + key).find(modify)[myself.defaults.placement](mk_outer_div(contents));
                        }
                    }
                    count++;
                });
            }

            var annotateArray = this.splitJSONRequest(annotateInfo, remote_url);
            $KOBJ.each(annotateArray, function(key, data) {
                var annotateString = $KOBJ.compactJSON(data);
                $KOBJ.getJSON(remote_url, {'annotatedata':annotateString}, annotateCB);
            });

            KOBJ.logger('annotated_search_results', myself.defaults['txn_id'], count, '', 'success', myself.defaults['rule_name'], myself.defaults['rid']);
            cb();

        };

    } else {
        KOBJ.loggers.annotate.trace("Local Callback Annotation Requested");
        runAnnotate = function() {
            var count = 0;

            KOBJ.loggers.annotate.trace("Lister is   ", myself.lister);
            var resultslist = $KOBJ(myself.lister);
            if (resultslist.length === 0) {
                KOBJ.loggers.annotate.trace("Lister length 0");
                return;
            }


            resultslist.each(function() {
                KOBJ.loggers.annotate.trace("Working on result list");

                var toAnnotate = this;
                var extractedData = myself.annotate_search_extractdata(toAnnotate, myself.defaults);
                $KOBJ.each(extractedData, function(name, value) {
                    $KOBJ(toAnnotate).data(name, value);
                });
                var contents = myself.callback(toAnnotate);
                if (contents) {
                    count++;
                    if ($KOBJ(toAnnotate).find('#' + myself.defaults.name + '_anno_list li').is('.' + myself.defaults.name + '_item')) {
                        $KOBJ(toAnnotate).find('#' + myself.defaults.name + '_anno_list').append(mk_list_item(myself.defaults.sep)).append(mk_list_item(contents));
                    } else {

                        $KOBJ(toAnnotate).find(modify)[myself.defaults.placement](mk_outer_div(contents));
                    }
                }
            });
            KOBJ.loggers.annotate.trace("About to log");
            KOBJ.logger('annotated_search_results', myself.defaults['txn_id'], count, '', 'success', myself.defaults['rule_name'],
                    myself.defaults['rid']);
            KOBJ.loggers.annotate.trace("Calling Callback");

            //cb();
        };


    }

    runAnnotate();

    // Watcher is the element which is being watched, runAnnotateLocal is the function to be run
//    if (typeof(watcher) != "undefined") {
//        KOBJDomWatch.watch(watcher, runAnnotate, KOBJ.get_application(config['rid']));
//    }


};


KOBJAnnotateSearchResults.prototype.mk_list_item = function(i) {
    return $KOBJ("<li class='" + this.defaults.name + "_item'>").css(this.defaults.li_css).append(i);
}

KOBJAnnotateSearchResults.prototype.mk_outer_div = function(anchor) {
    var name = this.defaults.name;
    var logo_item = mk_list_item(anchor);
    var logo_list = $KOBJ('<ul>').css(this.defaults.ul_css).attr("id", name + "_anno_list").append(logo_item);
    var inner_div = $KOBJ('<div>').css(this.defaults.inner_div_css).append(logo_list);
    if (this.defaults['tail_image']) {
        inner_div.css({
            "background-image": "url(" + this.defaults['tail_image'] + ")",
            "background-repeat": "no-repeat",
            "background-position": "right top"
        });
    }
    var outer_div = $KOBJ('<div>').css(this.defaults.outer_div_css).append(inner_div);
    if (this.defaults['head_image']) {
        outer_div.css({
            "background-image": "url(" + this.defaults['head_image'] + ")",
            "background-repeat": "no-repeat",
            "background-position": "left top"
        });
    }
    return outer_div;
}


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
KOBJAnnotateSearchResults.prototype.annotate_search_extractdata = function(toAnnotate, config) {

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


