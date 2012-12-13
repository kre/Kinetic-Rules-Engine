KOBJ.maxURLLength = 1800;

KOBJ.splitJSONRequest = function(json, maxLength, url) {

    var jsonString = $KOBJ.compactJSON(json);
    var numOfRequests = Math.ceil((jsonString.length + url.length) / maxLength);
    KOBJ.log("The number of requests to be made is: " + numOfRequests);
    if (numOfRequests > 1) {
        KOBJ.log("The length of the annotation request would be too large. Splitting into " + numOfRequests + " requests.");
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

KOBJ.getJSONP = function(url, data, cb) {
    KOBJ.log("getJSON with JSONP");
    $KOBJ.getJSON(url, data, cb);
};

// Start of annotate local changes, v1.2


// KOBJ.annotate_local_search_extractdata pulls the data out automatically, such as phone and domain.

KOBJ.annotate_local_search_extractdata = function(toAnnotate, config) {

    var annotateData = {};
    var phoneSelector = config.domains[window.location.host].phoneSel;
    var urlSelector = config.domains[window.location.host].phoneSel;
    var phoneTemp = $KOBJ(toAnnotate).find(phoneSelector).text().replace(/[\u00B7() -]/g, "");
    var urlTemp = $KOBJ(toAnnotate).find(urlSelector).attr("href");

    if (!urlTemp) {
        urlTemp = $KOBJ(toAnnotate).find(".url, cite").text();
        if (!urlTemp) {
            urlTemp = $KOBJ(toAnnotate).find("li:eq(1) a").attr("href");
        }
        // Failsafe
    }
    if (urlTemp) {
        annotateData["url"] = urlTemp;
        annotateData["domain"] = KOBJ.get_host(urlTemp);
    } else {
        annotateData["url"] = "";
        annotateData["domain"] = "";
    }
    if (phoneTemp === "") {
        phoneTemp = $KOBJ(toAnnotate);
        phoneTemp = phoneTemp.text().match(/\(\d{3}\)\s\d{3}-\d{4}/, "$1");
        if (phoneTemp !== null) {
            phoneTemp = phoneTemp[0];
            phoneTemp = phoneTemp.replace(/[() -]/g, "");
        }
    }


    var heightTemp = $KOBJ(toAnnotate).height();

    if (phoneTemp !== null) {
        annotateData["phone"] = phoneTemp;
    } else {
        annotateData["phone"] = "";
    }
    annotateData["height"] = heightTemp;
    return annotateData;
};

// Defaults for both with and without remote.
// The "domains" element provides selector on a site by site basis

KOBJ.annotate_local_search_defaults = {
    "name": "KOBJL",
    "domains":{
        "www.google.com":{"selector":".localbox .ts .g table+div,.g>.ts>tbody>tr>td:has(cite):not(:has(table)):not(:has(div)),#results td:last-child:has(h4):not(:has(table)):has(cite),.g table.ts tr td:last:not(:has(img)):has(cite),.g>table tbody tr td:has(h3):has(cite),.g>table tbody tr td table tr:has(.fl):has(cite)","watcher":"#rso","phoneSel":".nobr","urlSel":".l"},
        "search.yahoo.com":{"selector":".res.sc-ng.sc-lc-bz-m div.content>ol>li,#yls-rs-res tbody tr .yls-rs-bizinfo,.vcard","watcher": "","phoneSel":"[id *= lblPhone]","urlSel":".yschttl"},
        "www.bing.com":{"selector":".sc_ol1li, #srs_orderedList>.llsResultItem","watcher": "","phoneSel":".sc_hl1 li>:not(a)","urlSel":".nc_tc a, .sb_tlst a"},
        "maps.google.com":{"selector":"#resultspanel .res div.one:visible","watcher":"#spsizer .opanel:visible","phoneSel":".tel","urlSel":".fn.org"},
        "local.yahoo.com":{"selector":"#yls-rs-res tr.yls-rs-listinfo","watcher":"","phoneSel":".tel","urlSel":".yls-rs-listing-title"}

    }
};

// New Annotate Local function v 2.0
// Includes DOM watching, seperating selector based on site, and some speed improvements

KOBJ.annotate_local_search_results = function(annotate, config, cb) {
    var defaults = $KOBJ.extend(true, {}, KOBJ.annotate_local_search_defaults);

    if (typeof config === 'object') {
        $KOBJ.extend(true, defaults, config);
    }
    //get domain's lister
    if (defaults["domains"][window.location.hostname]) {
        // Gets selector for both the DOM watcher and to get element
        var lister = defaults["domains"][window.location.hostname]["selector"];
        var watcher = defaults["domains"][window.location.hostname]["watcher"];
    } else {
        return;
    }
    var runAnnotateLocal = null;
    if (defaults["remote"]) {

        var remote_url = defaults["remote"];
        KOBJ.annotate_local_counter = KOBJ.annotate_local_counter || 0;
        var maxLengthURL = KOBJ.maxURLLength;

        runAnnotateLocal = function() {
            var count = 0;

            var annotateFuncLocal = function() {
            };

            if (annotate) {
                annotateFuncLocal = annotate;
            } else {
                annotateFuncLocal = function(data) {
                    return data;
                };
            }

            function annotateCBLocal(data) {
                $KOBJ.each(data, function(key, data) {
                    var contents = annotateFuncLocal(data);
                    if (contents) {
                        $KOBJ("." + key + " :last").after(contents);
                        count++;
                    }
                });
                cb();
            }

            var annotateInfo = {};

            $KOBJ(lister).each(function() {
                var toAnnotate = this;
                var itemCounter = defaults["name"] + (KOBJ.annotate_local_counter += 1);

                annotateInfo[itemCounter] = KOBJ.annotate_local_search_extractdata(toAnnotate, defaults);
                $KOBJ(toAnnotate).addClass(itemCounter);
            });


            var annotateArray = KOBJ.splitJSONRequest(annotateInfo, maxLengthURL, remote_url);
            $KOBJ.each(annotateArray, function(key, data) {
                var annotateString = $KOBJ.compactJSON(data);
                KOBJ.getJSONP(remote_url, {'annotatedata':annotateString}, annotateCBLocal);
            });


            KOBJ.logger('annotated_local_search_results', config['txn_id'], count, '', 'success', config['rule_name'], config['rid']);
        };

    } else {
        runAnnotateLocal = function() {
            var resultslist = $KOBJ(lister);
            if (resultslist.length === 0) {
                return;
            }
            var count = 0;
            $KOBJ(resultslist).each(function() {

                var toAnnotate = this;

                var extractedData = KOBJ.annotate_local_search_extractdata(toAnnotate, defaults);
                // Inserts the data into the object.
                $KOBJ.each(extractedData, function(name, value) {
                    $KOBJ(toAnnotate).data(name, value);
                });

                var contents = annotate(toAnnotate);
                if (contents) {
                    count++;
                    $KOBJ(":last", this).after(contents);
                }
            });

            KOBJ.logger('annotated_search_results', config['txn_id'], count, '', 'success', config['rule_name']);
            cb();
        };

    }

    runAnnotateLocal();


    // Watcher is the element which is being watched, runAnnotateLocal is the function to be run
    if (typeof(watcher) != "undefined") {
        KOBJ.watchDOM(watcher, runAnnotateLocal);
    }

};

// End annotate local

// New annotate code v1.3
// Includes DOM watching, seperating selectors based on site, and some speed improvements

KOBJ.annotate_search_defaults = {
    "name": "KOBJ",
    "sep": "<div style='padding-top: 13px'>|</div>",
    "text_color": "#CCC",
    "height": "40px",
    "left_margin": "15px",
    "right_padding": "15px",
    "font_size": "12px",
    "font_family": "Verdana, Geneva, sans-serif",
    "placement" : 'prepend',
    "outer_div_css" : 0,
    "inner_div_css" : 0,
    "li_css" : 0,
    "ul_css" : 0,
    "results_lister" : "",
    "element_to_modify" : "div.s,div.abstr,p",
    "domains": {
        "www.google.com": { "selector": "li.g:not(.localbox), div.g", "modify": "div.s", "watcher": "#rso", "urlSel":".l" },
        "www.bing.com": { "selector": "#results>ul>li", "modify": "p", "watcher": "","urlSel":".nc_tc a, .sb_tlst a" },
        "search.yahoo.com": { "selector": "li div.res", "modify": "div.abstr", "watcher": "","urlSel":".yschttl" }
    }

};


// Extracts the data from the element
KOBJ.annotate_search_extractdata = function(toAnnotate, config) {

    var annotateData = {};
    var urlSelector = config.domains[window.location.host].urlSel;
    var urlTemp = $KOBJ(toAnnotate).find(urlSelector).attr("href");
    // ".l" is for Google, ".nc_tc, .sb_tlst" are for Bing, .yschttl is for Yahoo

    if (!urlTemp) {
        urlTemp = $KOBJ(toAnnotate).find(".url, cite").attr("href");
        // Failsafe
    }

    if(window.location.host == "search.yahoo.com" && urlTemp.indexOf("**http") != -1){
		urlTemp = urlTemp.replace(/.*\*\*/,"");
		urlTemp = urlTemp.replace(/%3a/,":");
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

KOBJ.annotate_search_results = function(annotate, config, cb) {

    var defaults = $KOBJ.extend(true, {}, KOBJ.annotate_search_defaults);
    if (typeof config === 'object') {
        $KOBJ.extend(true, defaults, config);
    }

    defaults.outer_div_css = {
        "float": "right",
        "width": "auto",
        "height": defaults.height,
        "font-size": defaults.font_size,
        "line-height": "normal",
        "font-family": defaults.font_family
    };

    defaults.li_css = {
        "float": "left",
        "margin": "0",
        "vertical-align": "middle",
        "padding-left": "4px",
        "color": defaults.text_color,
        "white-space": "nowrap",
        "text-align": "center"
    };

    defaults.ul_css = {
        "margin": "0",
        "padding": "0",
        "list-style": "none"
    };

    defaults.inner_div_css = {
        "float": "left",
        "display": "inline",
        "height": defaults.height,
        "margin-left": defaults.left_margin,
        "padding-right": defaults.right_padding
    };

    if (typeof config === 'object') {
        $KOBJ.extend(true, defaults, config);
    }


    var lister = "";
    var modify = "";
    var watcher = "";

    if (defaults["results_lister"]) {
        lister = defaults["results_lister"];
        watcher = "";
        modify = defaults["element_to_modify"];
    } else if (defaults["domains"][window.location.hostname]) {
        // Gets selectors for both DOM watcher and the element
        lister = defaults["domains"][window.location.hostname]["selector"];
        watcher = defaults["domains"][window.location.hostname]["watcher"];
        modify = defaults["domains"][window.location.hostname]["modify"];
    } else {
        return;
    }

    function mk_list_item(i) {
        return $KOBJ("<li class='" + defaults.name + "_item'>").css(defaults.li_css).append(i);
    }

    function mk_outer_div(anchor) {
        var name = defaults.name;
        var logo_item = mk_list_item(anchor);
        var logo_list = $KOBJ('<ul>').css(defaults.ul_css).attr("id", name + "_anno_list").append(logo_item);
        var inner_div = $KOBJ('<div>').css(defaults.inner_div_css).append(logo_list);
        if (typeof defaults != 'undefined' && defaults['tail_image']) {
            inner_div.css({
                "background-image": "url(" + defaults['tail_image'] + ")",
                "background-repeat": "no-repeat",
                "background-position": "right top"
            });
        }
        var outer_div = $KOBJ('<div>').css(defaults.outer_div_css).append(inner_div);
        if (typeof defaults != 'undefined' && defaults['head_image']) {
            outer_div.css({
                "background-image": "url(" + defaults['head_image'] + ")",
                "background-repeat": "no-repeat",
                "background-position": "left top"
            });
        }
        return outer_div;
    }

    var runAnnotate = null;
    if (defaults["remote"]) {

        var remote_url = defaults["remote"];
        var maxLengthURL = KOBJ.maxURLLength;

        KOBJ.annotate_search_counter = KOBJ.annotate_search_counter || 0;
        runAnnotate = function() {

            var resultslist = $KOBJ(lister);
            if (resultslist.length === 0) {
                return;
            }
            var count = 0;
            var annotateInfo = {};
            resultslist.each(function() {
                var toAnnotate = this;
                var itemCounter = defaults['name'] + (KOBJ.annotate_search_counter += 1);

                annotateInfo[itemCounter] = KOBJ.annotate_search_extractdata(toAnnotate, defaults);
                $KOBJ(toAnnotate).addClass(itemCounter);
            });

            var annotateFunc = function() {
            };

            if (annotate) {
                annotateFunc = annotate;
            } else {
                annotateFunc = function(data) {
                    return data;
                };
            }

            function annotateCB(data) {
                $KOBJ.each(data, function(key, data) {
                    var contents = annotateFunc(data);
                    if (contents) {
                        if ($KOBJ("." + key).find('#' + defaults.name + '_anno_list li').is('.' + defaults.name + '_item')) {
                            $KOBJ("." + key).find('#' + defaults.name + '_anno_list').append(mk_list_item(defaults.sep)).append(mk_list_item(contents));
                        } else {
                            $KOBJ("." + key).find(modify)[defaults.placement](mk_outer_div(contents));
                        }
                    }
                    count++;
                });
            }

            var annotateArray = KOBJ.splitJSONRequest(annotateInfo, maxLengthURL, remote_url);
            $KOBJ.each(annotateArray, function(key, data) {
                var annotateString = $KOBJ.compactJSON(data);
                KOBJ.getJSONP(remote_url, {'annotatedata':annotateString}, annotateCB);
            });

            KOBJ.logger('annotated_search_results', config['txn_id'], count, '', 'success', config['rule_name'], config['rid']);
            cb();

        };

    } else {
        runAnnotate = function() {
            var count = 0;

            var resultslist = $KOBJ(lister);
            if (resultslist.length === 0) {
                return;
            }
            
            resultslist.each(function() {

                var toAnnotate = this;
                var extractedData = KOBJ.annotate_search_extractdata(toAnnotate, defaults);
                $KOBJ.each(extractedData, function(name, value) {
                    $KOBJ(toAnnotate).data(name, value);
                });
                var contents = annotate(toAnnotate);
                if (contents) {
                    count++;
                    if ($KOBJ(toAnnotate).find('#' + defaults.name + '_anno_list li').is('.' + defaults.name + '_item')) {
                        $KOBJ(toAnnotate).find('#' + defaults.name + '_anno_list').append(mk_list_item(defaults.sep)).append(mk_list_item(contents));
                    } else {

                        $KOBJ(toAnnotate).find(modify)[defaults.placement](mk_outer_div(contents));
                    }
                }
            });
            KOBJ.logger('annotated_search_results', config['txn_id'], count, '', 'success', config['rule_name'], config['rid']);
            cb();
        };


    }

    runAnnotate();

    // Watcher is the element which is being watched, runAnnotateLocal is the function to be run
    if (typeof(watcher) != "undefined") {
        KOBJ.watchDOM(watcher, runAnnotate);
    }
};

// End new annotate code

