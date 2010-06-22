KOBJ.search_percolate = {};

KOBJ.search_percolate.defaults = {};
KOBJ.search_percolate.ajax = false;

KOBJ.search_percolate.defaults = {
	"name":"KOBJ",
	"sep":"<div></div>",
	"text_color":"#CCC",
	"height":"100px",
	"font_size":"12px",
	"class":"KOBJ_item",
	"font_family": "Verdana, Geneva, sans-serif",

	"title":"Percolation Results",
	"site": {
		"www.google.com": {

			"parem": "start",
			"mainSelector": "#ires ol",
			"backupSelector": "#mbEnd",
			"resultNumParem": "num=90",
			"resultElement": "li.g, div.g",
			"classes":"",
			"actionMain":"before",
			"actionBackup":"after",
			"watcher":"#rso",
			"urlSel":".l",
			"seperator_css":{},
			"div_css":{
//				"padding-bottom": "3px",
//				"padding-left": "16px",
//				"padding-right": "5px",
//				"max-width": "48em",
//				"min-height": "30px"
			},
	
			"ol_css": {
				"display": "block",
				"padding-top":"0px",
				"list-style":"none",
				"padding-left":"0px"
			}

		},
		
		"www.bing.com": {
			"parem": "first",
			"mainSelector":"#result ul:first",
			"backupSelector":".sb_ph",
			"resultNumParem": "count=100",
			"resultElement":"#results>ul>li",
			"actionMain":"prepend",
			"classes":"sa_cc",
			"actionBackup":"before",
			"watcher": "",
			"urlSel":".nc_tc a, .sb_tlst a",
			"seperator_css":{},
			"div_css":{

			},
		
			"ol_css": {
				"display": "block",
				"padding-top":"18px",
				"list-style":"none",
				"padding-left":"0px"
			}
		},

		"search.yahoo.com": {
			"parem": "b",
			"mainSelector":"#web ol:first",
			"backupSelector":"#main",
			"resultNumParem": "n=100",
			"resultElement":"#web ol>li",
			"actionMain":"prepend",
			"actionBackup":"prepend",
			"watcher": "",
			"classes":"",
			"urlSel":".yschttl",
			"seperator_css":{},
			"div_css":{
				"padding-bottom": "0px",
				"padding-left": "0px",
				"padding-right": "5px",
				"max-width": "48em",
				"min-height": "75px"
			},
		
			"ol_css": {
				"display": "block",
				"padding-top":"0px",
				"list-style":"none",
				"padding-left":"0px"
			}
		}
	}
};

KOBJ.search_percolate.extractdata = function(toPercolate,config){

	var percolateData = {};
	var urlSelector = config.site[window.location.host].urlSel;
	var urlTemp = $KOBJ(toPercolate).find(urlSelector).attr("href");

	if(!urlTemp){
		urlTemp = $KOBJ(toPercolate).find(".url, cite").attr("href");
		// Failsafe
	}

	if(window.location.host == "search.yahoo.com"){
		urlTemp = urlTemp.replace(/.*\*\*/,"");
		urlTemp = urlTemp.replace(/%3a/,":");
	}

	if(urlTemp){
		percolateData["url"] = urlTemp;
		percolateData["domain"] = KOBJ.get_host(urlTemp);
	} else {
		percolateData["url"] = "";
		percolateData["domain"] = "";
	}
	return percolateData;
};

KOBJ.percolate = function(selector, config) {

	try{

		var defaults = $KOBJ.extend(true, {}, KOBJ.search_percolate.defaults);
		
		if (typeof config === 'object') {
			$KOBJ.extend(true, defaults, config);
		}
		var site_defaults = defaults.site[window.location.host];
	
		function percolate_search_results(selector,config){
		
			var defaults = $KOBJ.extend(true, {}, KOBJ.search_percolate.defaults);
		
			if (typeof config === 'object') {
				$KOBJ.extend(true, defaults, config);
			}
	
			if(KOBJ.search_percolate.ajax){
				$KOBJ("." + defaults.name + "_percolate").remove();
				KOBJ.search_percolate.ajax = false;
			}
	
			site_defaults = defaults.site[window.location.host];
	
			function move_item (obj) {
                var append_to = null;
                if($KOBJ(".KOBJ_Moved").length != 0)
                {
                  $KOBJ(".KOBJ_Moved:last").after($KOBJ(obj));
                  // We have to set the class here.  If we set it before the $KOBJ(".KOBJ_Moved:last"). will find us not
                  // the last moved element.
                  $KOBJ(obj).addClass("KOBJ_Moved");
                }
                else
                {
                    $KOBJ(obj).addClass("KOBJ_Moved");
                    $KOBJ(site_defaults.mainSelector).prepend($KOBJ(obj));
                }
			}
	
			function serpslurp(){
				//returns the URL for the next batch of results
				var cloc = document.location.toString();
				if(cloc.search(/#/) && KOBJ.document.location.host == "www.google.com"){
					cloc = cloc.replace(/http:\/\/www.google.com\/(.*?)#/,"http://www.google.com/search?").replace(/&aq.*?&/,"&").replace(/&aqo.*?&/,"&").replace(/&aql.*?&/,"&").replace(/fp.*?/,"&").replace(/&oq.*?&/,"&").replace(/&aqi.*?&/,"&");
				}
	
				var nextParem = site_defaults.parem;
				
				var regExp = new RegExp("("+nextParem+")=(\\d+)"); 		
		
				var m;
				var start = 0;
				try { m = cloc.match(regExp);
					start = parseInt(m[2]);
				    } catch(err) {}
				var next = (start+10).toString();
				if(m) {
				    cloc = cloc.replace(regExp, nextParem + "=" + next);
				} else {
				    cloc = cloc + "&" + nextParem + "=" + next;
				}
				try {
					m = cloc.match(regExp);
					start = parseInt(m[2]);
				} catch(err) {
	
				}
				next = (start+10).toString();
				if(m) {
				    cloc = cloc.replace(regExp, nextParem + "=" +  next);
				} else {
				    cloc = cloc + "&" + nextParem + "=" + next;
				}
				cloc += "&"+site_defaults.resultNumParem;
				return cloc;
			}
		
			//percolate this page
			$KOBJ(site_defaults.resultElement).each(function() {
			    var data = this;


                // In the case of google the local result are mixed with the normal results
                // so we check if the thing we are looking at has a class localbox and ignore it
                // so that it does not move.
                if($KOBJ(data).hasClass("KOBJ_Moved") || $KOBJ(data).hasClass("localbox"))
                    return;

				var extractedData = KOBJ.search_percolate.extractdata(data,defaults);
				$KOBJ.each(extractedData, function(name, value){
					$KOBJ(data).data(name, value);
				});
				if (selector(data)) {
					move_item(data);
				}
			});
		
			//percolate deep results
            var next_search_result = KOBJ.ajax(serpslurp(),false);
//			$KOBJ.get(serpslurp(), function(res) {
				$KOBJ(site_defaults.resultElement, next_search_result).each(function() {
					var data = this;
                    if($KOBJ(data).hasClass("KOBJ_Moved") || $KOBJ(data).hasClass("localbox"))
                        return true;
					var extractedData = KOBJ.search_percolate.extractdata(data,defaults);
					$KOBJ.each(extractedData, function(name, value){
						$KOBJ(data).data(name, value);
					});
					if (selector(data)) {
						move_item(data);
					}
				});
//			});
		}
	
		percolate_search_results(selector,config);
		
		var watcher = defaults.site[window.location.host].watcher;
		
		if(watcher){
			KOBJ.watchDOM(watcher,function(){KOBJ.search_percolate.ajax = true; percolate_search_results(selector,config);});
		}
	} catch(error) {
		KOBJ.log("Percolation error: ");
		KOBJ.log(error.message);
	}

};



