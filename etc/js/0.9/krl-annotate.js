KOBJ.maxURLLength = 1800;

KOBJ.splitJSONRequest = function(json,maxLength,url){

		jsonString = $K.compactJSON(json);
		var numOfRequests = Math.ceil((jsonString.length + url.length) / maxLength);
		KOBJ.log("The number of requests to be made is: " + numOfRequests);
		if( numOfRequests > 1){
			KOBJ.log("The length of the annotation request would be too large. Splitting into "+ numOfRequests+ " requests.");
			var toReturn = [];
                        var count = 1;
			$K.each(json, function(index){
				object = this;
                                number = count++ % (numOfRequests);
                                toReturn[number] = toReturn[number] || {};
                                toReturn[number][index] = object;
		        });
			return toReturn;
		} else {
			return [json];
		}
};

KOBJ.watchDOM = function(selector,callBackFunc,time){
	if(!KOBJ.watcherRunning){
			KOBJ.log("Starting the DOM Watcher");
			var KOBJ_setInterval = 0;
			if(!typeof(setInterval_native) == "undefined"){
				KOBJ_setInterval = setInterval_native;
			} else {
				KOBJ_setInterval = setInterval;
			}
			if(KOBJ.watcherRunning){clearInterval(KOBJ.watcherRunning);}
                        KOBJ.watcherData = [];
                        KOBJ.watcherData.push({"selector": selector,"callBacks": [callBackFunc]});
			KOBJ.log("DOM Watcher Callback for new selector " +selector+ " added");
			$K(selector+" :child:first").addClass("KOBJ_AjaxWatcher");
			KOBJ.watcher = function(){
				$K(KOBJ.watcherData).each(function(){
					var data = this;
					var selectorExists = $K(selector).length;
					if(!selectorExists){return;}
					var hasNotChanged = $K(data.selector+" :child:first").is(".KOBJ_AjaxWatcher");
					if(!hasNotChanged){
						$K(data.callBacks).each(function(){
							callBack = this;
							KOBJ.log("Running call back on selector " + selector);
							callBack();
						});
						$K(data.selector+" :child:first").addClass("KOBJ_AjaxWatcher");
					}
				});
			};
			KOBJ.watcherRunning = KOBJ_setInterval(KOBJ.watcher,time||1000);
	} else {
		$K(KOBJ.watcherData).each(function(){
			dataObj = this;
			if(dataObj.selector == selector){
				dataObj.callBacks.push(callBackFunc);
				$K(selector+" :child:first").addClass("KOBJ_AjaxWatcher");
				KOBJ.log("DOM Watcher Callback for previous selector " +selector+ " added");
				return false;
			} else {
				KOBJ.watcherData.push({"selector": selector,"callBacks": [callBackFunc]});
				$K(selector+" :child:first").addClass("KOBJ_AjaxWatcher");
				KOBJ.log("DOM Watcher Call for new selector "+selector+" added");
			}
		});
	}	
};

// Start of annotate local changes, v1.2


// KOBJ.annotate_local_search_extractdata pulls the data out automatically, such as phone and domain.

KOBJ.annotate_local_search_extractdata = function(toAnnotate,config){
	
	var annotateData = {};
	var phoneSelector = config.domains[window.location.host].phoneSel;
	var urlSelector = config.domains[window.location.host].phoneSel;
	var phoneTemp = $K(toAnnotate).find(phoneSelector).text().replace(/[\u00B7() -]/g, "");
	var urlTemp = $K(toAnnotate).find(urlSelector).attr("href");
	// ".l" is for Google, ".nc_tc, .sb_tlst" are for Bing, .yschttl is for Yahoo
	
	if(!urlTemp){
		urlTemp = $K(toAnnotate).find(".url, cite").text();
		if(!urlTemp){
			urlTemp = $K(toAnnotate).find("li:eq(1) a").attr("href");
		}
		// Failsafe
	}
	if(urlTemp){
		annotateData["url"] = urlTemp;
		domainTemp = KOBJ.get_host(urlTemp);
		annotateData["domain"] = domainTemp;
	} else {
		annotateData["url"] = "";
		annotateData["domain"] = "";
	}
	if(phoneTemp===""){
		phoneTemp = $K(toAnnotate);
		phoneTemp = phoneTemp.text().match(/\(\d{3}\)\s\d{3}-\d{4}/,"$1");
		if(phoneTemp!==null){
			phoneTemp = phoneTemp[0];
			phoneTemp = phoneTemp.replace(/[() -]/g, "");
		}
	}


	var heightTemp = $K(toAnnotate).height();
	
	if(phoneTemp!==null){
		annotateData["phone"] = phoneTemp;
	} else { annotateData["phone"] = ""; }
	annotateData["height"] = heightTemp;
	return annotateData;
};

// Defaults for both with and without remote.
// The "domains" element provides selector on a site by site basis

KOBJ.annotate_local_search_defaults = {
	"name": "KOBJL",
	"domains":{
		"www.google.com":{"selector":".g>.ts>tbody>tr>td:has(cite):not(:has(table)):not(:has(div)),#results td:last-child:has(h4):not(:has(table)):has(cite),.g table.ts tr td:last:not(:has(img)):has(cite),.g>table tbody tr td:has(h3):has(cite),.g>table tbody tr td table tr:has(.fl):has(cite)","watcher":"#rso","phoneSel":".nobr","urlSel":".l"},
		"search.yahoo.com":{"selector":".res.sc-ng.sc-lc-bz-m div.content>ol>li,#yls-rs-res tbody tr .yls-rs-bizinfo,.vcard","watcher": "","phoneSel":"[id *= lblPhone]","urlSel":".yschttl"},
		"www.bing.com":{"selector":".sc_ol1li, #srs_orderedList>.llsResultItem","watcher": "","phoneSel":".sc_hl1 li>:not(a)","urlSel":".nc_tc a, .sb_tlst a"},
		"maps.google.com":{"selector":"#resultspanel .res div.one:visible","watcher":"#spsizer .opanel:visible","phoneSel":".tel","urlSel":".fn.org"},
		"local.yahoo.com":{"selector":"#yls-rs-res tr.yls-rs-listinfo","watcher":"","phoneSel":".tel","urlSel":".yls-rs-listing-title"}

	}
};

// New Annotate Local function
// Includes DOM watching, seperating selector based on site, and some speed improvements

KOBJ.annotate_local_search_results = function(annotate, config, cb) {
	var defaults = jQuery.extend(true, {}, KOBJ.annotate_local_search_defaults);

	if (typeof config === 'object') {
		jQuery.extend(true, defaults, config);
	}
	//get domain's lister
	if(defaults["domains"][window.location.hostname]){
		// Gets selector for both the DOM watcher and to get element
		var lister = defaults["domains"][window.location.hostname]["selector"];
		var watcher = defaults["domains"][window.location.hostname]["watcher"];
	} else {
		return;
	}

	function runAnnotateLocal(){
		resultslist = $K(lister);
		if(resultslist.length===0){ return; }
		var count = 0;
		$K(resultslist).each(function() {

			var toAnnotate = this;
			
			var extractedData = KOBJ.annotate_local_search_extractdata(toAnnotate,defaults);
			// Inserts the data into the object.
			$K.each(extractedData, function(name, value){
				$K(toAnnotate).data(name, value);
			}); 

			var contents = annotate(toAnnotate);
			if (contents) {
				count++;
				$K(":last",this).after(contents);
			}
		});

		KOBJ.logger('annotated_search_results', config['txn_id'], count, '', 'success', config['rule_name'] );
		cb();
	}

	runAnnotateLocal();


	// Watcher is the element which is being watched, runAnnotateLocal is the function to be run
	if(watcher){
		KOBJ.watchDOM(watcher, runAnnotateLocal);
	}



};


// Remote local search function v1.0
// First iteration of remote local search. Includes changes to annotate local
// namely DOM watching, seperating selector based on site, and some speed improvements

KOBJ.annotate_local_search_results_withremote = function(remoteurl, config, cb) {
	var defaults = jQuery.extend(true, {}, KOBJ.annotate_local_search_defaults);
	var maxLengthURL = KOBJ.maxURLLength;
	if (typeof config === 'object') {
		jQuery.extend(true, defaults, config);
	}
	
	if(defaults["domains"][window.location.hostname]){
		// Gets selectors for both DOM watcher and the element
		var lister = defaults["domains"][window.location.hostname]["selector"];
		var watcher = defaults["domains"][window.location.hostname]["watcher"];
	} else {
		return;
	}

	KOBJ.annotate_local_counter = KOBJ.annotate_local_counter || 0;
	function runAnnotateLocal(){
		var count = 0;
		function annotateCBLocal(data){
	   		$K.each(data, function(key,contents){ 
	   			if(contents){
	    				$K("."+key+" :last").after(contents);
					count++;
				}
	    	        });
			cb();
		}

		var annotateInfo = {};
		$K(lister).each(function() {
			var toAnnotate = this;

			var itemCounter = defaults['name'] + (KOBJ.annotate_local_counter += 1);
			
			annotateInfo[itemCounter] = KOBJ.annotate_local_search_extractdata(toAnnotate,defaults);
			$K(toAnnotate).addClass(itemCounter);
		});
		
		var annotateArray = KOBJ.splitJSONRequest(annotateInfo,maxLengthURL,remoteurl);
		$K.each(annotateArray,function(key,data){
			annotateString = $K.compactJSON(data);
			$K.getJSON(remoteurl, {'annotatedata':annotateString},annotateCBLocal);
		});
			
		KOBJ.logger('annotated_search_results', config['txn_id'], count, '', 'success', config['rule_name'], config['rid'] );
	}
	runAnnotateLocal();

	// Watcher is the element which is being watched, runAnnotateLocal is the function to be run
	if(watcher){
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
	"www.google.com": { "selector": "li.g, div.g", "modify": "div.s", "watcher": "#rso", "urlSel":".l" },
	"www.bing.com": { "selector": "#results>ul>li", "modify": "p", "watcher": false,"urlSel":".nc_tc a, .sb_tlst a" },
	"search.yahoo.com": { "selector": "li div.res", "modify": "div.abstr", "watcher": false,"urlSel":".yschttl" },
	"unknown": { "selector": "#sw_main>.sr_dcard" }
    }
	
  };

KOBJ.annotate_search_defaults.outer_div_css = KOBJ.annotate_search_defaults.outer_div_css.outer_div_css || {
      "float": "right",
      "width": "auto",
      "height": KOBJ.annotate_search_defaults.height,
      "font-size": KOBJ.annotate_search_defaults.font_size,
      "line-height": "normal",
      "font-family": KOBJ.annotate_search_defaults.font_family
      };

KOBJ.annotate_search_defaults.li_css = KOBJ.annotate_search_defaults.outer_div_css.li_css || {
      "float": "left",
      "margin": "0",
      "vertical-align": "middle",
      "padding-left": "4px",
      "color": KOBJ.annotate_search_defaults.text_color,
      "white-space": "nowrap",
      "text-align": "center"
      };

KOBJ.annotate_search_defaults.ul_css = KOBJ.annotate_search_defaults.outer_div_css.ul_css || {
      "margin": "0",
      "padding": "0",
      "list-style": "none"
      };

KOBJ.annotate_search_defaults.inner_div_css = KOBJ.annotate_search_defaults.outer_div_css.inner_div_css || {
      "float": "left",
      "display": "inline",
      "height": KOBJ.annotate_search_defaults.height,
      "margin-left": KOBJ.annotate_search_defaults.left_margin,
      "padding-right": KOBJ.annotate_search_defaults.right_padding
      };


// Extracts the data from the element
KOBJ.annotate_search_extractdata = function(toAnnotate,config){

	var annotateData = {};
	var urlSelector = config.domains[window.location.host].urlSel;
	var urlTemp = $K(toAnnotate).find(urlSelector).attr("href");
	// ".l" is for Google, ".nc_tc, .sb_tlst" are for Bing, .yschttl is for Yahoo
	
	if(!urlTemp){
		urlTemp = $K(toAnnotate).find(".url, cite").attr(href);
		// Failsafe
	}
	if(urlTemp){
		annotateData["url"] = urlTemp;
		domainTemp = KOBJ.get_host(urlTemp);
		annotateData["domain"] = domainTemp;
	} else {
		annotateData["url"] = "";
		annotateData["domain"] = "";
	}
	return annotateData;
};

KOBJ.annotate_search_results = function(annotate, config, cb) {

	var defaults = jQuery.extend(true, {}, KOBJ.annotate_search_defaults);

	if (typeof config === 'object') {
		jQuery.extend(true, defaults, config);
	}

	var lister = "";
	var modify = "";
	var watcher = "";

	if (defaults["results_lister"]) {
		lister = defaults["results_lister"];
		watcher = "";
		modify = defaults["element_to_modify"];
	} else if (defaults["domains"][window.location.hostname]){
		// Gets selectors for both DOM watcher and the element
		lister = defaults["domains"][window.location.hostname]["selector"];
		watcher = defaults["domains"][window.location.hostname]["watcher"];
		modify = defaults["domains"][window.location.hostname]["modify"];
	} else {
		return;
	}

	function mk_list_item(i) {
		return $K("<li class='" + defaults.name + "_item'>").css(defaults.li_css).append(i);
	}

	function mk_outer_div(anchor) {
		var name = defaults.name;
		var logo_item = mk_list_item(anchor);
		var logo_list = $K('<ul>').css(defaults.ul_css).attr("id", name + "_anno_list").append(logo_item);
		var inner_div = $K('<div>').css(defaults.inner_div_css).append(logo_list);
		if (typeof defaults != 'undefined' && defaults['tail_image']) {
			inner_div.css({
				"background-image": "url(" + defaults['tail_image'] + ")",
				"background-repeat": "no-repeat",
				"background-position": "right top"
			});
		}
		var outer_div = $K('<div>').css(defaults.outer_div_css).append(inner_div);
		if (typeof defaults != 'undefined' && defaults['head_image']) {
			outer_div.css({
				"background-image": "url(" + defaults['head_image'] + ")",
				"background-repeat": "no-repeat",
				"background-position": "left top"
			});
		}
		return outer_div;
	}

	function runAnnotate(){
		var count = 0;

		var resultslist = $K(lister);
		if(resultslist.length === 0){ return; }

		resultslist.each(function() {

			var toAnnotate = this;			
			var extractedData = KOBJ.annotate_search_extractdata(toAnnotate,defaults);
			$K.each(extractedData, function(name, value){
				$K(toAnnotate).data(name, value);
			}); 
			var contents = annotate(toAnnotate);
			if (contents) {
				count++;
				if ($K(toAnnotate).find('#' + defaults.name + '_anno_list li').is('.' + defaults.name + '_item')) {
					$K(toAnnotate).find('#' + defaults.name + '_anno_list').append(mk_list_item(defaults.sep)).append(mk_list_item(contents));
				} else {
					$K(toAnnotate).find(modify)[defaults.placement](mk_outer_div(contents));
				}
			}
		});
		KOBJ.logger('annotated_search_results', config['txn_id'], count, '', 'success', config['rule_name'], config['rid'] );
		cb();
	}

	runAnnotate();

	// Watcher is the element which is being watched, runAnnotateLocal is the function to be run
	if(watcher){
		KOBJ.watchDOM(watcher, runAnnotate);
	}
};

// Annotate search with remote v1.0


KOBJ.annotate_search_results_withremote = function(remoteurl, config, cb) {

	var maxLengthURL = KOBJ.maxURLLength;
	
	var defaults = jQuery.extend(true, {}, KOBJ.annotate_search_defaults);

	if (typeof config === 'object') {
		jQuery.extend(true, defaults, config);
	}
	
	if(defaults["domains"][window.location.hostname]){
		// Gets selectors for both DOM watcher and the element
		var lister = defaults["domains"][window.location.hostname]["selector"];
		var watcher = defaults["domains"][window.location.hostname]["watcher"];
		var modify = defaults["domains"][window.location.hostname]["modify"];
	} else {
		return;
	}

	function mk_list_item(i) {
		return $K("<li class='" + defaults.name + "_item'>").css(defaults.li_css).append(i);
	}

	function mk_outer_div(anchor) {
		var name = defaults.name;
		var logo_item = mk_list_item(anchor);
		var logo_list = $K('<ul>').css(defaults.ul_css).attr("id", name + "_anno_list").append(logo_item);
		var inner_div = $K('<div>').css(defaults.inner_div_css).append(logo_list);
		if (typeof defaults != 'undefined' && defaults['tail_image']) {
			inner_div.css({
				"background-image": "url(" + defaults['tail_image'] + ")",
				"background-repeat": "no-repeat",
				"background-position": "right top"
			});
		}
		var outer_div = $K('<div>').css(defaults.outer_div_css).append(inner_div);
		if (typeof defaults != 'undefined' && defaults['head_image']) {
			outer_div.css({
				"background-image": "url(" + defaults['head_image'] + ")",
				"background-repeat": "no-repeat",
				"background-position": "left top"
			});
		}
		return outer_div;
	}

	KOBJ.annotate_search_counter = KOBJ.annotate_search_counter || 0;
	function runAnnotate(){

		var resultslist = $K(lister);
		if(resultslist.length === 0){ return; }
		var count = 0;
		var annotateInfo = {};
		resultslist.each(function() {
			var toAnnotate = this;
			var itemCounter = defaults['name'] + (KOBJ.annotate_search_counter += 1);
			
			annotateInfo[itemCounter] = KOBJ.annotate_search_extractdata(toAnnotate,defaults);
			$K(toAnnotate).addClass(itemCounter);
		});
		function annotateCB(data){
			$K.each(data, function(key,contents){
				if(contents){
					if ($K("."+key).find('#' + defaults.name + '_anno_list li').is('.' + defaults.name + '_item')) {
						$K("."+key).find('#' + defaults.name + '_anno_list').append(mk_list_item(defaults.sep)).append(mk_list_item(contents));
					} else {
						$K("."+key).find(modify)[defaults.placement](mk_outer_div(contents));
					}
				}				
				count++;
	        	});
		
			cb();
		}
		
		var annotateArray = KOBJ.splitJSONRequest(annotateInfo,maxLengthURL,remoteurl);
		$K.each(annotateArray,function(key,data){
			annotateString = $K.compactJSON(data);
			$K.getJSON(remoteurl, {'annotatedata':annotateString},annotateCB);
		});
			
		KOBJ.logger('annotated_search_results', config['txn_id'], count, '', 'success', config['rule_name'], config['rid'] );

	}

	runAnnotate();

	// Watcher is the element which is being watched, runAnnotateLocal is the function to be run
	if(watcher){
		KOBJ.watchDOM(watcher, runAnnotate);
	}
};




// End new annotate code

