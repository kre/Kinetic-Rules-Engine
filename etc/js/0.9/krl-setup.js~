;

var $K = jQuery.noConflict();


var KOBJ= KOBJ ||
  { name: "KRL Runtime Library",
    version: '0.9',
    copyright: "Copyright 2007-2009, Kynetx Inc.  All Rights reserved."
  };

KOBJ._log = new Array();
KOBJ.log = function(msg){
	KOBJ._log.push({'ts':new Date(),'msg':msg});
	if(window.console != undefined && console.log != undefined){ console.log(msg); }
};

KOBJ.logger = function(type,txn_id,element,url,sense,rule,rid) {
//     e=document.createElement("script");
//     e.src=KOBJ.callback_url+"?type="+type+"&txn_id="+txn_id+"&element="+element+"&sense="+sense+"&url="+escape(url)+"&rule="+rule;
//     if(rid) e.src+="&rid="+rid;
//     body=document.getElementsByTagName("body")[0];
//     body.appendChild(e);
  var url=KOBJ.callback_url+"?type="+type+"&txn_id="+txn_id+"&element="+element+"&sense="+sense+"&url="+escape(url)+"&rule="+rule;
  if(rid) url+="&rid="+rid;
  KOBJ.require(url);
};
