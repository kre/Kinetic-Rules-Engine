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
//used for overriding the document for UI actions
KOBJ.document = document;

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

KOBJ.css=function(css){
   var head=KOBJ.document.getElementsByTagName('head')[0],
       style=KOBJ.document.createElement('style'),
       rules=KOBJ.document.createTextNode(css);
   style.type='text/css';
   style.id='KOBJ_stylesheet';
   KOBJstyle=KOBJ.document.getElementById('KOBJ_stylesheet');
   if(KOBJstyle==null){
       if(style.styleSheet){
           style.styleSheet.cssText=rules.nodeValue;
       }else{
           style.appendChild(rules);
       }
   head.appendChild(style);
   }else{
       if(KOBJstyle.styleSheet){
           KOBJstyle.styleSheet.cssText+=rules.nodeValue;
       }else{
           KOBJstyle.appendChild(rules);
       }
   }
};
