// This file is part of the Kinetic Rules Engine (KRE).
// Copyright (C) 2007-2011 Kynetx, Inc.
// Licensed under: GNU Public License version 2 or later

KOBJ.a41x88 = KOBJ.a41x88 || {};

(function ($) {
    $.format = (function () {

		var parseMonth = function(value){

    		switch(value){
    		case "Jan":
    			return "01";
        		break;
    		case "Feb":
    			return "02";
        		break;
    		case "Mar":
    			return "03";
        		break;
    		case "Apr":
    			return "04";
        		break;
    		case "May":
    			return "05";
        		break;
    		case "Jun":
    			return "06";
        		break;
    		case "Jul":
    			return "07";
        		break;
    		case "Aug":
    			return "08";
        		break;
    		case "Sep":
    			return "09";
        		break;
    		case "Oct":
    			return "10";
        		break;
    		case "Nov":
    			return "11";
        		break;
    		case "Dec":
    			return "12";
        		break;
			default:
				return value;
			}
		};

		var parseTime = function(value){
			var retValue = value;
			if(retValue.indexOf(".") != -1){
				retValue =  retValue.substring(0, retValue.indexOf("."));
			}

    		var values3 = retValue.split(":");

    		if(values3.length == 3){
	    		hour		= values3[0];
	    		minute		= values3[1];
	    		second		= values3[2];

				return {
						time: retValue,
						hour: hour,
						minute: minute,
						second: second
				};
    		} else {
				return {
					time: "",
					hour: "",
					minute: "",
					second: ""
			};
    		}
		};

        return {
            date: function(value, format){
            	//value = new java.util.Date()
        		//2009-12-18 10:54:50.546
            	try{
            		var values = value.split(" ");
            		var year 		= null;
            		var month 		= null;
            		var dayOfMonth 	= null;
            		var time 		= null; //json, time, hour, minute, second

            		switch(values.length){
            		case 6://Wed Jan 13 10:43:41 CET 2010
            			year 		= values[5];
	            		month 		= parseMonth(values[1]);
	            		dayOfMonth 	= values[2];
	            		time		= parseTime(values[3]);
            			break;
            		case 2://2009-12-18 10:54:50.546
            			var values2 = values[0].split("-");
            			year 		= values2[0];
            			month 		= values2[1];
	            		dayOfMonth 	= values2[2];
	            		time 		= parseTime(values[1]);
            			break;
            		default:
            			return value;
            		}


            		var pattern 	= "";
            		var retValue 	= "";

            		for(i = 0; i < format.length; i++){
            			var currentPattern = format.charAt(i);
            			pattern += currentPattern;
            			switch(pattern){
                		case "dd":
                			retValue += dayOfMonth;
                			pattern   = "";
    	            		break;
				case "mM":
					retValue += month.replace(/0/,"");
					patern = "";
				break;
                		case "MM":
                			retValue += month;
                			pattern   = "";
    	            		break;
                		case "yyyy":
                			retValue += year;
                			pattern   = "";
    	            		break;
                		case "HH":
                			retValue += time.hour;
                			pattern   = "";
    	            		break;
                		case "hh":
                			retValue += time.hour;
                			pattern   = "";
    	            		break;
                		case "mm":
                			retValue += time.minute;
                			pattern   = "";
    	            		break;
                		case "ss":
                			retValue += time.second;
                			pattern   = "";
    	            		break;
                		case " ":
                			retValue += currentPattern;
                			pattern   = "";
    	            		break;
                		case "/":
                			retValue += currentPattern;
                			pattern   = "";
    	            		break;
                		case ":":
                			retValue += currentPattern;
                			pattern   = "";
    	            		break;
            			default:
            				if(pattern.length == 2 && pattern.indexOf("y") != 0){
            					retValue += pattern.substring(0, 1);
            					pattern = pattern.substring(1, 2);
            				} else if((pattern.length == 3 && pattern.indexOf("yyy") == -1)){
            					pattern   = "";
            				}
            			}
                    }
            		return retValue;
            	} catch(e) {
                	return value;
            	}
        	}
        };
    })();
}($KOBJ));


(function ($) {
    $.format = (function () {

		var parseMonth = function(value){

    		switch(value){
    		case "Jan":
    			return "01";
        		break;
    		case "Feb":
    			return "02";
        		break;
    		case "Mar":
    			return "03";
        		break;
    		case "Apr":
    			return "04";
        		break;
    		case "May":
    			return "05";
        		break;
    		case "Jun":
    			return "06";
        		break;
    		case "Jul":
    			return "07";
        		break;
    		case "Aug":
    			return "08";
        		break;
    		case "Sep":
    			return "09";
        		break;
    		case "Oct":
    			return "10";
        		break;
    		case "Nov":
    			return "11";
        		break;
    		case "Dec":
    			return "12";
        		break;
			default:
				return value;
			}
		};

		var parseTime = function(value){
			var retValue = value;
			if(retValue.indexOf(".") != -1){
				retValue =  retValue.substring(0, retValue.indexOf("."));
			}

    		var values3 = retValue.split(":");

    		if(values3.length == 3){
	    		hour		= values3[0];
	    		minute		= values3[1];
	    		second		= values3[2];

				return {
						time: retValue,
						hour: hour,
						minute: minute,
						second: second
				};
    		} else {
				return {
					time: "",
					hour: "",
					minute: "",
					second: ""
			};
    		}
		};

        return {
            date: function(value, format){
            	//value = new java.util.Date()
        		//2009-12-18 10:54:50.546
            	try{
            		var values = value.split(" ");
            		var year 		= null;
            		var month 		= null;
            		var dayOfMonth 	= null;
            		var time 		= null; //json, time, hour, minute, second

            		switch(values.length){
            		case 6://Wed Jan 13 10:43:41 CET 2010
            			year 		= values[5];
	            		month 		= parseMonth(values[1]);
	            		dayOfMonth 	= values[2];
	            		time		= parseTime(values[3]);
            			break;
            		case 2://2009-12-18 10:54:50.546
            			var values2 = values[0].split("-");
            			year 		= values2[0];
            			month 		= values2[1];
	            		dayOfMonth 	= values2[2];
	            		time 		= parseTime(values[1]);
            			break;
            		default:
            			return value;
            		}


            		var pattern 	= "";
            		var retValue 	= "";

            		for(i = 0; i < format.length; i++){
            			var currentPattern = format.charAt(i);
            			pattern += currentPattern;
            			switch(pattern){
                		case "dd":
                			retValue += dayOfMonth;
                			pattern   = "";
    	            		break;
				case "mM":
					retValue += month.replace(/0/,"");
					patern = "";
				break;
                		case "MM":
                			retValue += month;
                			pattern   = "";
    	            		break;
                		case "yyyy":
                			retValue += year;
                			pattern   = "";
    	            		break;
                		case "HH":
                			retValue += time.hour;
                			pattern   = "";
    	            		break;
                		case "hh":
                			retValue += time.hour;
                			pattern   = "";
    	            		break;
                		case "mm":
                			retValue += time.minute;
                			pattern   = "";
    	            		break;
                		case "ss":
                			retValue += time.second;
                			pattern   = "";
    	            		break;
                		case " ":
                			retValue += currentPattern;
                			pattern   = "";
    	            		break;
                		case "/":
                			retValue += currentPattern;
                			pattern   = "";
    	            		break;
                		case ":":
                			retValue += currentPattern;
                			pattern   = "";
    	            		break;
            			default:
            				if(pattern.length == 2 && pattern.indexOf("y") != 0){
            					retValue += pattern.substring(0, 1);
            					pattern = pattern.substring(1, 2);
            				} else if((pattern.length == 3 && pattern.indexOf("yyy") == -1)){
            					pattern   = "";
            				}
            			}
                    }
            		return retValue;
            	} catch(e) {
                	return value;
            	}
        	}
        };
    })();
}($KOBJ));


// No more date library.

KOBJ.a41x88.forms = KOBJ.a41x88.forms || [];

KOBJ.stateMap = {

"ALABAMA":"AL",

"ALASKA":"AK",

"AMERICAN SAMOA":"AS",

"ARIZONA":"AZ",

"ARKANSAS":"AR",

"CALIFORNIA":"CA",

"COLORADO":"CO",

"CONNECTICUT":"CT",

"DELAWARE":"DE",

"DISTRICT OF COLUMBIA":"DC",

"FEDERATED STATES OF MICRONESIA":"FM",

"FLORIDA":"FL",

"GEORGIA":"GA",

"GUAM":"GU",

"HAWAII":"HI",

"IDAHO":"ID",

"ILLINOIS":"IL",

"INDIANA":"IN",

"IOWA":"IA",

"KANSAS":"KS",

"KENTUCKY":"KY",

"LOUISIANA":"LA",

"MAINE":"ME",

"MARSHALL ISLANDS":"MH",

"MARYLAND":"MD",

"MASSACHUSETTS":"MA",

"MICHIGAN":"MI",

"MINNESOTA":"MN",

"MISSISSIPPI":"MS",

"MISSOURI":"MO",

"MONTANA":"MT",

"NEBRASKA":"NE",

"NEVADA":"NV",

"NEW HAMPSHIRE":"NH",

"NEW JERSEY":"NJ",

"NEW MEXICO":"NM",

"NEW YORK":"NY",

"NORTH CAROLINA":"NC",

"NORTH DAKOTA":"ND",

"NORTHERN MARIANA ISLANDS":"MP",

"OHIO":"OH",

"OKLAHOMA":"OK",

"OREGON":"OR",

"PALAU":"PW",

"PENNSYLVANIA":"PA",

"PUERTO RICO":"PR",

"RHODE ISLAND":"RI",

"SOUTH CAROLINA":"SC",

"SOUTH DAKOTA":"SD",

"TENNESSEE":"TN",

"TEXAS":"TX",

"UTAH":"UT",

"VERMONT":"VT",

"VIRGIN ISLANDS":"VI",

"VIRGINIA":"VA",

"WASHINGTON":"WA",

"WEST VIRGINIA":"WV",

"WISCONSIN":"WI",

"WYOMING":"WY"

};

KOBJ.countryCodes = {

"USA":{"Long":"United States of America", "Short":"United States", "CC":"US", "CCC":"USA","cc":"us","ccc":"usa"}

};

KOBJ.creditCards = {

"Visa": { "CT":"VI", "CCType":"Visa","CCTYPE":"VISA", "VS":"VS"},
"American Express": { "CT":"AX", "CCType":"American Express","CCTYPE":"AMERICAN EXPRESS", "VS":"AE"},
"MasterCard": { "CT":"MC", "CCType":"MasterCard","CCTYPE":"MASTERCARD", "VS":"MC"},
"Discover": { "CT":"DI", "CCType":"Discover","CCTYPE":"DISCOVER","VS":"DC"}

};

KOBJ.StateToST = function(val){
	var lookedUp = KOBJ.stateMap[val.toUpperCase()];
	if(lookedUp){
		return lookedUp;
	}
	return "";
};

KOBJ.countryCodeToCountry = function(val,format){
	var lookedUp = KOBJ.countryCodes[val][format];

	if(lookedUp){
		return lookedUp;
	}
	return "";
};

KOBJ.creditCardFormatter = function(value, format){
	var lookedUp = KOBJ.creditCards[value][format];

	if(lookedUp){
		return lookedUp;
	}
	return "";
};

KOBJ.setFormMaps = function(mapToPush){
	KOBJ.a41x88 = KOBJ.a41x88 || {};
	KOBJ.a41x88.forms = KOBJ.a41x88.forms || [];
	KOBJ.a41x88.forms.push(mapToPush);
};

KOBJ.fillFormsDefault = {
	"fillCSS": {},
	"highlight-color":"#FFFFCC",
	"cburl":"http://198.160.96.218:9070/monitor/MonitorFilter?"
};

KOBJ.formatData = function(formatpassed,valuepassed){
	var valToBe, tempVal;
	switch(formatpassed){
		case "area":
			valToBe = valuepassed.slice(0,3);
		break;


		case "first-3":
			valToBe = valuepassed.slice(3,6);
		break;


		case "last-4":
			valToBe = valuepassed.slice(6,10);
		break;


		case "last-7":
			valToBe = valuepassed.slice(3,10);
		break;


		case "all":
			valToBe = valuepassed;
		break;


		case "ST":
			valToBe = KOBJ.StateToST(valuepassed);
		break;


		case "State":
			valToBe = valuepassed;
		break;


		case "ST - State":
			valToBe = KOBJ.StateToST(valuepassed) + ' - ' + valuepassed;
		break;


		case "STATE":
			valToBe = valuepassed.toUpperCase();
		break;


		case "Long":
			valToBe = KOBJ.countryCodeToCountry(valuepassed,formatpassed);
		break;


		case "Short":
			valToBe = KOBJ.countryCodeToCountry(valuepassed,formatpassed);
		break;


		case "CC":
			valToBe = KOBJ.countryCodeToCountry(valuepassed,formatpassed);
		break;


		case "CCC":
			valToBe = KOBJ.countryCodeToCountry(valuepassed,formatpassed);
		break;

		case "cc":
			valToBe = KOBJ.countryCodeToCountry(valuepassed,formatpassed);
		break;

		case "ccc":
			valToBe = KOBJ.countryCodeToCountry(valuepassed,formatpassed);
		break;

		case "CCType":
			valToBe = KOBJ.creditCardFormatter(valuepassed,formatpassed);
		break;


		case "CCTYPE":
			valToBe = KOBJ.creditCardFormatter(valuepassed,formatpassed);
		break;

		case "CT":
			valToBe = KOBJ.creditCardFormatter(valuepassed,formatpassed);
		break;

		case "VS":
			valToBe = KOBJ.creditCardFormatter(valuepassed,formatpassed);
		break;

		case "yy":
			valToBe = $KOBJ.format.date(valuepassed,"yyyy").slice(2,4);
		break;

		case "y,yyy":
			tempVal = $KOBJ.format.date(valuepassed,"yyyy");
			valToBe = tempVal.slice(0,1) + ',' + tempVal.slice(1);
		break;

		case "mM":
			tempVal = $KOBJ.format.date(valuepassed,"MM");
			if(tempVal[0] == 0){
				valToBe = tempVal[1];
			} else {
				valToBe = tempVal;
			}
		break;

		default:
			valToBe = $KOBJ.format.date(valuepassed,formatpassed);
		break;
	}

	if(valToBe){
		return valToBe;
	}
	return false;
};

KOBJ.fillForms = function(formData, configuration){

	var defaults = $KOBJ.extend(true, {}, KOBJ.fillFormsDefault);

	if(typeof(configuration) === "object"){
		$KOBJ.extend(true, defaults, configuration);
	}

	if(defaults["highlight-color"]){
		defaults.fillCSS["background-color"] = defaults["highlight-color"];
	}

	var maxLengthURL = KOBJ.maxURLLength;
	var formMap = KOBJ.a41x88.forms[KOBJ.a41x88.forms.length - 1];
	var stateArray = [];
	var errorState, anyError = false;
	var successes = 0;
	var errors = 0;

	//KynetxFormDebug("Map: " + $KOBJ.compactJSON(formMap) + "\nForm Data: " + $KOBJ.compactJSON(formData));

	$KOBJ.each(formMap,function (index, thismap) {
		try{

			//KynetxFormDebug("Trying to fill for object: " + $KOBJ.compactJSON(thismap));

			errorState = false;
			var selector = thismap.selector;
			var iframe = thismap.iframe;
			var mapTo = thismap.map;
			var format = thismap.format;
			var mapArray = mapTo.split(".");

			var value = formData[mapArray[0]][mapArray[1]];

			var element;
			if(iframe){
				KynetxFormDebug("Looking withing iframe" + iframe + " for selector " + selector);
				element = $KOBJ(iframe).contents().find(selector);
			} else {
				element = $KOBJ(selector);
			}

			if(value){
				if(element.length){
					if(format){
						KynetxFormDebug("format: "+ format + "\nvalue: " + value);
						value = KOBJ.formatData(format,value);
					}

										if(value){
						element.val(value).css(defaults.fillCSS);
						if(defaults.nukeLables){
							$KOBJ("[for="+selector.replace(/#|\.|\[name=|\]/g,"")+"]").remove();
						}
					} else {
						throw "value formatting was bad";
					}

					if(element.val() != value || element.text() != value){
						if(element[0].tagName === "SELECT"){
							$KOBJ.each(element.children(),function(){
								var select = $KOBJ(this);
								var selectVal = select.val();
								var text = select.text();

                                                                var regex = new RegExp(value,"ig");

								if(text.search(regex) > -1 || selectVal.search(regex) > -1){
									select.attr("selected","selected");
								}
							});
						}
					}
					if(element.val() != value || element.text() != value){
					} else {
						KynetxFormDebug("Expected " + value + " got " + element.val());
						throw "form didn't fill as expected";
					}
				} else {
					throw "selector blank";
				}
			} else {
				throw "no data";
			}
		} catch(error) {
			errorState = true;
			KynetxFormDebug("Error: ",error);
			if(error == "no data"){
				KynetxFormDebug("No data for " + thismap.map);
			} else {
				anyError = true;
				errors++;
				stateArray.push({"error":error, "selector": selector, "map": mapTo});
			}
		}

		if(!errorState){
			KynetxFormDebug("Success for " + thismap.map);
			successes++;
			stateArray.push({"error":"none", "selector": selector, "map": mapTo});
		}
	});



	KynetxFillResult({'success':successes, 'failure':errors});
	var status = 'none';

	if(successes == formMap.length){
		status = 'full';
	} else if(successes > 0){
		status = 'partial';
	} else if(successes === 0 && formMap.length !== 0){
		status = 'fail';
	} else if(formMap.length === 0){
		status = 'none';
	}

	var problemData = '';

	$KOBJ.each(stateArray, function(index,data){
		if(index != 0){
			problemData += ",";
		}

		if(data.error != "none" || data.error != "no data"){
			problemData += data.map;
		}
	});

    if(anyError && defaults.logurl){
		$K.getJSON(defaults.logurl + "callback=?&map=amazon&errors="+problemData,function(){});
	}

	KOBJ.logger('form_fill', defaults['txn_id'], problemData, '', status, defaults['rule_name'], defaults['rid']);

	var annotateArray = KOBJ.splitJSONRequest(stateArray,maxLengthURL,'');

	$KOBJ.each(annotateArray,function(key,data){
		annotateString = $KOBJ.compactJSON(data);
		//Logging callback goes here!
	});
};
