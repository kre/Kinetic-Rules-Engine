if (typeof(KOBJAnnotateSearchResults) == 'undefined') {
    (function() {
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
                "scope": "S" + KOBJEventManager.eid(),
                "maxURLLength" : KOBJ.max_url_length(),
                "wrapper_css" : { "display" : "none" },
                "placement" : 'append',
                "flush_domains" : false,
                "use_change_condition": true,
                "domains": {
                    "www.google.com": {
                        "selector": "li.g:not(.localbox), div.g",
                        "modify": "div.s",
                        "watcher": "#rso",
                        "urlSel":".l",
                        "change_condition": KOBJAnnotateSearchResults.google_search_change_condition,
                        "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
                    },
                    "search.aol.com": {
                        "selector": ".MSL li",
                        "modify": "p[property='f:desc']",
                        "watcher": "",
                        "urlSel":"a[rel='f:url']",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
                    },
                    "www.bing.com": {
                        "selector": "#results div.sa_cc",
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
                    },
                    "www.hotbot.com": {
                        "selector": "p.res",
                        "modify": "",
                        "watcher": "",
                        "urlSel":"a",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
                    },
                    "www.ask.com" : {
                        "selector": "#teoma-results .tsrc_lxlx, #psa-teoma-result #result-table .pad",
                        "modify": "",
                        "watcher": "",
                        "urlSel":".title",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
                    },
                    "www.alltheweb.com" : {
                        "selector": ".resultWell .result",
                        "modify": ".resTeaser",
                        "watcher": "",
                        "urlSel":".res",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
                    }
                    ,
                    "www.altavista.com" : {
                        "selector": "a.res",
                        "modify": KOBJAnnotateSearchResults.altavisa_custom_modify,
                        "watcher": "",
                        "urlSel":"",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateSearchResults.annotate_search_extractdata
                    },
                    "www.facebook.com" : {
                        "selector": ".uiUnifiedStory",
                        "modify": ".commentable_item",
                        "watcher": "#pagelet_home_stream",
                        "placement" : 'before',
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateSearchResults.annotate_facebook_extractdata
                    },
                    "www.linkedin.com" : {
                        "selector": "ul.chron li",
                        "modify": ".feed-actions",
                        "watcher": "",
                        "placement" : 'before',
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateSearchResults.annotate_linkedin_extractdata
                    }
                }
            };

            // TODO : Add about.com, twitter.com

            this.domain_name = an_config.domain_override || window.location.hostname;


            if (an_config.remote && an_config.remote == "event") {
                this.defaults.maxURLLength = 700;

            }
            // Lets merge our defaults  and with what comes in the config
            // Careful this is a deep merge.
            if (typeof an_config === 'object') {
                if (an_config.flush_domains == true) {
                    delete this.defaults.domains;
                }
                $KOBJ.extend(true, this.defaults, an_config);
            }


            KOBJ.loggers.annotate.trace("Annotate Domain " + this.domain_name);
            // domain not find ignore.
            if (this.defaults.domains[this.domain_name] == null) {
                this.invalid = true;
                return;
            }

            // If the domain / name we are working with overrides css do it here.
            if (this.defaults.domains[this.domain_name]["wrapper_css"]) {
                this.defaults.wrapper_css = this.defaults.domains[this.domain_name]["wrapper_css"];
            }

            KOBJ.loggers.annotate.trace("1 Placement Overridden with " + this.defaults["placement"]);
            KOBJ.loggers.annotate.trace("2 Placement Overridden with " + this.defaults.domains[this.domain_name]["placement"]);

            if (this.defaults.domains[this.domain_name]["placement"]) {
                this.defaults.placement = this.defaults.domains[this.domain_name]["placement"];
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
            this.instance_id = "A" + KOBJEventManager.eid();

            if (this.defaults.domains[this.domain_name]) {
                // Gets selectors for both DOM watcher and the element
                this.lister = this.defaults.domains[this.domain_name]["selector"];
                this.watcher = this.defaults.domains[this.domain_name]["watcher"];
                this.modify = this.defaults.domains[this.domain_name]["modify"];

                if (this.defaults.domains[this.domain_name]["change_condition"]) {
                    this.change_condition = this.defaults.domains[this.domain_name]["change_condition"];
                }

                if (this.defaults.domains[this.domain_name]["extract_function"]) {
                    if (typeof(this.defaults.domains[this.domain_name]["extract_function"]) == "function")
                        this.extract_function = this.defaults.domains[this.domain_name]["extract_function"];
                    else {
                        var extractor = this.defaults.domains[this.domain_name]["extract_function"];
                        this.extract_function = function(toAnnotate) {
                            return eval(extractor + "(toAnnotate)");
                        }
                    }
                }

            } else {
                this.invalid = true;
            }

            if (!this.defaults.use_change_condition) {
                this.change_condition = false;
            }
            KOBJAnnotateSearchResults.instances[this.instance_id] = this;

            KOBJ.loggers.annotate.trace("Annotate Object Created");
        }

        ;

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
                KOBJ.loggers.annotate.trace("Page is not stable url did not change");
                return false;
            }

            var about_to_be_typed = $KOBJ("#tsf input[name='q']").prev().text();
            var search_field = $KOBJ("#tsf input[name='q']").val();

            if (KOBJ.urlDecode(current_query.oq) == search_field || KOBJ.urlDecode(current_query.q) == search_field ||
                    KOBJ.urlDecode(current_query.oq) == about_to_be_typed || KOBJ.urlDecode(current_query.q) == about_to_be_typed) {
                KOBJ.loggers.annotate.trace("Page considered stable.");
                return true;
            }
            KOBJ.loggers.annotate.trace("Page is not stable");

            return false;
        };


        KOBJAnnotateSearchResults.instances = { };


        KOBJAnnotateSearchResults.true_change_condition = function() {
            return true;
        };


        /* For the pages we support annotation out of the box this method will extract the wanted
         "data" elements and store them so that the annotating function can use it to figure
         out what should be annotated.
         */
        KOBJAnnotateSearchResults.annotate_search_extractdata = function(toAnnotate, annotator) {

            var annotateData = {};
            var urlSelector = annotator.defaults.domains[this.domain_name].urlSel;
            var urlTemp = "";

            if (urlSelector == "") {
                KOBJ.loggers.annotate.trace("Searching ourselfs");
                urlTemp = $KOBJ(toAnnotate).attr("href");
            }
            else {
                KOBJ.loggers.annotate.trace("Search by selector");
                urlTemp = $KOBJ(toAnnotate).find(urlSelector).attr("href");
            }

            // Yahoo sometime put tracking url befor ethe real url.   We strip the tracking url out here.
            if (urlTemp && urlTemp.indexOf() == "av.rds.yahoo.com" != -1 && urlTemp.indexOf("**http") != -1) {
                urlTemp = urlTemp.replace(/.*\*\*/, "");
                urlTemp = KOBJ.urlDecode(urlTemp); //.replace(/%3a/, ":");
            }

            if (urlTemp) {
                annotateData["url"] = urlTemp;
                annotateData["domain"] = KOBJ.get_host(urlTemp);
            } else {
                annotateData["url"] = "";
                annotateData["domain"] = "";
            }

            KOBJ.loggers.annotate.trace("Extracted DAta ", annotateData);

            return annotateData;
        };

        /*
         Altavisa has a strange layout so we need a special way to put the annotation
         */
        KOBJAnnotateSearchResults.altavisa_custom_modify = function(toAnnotate, placement, wrapper) {
            $KOBJ(toAnnotate).next().next()[placement](wrapper);
        };

        /*
         Facebook data is not really links but names and images
         */
        KOBJAnnotateSearchResults.annotate_facebook_extractdata = function(toAnnotate, annotator) {

            var annotateData = {};

            annotateData["name"] = $KOBJ($KOBJ(toAnnotate).find(".actorName a,a.passiveName,span.UIIntentionalStory_Names a")[0]).text();
            annotateData["profile_image"] = $KOBJ($KOBJ(toAnnotate).find(".uiProfilePhoto")).attr("src");

            KOBJ.loggers.annotate.trace(annotateData);

            return annotateData;
        };


        /*
         Linked in data is the persons name and their linked in id also known as a mid.
         */
        KOBJAnnotateSearchResults.annotate_linkedin_extractdata = function(toAnnotate, annotator) {

            var annotateData = {};
            if ($KOBJ(toAnnotate).attr("data-config") == null) {
                return { "mid" :  null, "name" : null};
            }
            annotateData = $KOBJ(toAnnotate).attr("data-config").replace("mid", "'mid'").replace("name", "'name'").replace(/'/g, '"');

            annotateData = $KOBJ.parseJSON(annotateData);

            KOBJ.loggers.annotate.trace(annotateData);

            return annotateData;
        };


        /*
         Used to name the annotated item with a marker that allow use to know if it has already been
         looked at for  anno.
         */
        KOBJAnnotateSearchResults.prototype.app_marker = function() {
            return this.name + "_" + this.defaults.scope + "_" + this.app.app_id + "_anno";
        };

        /*
         Used to name the annotated item with a marker that allow use to uniquely label each item so that
         remote annotations can say what item is to be annotated in their results.
         */
        KOBJAnnotateSearchResults.prototype.app_marker_count = function() {
            return this.app_marker() + "_" + (this.annotate_search_counter += 1);
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

            if (this.defaults["remote"] == "event") {
                runAnnotate = this.annotate_event_search();
            } else if (this.defaults["remote"]) {
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

            list_results = [];

            if (typeof(myself.lister) == "function") {
                list_results = myself.lister();
            }
            else {
                list_results = $KOBJ(myself.lister)
            }
            $KOBJ.each(list_results, function() {
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
                    if (myself.modify == "") {
                        $KOBJ(toAnnotate)[myself.defaults.placement](wrapper);
                    }
                    else if (typeof(myself.modify) == "function") {
                        myself.modify(toAnnotate, myself.defaults.placement, wrapper);
                    } else {
                        $KOBJ(toAnnotate).find(myself.modify)[myself.defaults.placement](wrapper);
                    }
                    $KOBJ(toAnnotate).data("wrapper" + myself.defaults.scope, wrapper);
                }

                var extract_data = myself.extract_function(toAnnotate, myself);

                // We attached the extracted data to the element for easy access later.
//        $KOBJ.each(extract_data, function(name, value) {
//            $KOBJ(toAnnotate).data(name, value);
//        });

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

        KOBJAnnotateSearchResults.prototype.annotate_event_search = function() {
            var myself = this;
            KOBJ.loggers.annotate.trace("Event Annotation Requested ");

            var runAnnotate = function() {
                KOBJ.loggers.annotate.trace("In Event Annotate Function");

                var remote_url = myself.defaults["remote"];
                var annotateInfo = myself.collect_and_label();
                var count = 0;

                if (!$KOBJ.isEmptyObject(annotateInfo)) {
                    var annotateArray = myself.splitJSONRequest(annotateInfo, remote_url);
                    $KOBJ.each(annotateArray, function(key, data) {
                        var annotateString = $KOBJ.compactJSON(data);
                        myself.app.raise_event("annotate_search", {
                            "name":myself.name,
                            "scope":myself.defaults.scope,
                            "annotate_instance" : myself.instance_id,
                            "annotatedata":annotateString
                        });
                    });
                }
                myself.callback();
            };

            return runAnnotate;

        };

        KOBJAnnotateSearchResults.receive_annotation_data = function(annotation_id, data, instance_id) {
            var anno = KOBJAnnotateSearchResults.instances[instance_id];
            if (!anno) {
                KOBJ.log("Did not find annotation object for id " + instance_id);
                return;
            }
            KOBJ.log("Calling annotate data with ");
            KOBJ.log(data);
            var hashinfo = {};
            hashinfo[annotation_id] = data;

            anno.annotate_data(hashinfo);
        }
                ;

        KOBJAnnotateSearchResults.receive_annotation = function(annotation_id, html, instance_id) {
            var anno = KOBJAnnotateSearchResults.instances[instance_id];
            if (!anno) {
                KOBJ.log("Did not find annotation object for id " + instance_id);
                return;
            }

            var toAnnotate = $KOBJ("." + annotation_id);
            var container = $KOBJ(toAnnotate.data("wrapper" + anno.defaults.scope));
            if (html) {
                container.append(html);
                container.show();
            }
        };


        /*
         Data should look like
         { item_id : {data attributes} }
         */
        KOBJAnnotateSearchResults.prototype.annotate_data = function(data) {
            var count = 0;
            var myself = this;

            KOBJ.loggers.annotate.trace("Anno Data Call: ", data);
            // Here item_id is the unique id we put on the item we are annotating.
            $KOBJ.each(data, function(item_id, item_data) {
                KOBJ.loggers.annotate.trace("Working on result list local");
                count++;
                var toAnnotate = $KOBJ("." + item_id);
                var container = $KOBJ(toAnnotate.data("wrapper" + myself.defaults.scope));
                KOBJ.loggers.annotate.trace("Item Data: ", item_data);
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
                annotate_data[item_id] = item_data.data;
            });

            return annotate_data;
        };

        KOBJAnnotateSearchResults.prototype.splitJSONRequest = function(json, url) {

            var to_compact = this.data_only(json);
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
                return [to_compact];
            }
        };


        /* For the pages we support annotation out of the box this method will extract the wanted
         "data" elements and store them so that the annotating function can use it to figure
         out what should be annotated.
         */
        KOBJAnnotateLocalSearchResults.annotate_local_search_extractdata = function(toAnnotate, annotator) {
            KOBJ.loggers.annotate.trace("Extracting Local Data.............................");

            var annotateData = {};
            var phoneSelector = annotator.defaults.domains[this.domain_name].phoneSel;
            var urlSelector = annotator.defaults.domains[this.domain_name].urlSel;
            var phoneTemp = $KOBJ(toAnnotate).find(phoneSelector).text().replace(/[\u00B7() -]/g, "");
            var urlTemp = $KOBJ(toAnnotate).find(urlSelector).attr("href");

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

            KOBJ.loggers.annotate.trace("Extracted DAta ", annotateData);
            return annotateData;
        };


        function KOBJAnnotateLocalSearchResults(an_app, an_name, an_config, an_callback) {
            KOBJ.loggers.annotate.trace("Local Annotage Init ");

            this.defaults = {
                "wrapper_css" : {
                    "color": "#CCC",
                    "width": "auto",
                    "font-size": "12px",
                    "line-height": "normal",
                    "left-margin": "15px",
                    "right-padding": "15px",
                    "font-family": "Verdana, Geneva, sans-serif"
                },
                "placement" : 'append',
                "flush_domains":  true,
                "domains": {
                    "www.google.com":{
                        "selector":".ts .w0",
                        "watcher":"#rso",
                        "phoneSel":".nobr",
                        "urlSel":".l",
                        "modify":"",
                        "change_condition": KOBJAnnotateSearchResults.google_search_change_condition,
                        "extract_function": KOBJAnnotateLocalSearchResults.annotate_local_search_extractdata
                    },
                    "search.yahoo.com":{
                        "selector":".sc-loc",
                        "watcher": "",
                        "phoneSel":"[id *= lblPhone]",
                        "urlSel":".yschttl",
                        "modify":"",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateLocalSearchResults.annotate_local_search_extractdata
                    },
                    "www.bing.com":{
                        "selector":".sc_ol1li",
                        "watcher": "",
                        "phoneSel":".sc_hl1 li>:not(a)",
                        "urlSel":"li>a:contains('Website')",
                        "modify":"",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateLocalSearchResults.annotate_local_search_extractdata

                    },
                    "www.ask.com": {
                        selector : ".answers_ui_content td td td:nth-child(2) div",
                        "watcher":"",
                        "phoneSel":"span.txt3",
                        "urlSel":"a.title:odd",
                        "modify":"",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateLocalSearchResults.annotate_local_search_extractdata
                    },
                    "maps.google.com":{
                        "selector":".one",
                        "watcher":".res",
                        "phoneSel":".tel",
                        "urlSel":".fn.org",
                        "modify":"",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateLocalSearchResults.annotate_local_search_extractdata

                    },
                    "local.yahoo.com":{
                        "selector":".yls-rs-bizinfo",
                        "watcher":"",
                        "phoneSel":".tel",
                        "urlSel":".yls-rs-listing-title",
                        "modify":"",
                        "change_condition": KOBJAnnotateSearchResults.true_change_condition,
                        "extract_function": KOBJAnnotateLocalSearchResults.annotate_local_search_extractdata
                    }
                }
            };


            // Lets merge our defaults  and with what comes in the config
            if (typeof an_config === 'object') {
                $KOBJ.extend(true, this.defaults, an_config);
            }

            this.base_ann = new KOBJAnnotateSearchResults(an_app, an_name, this.defaults, an_callback)
            KOBJ.loggers.annotate.trace("Local Init Complete ");

        }

        ;

        KOBJAnnotateLocalSearchResults.prototype.annotate = function() {
            KOBJ.loggers.annotate.trace("Local Ann annotate ");

            this.base_ann.annotate();
        };

        window.KOBJAnnotateSearchResults = KOBJAnnotateSearchResults;
        window.KOBJAnnotateLocalSearchResults = KOBJAnnotateLocalSearchResults;
    })();
}
