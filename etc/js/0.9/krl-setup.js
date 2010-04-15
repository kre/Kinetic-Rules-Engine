;

window['$K'] = jQuery

window['KOBJ']= { name: "KRL Runtime Library",
    version: '0.9',
    copyright: "Copyright 2007-2009, Kynetx Inc.  All Rights reserved."
  };

/* TODO: Not used as far as I can tell CID 4/13 */  
KOBJ._log = new Array();

/* Logs data to the browsers windows console */
KOBJ.log = function(msg){
	/* TODO: Remove this as it is not used  not sure why it is here */
	KOBJ._log.push({'ts':new Date(),'msg':msg});
	if(window.console != undefined && console.log != undefined) { 
		console.log(msg); 
	}
};

KOBJ.errorstack_submit = function(key,e) {
  var txt="_s="+key+"&_r=img";
  txt+="&Msg="+escape(e.message ? e.message : e);
  txt+="&URL="+escape(e.fileName ? e.fileName : "");
  txt+="&Line="+ (e.lineNumber ? e.lineNumber : 0);
  txt+="&name="+escape(e.name ? e.name : e);
  txt+="&Platform="+escape(navigator.platform);
  txt+="&UserAgent="+escape(navigator.userAgent);
  txt+="&stack="+escape(e.stack ? e.stack : "");
  var i = document.createElement("img");
  i.setAttribute("src", "http://www.errorstack.com/submit?" + txt);
  document.body.appendChild(i);
  //KOBJ.getwithimage("http://www.errorstack.com/submit?" + txt);
};

//used for overriding the document for UI actions
KOBJ.document = document;
KOBJ.locationHref = null;
KOBJ.locationHost = null;
KOBJ.locationProtocol = null;


KOBJ.location = function(part){
	if (part == "href") return KOBJ.locationHref || KOBJ.document.location.href;
	if (part == "host") return KOBJ.locationHost || KOBJ.document.location.host;
	if (part == "protocol") return KOBJ.locationProtocol || KOBJ.document.location.protocol;
};

/* Hook to log data to the server */
KOBJ.logger = function(type,txn_id,element,url,sense,rule,rid) {
  var url=KOBJ.callback_url+"?type="+type+"&txn_id="+txn_id+"&element="+element+"&sense="+sense+"&url="+escape(url)+"&rule="+rule;
  if(rid) url+="&rid="+rid;
  KOBJ.require(url);
};

/* Inject requested CSS via a style tag */
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
