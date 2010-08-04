{
   "dispatch": [{"domain": "bankofamerica.com"}],
   "global": [{"emit": "\nvar old_domain = document.domain;       var old_fragment = window.location.hash;       $(\"head\").append(\"<script type='text/javascript' src='http://www.json.org/json2.js' /><\/script>\");           listen = function(ifrm){        if(old_fragment!=window.location.hash){             var response = window.location.hash.substring(1);             alert(\"in linsten the response is:\" + response);             eval(response);             if(talk.talker == ifrm) return talk.content;        }else{             response = \"notready\";             setTimeout(\"listen(\"+ifrm+\")\",500);        }       };       tellParent = function(frag){        parent.location = parent.location.href.substring(0,parent.location.href.length - parent.location.hash.length) + \"#\" + frag;       };       tellChild = function(url, ifrmID, fragment){         var i = $(\"#\"+ifrmID);         if(i == undefined || i== null || i.length == 0 || i[0] == undefined){           $(\"body\").append('<IFRAME id=\"'+ ifrmID +'\" name=\"'+ifrmID+'_name\"/>');           alert(\"create iframe:\" + ifrmID);           i = $(\"#\"+ifrmID);           i.load(                     function(){                        }                 );          }         i.attr(\"src\", url+\"#\"+fragment);       };                "}],
   "meta": {
      "logging": "off",
      "name": "Test"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nvar address = $(\".txtAddDet:first\").text().replace(/^\\s+|\\s+$/g,\"\").replace(/\\s+<br\\s*\\/?>\\s+/g,\" \");  $(\"body\").append(\"<span id='address'>\"+address+\"<\/span>\");        var phone = $(\".txtPHNTXT:last\").text().replace(/^\\s+|\\s+$/g,\"\").substr(this.length-14,12);  $(\"body\").append(\"<span id='phone'>\"+phone+\"<\/span>\");      var obj = {\"talker\":this.id,\"content\":{\"address\":address,\"phone\":phone}};    var saying = JSON.stringify(obj, function (key, value) {      return value;  });    tellParent(saying);            ",
         "foreach": [],
         "name": "address_extract",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*SecurityCenterControl\\?custAction=4",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "EXTRACTED EMAIL:"
               },
               {
                  "type": "var",
                  "val": "email"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nvar email = $(\".SFtdtext1:first\").text().replace(/^\\s+|\\s+$/g,\"\");  $(\"body\").append(\"<span id='email'>\"+email+\"<\/span>\");          ",
         "foreach": [],
         "name": "email_extract",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "SecurityCenterControl\\?custAction=5",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "account number"
               },
               {
                  "type": "var",
                  "val": "accNum"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nvar accNum = $(\".OverText\",$(\"#ttAcctNo1\")).text().replace(\"/\\s*<.*>\\s*/g\",\"\");    $(\"body\").append(\"<span id='accNum' style='display:none;'>\"+accNum+\"<\/span>\");          ",
         "foreach": [],
         "name": "account_extract",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "/GotoOnlineStatement",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nvar SecurityCenter_link = $(\".cmslinknormal:first\").attr(\"href\");     tellChild(SecurityCenter_link, \"security_center\", \"\");        obj = listen(\"security_center\");             var Account_link = $(\"a:eq(2)\",$(\".secondaryNavCnt\")).attr(\"href\");          ",
         "foreach": [],
         "name": "overview_links_extract",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "GotoWelcome",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "domain"
               },
               {
                  "type": "var",
                  "val": "msg"
               }
            ],
            "modifiers": null,
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nvar old_domain = document.domain;     document.domain = \"bankofamerica.com\";     var new_domain = document.domain;     msg = \"old domain:\" + old_domain + \"<br />\" + \"new domain:\" + new_domain;          ",
         "foreach": [],
         "name": "super_domain",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "state": "inactive"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nvar email_link = $(\"a:eq(0)\",$(\"#Personal\")).attr(\"href\");  tellChild(email_link,\"email_frm\",\"\");      var addr_link = $(\"a:eq(1)\",$(\"#Personal\")).attr(\"href\");  tellChild(addr_link,\"addr_frm\",\"\");    var msgobj = listen(\"addr_frm\");  var msg = JSON.stringify(msgobj , function (key, value) {      return value;  });  var f = function(){      alert(msg);  };  var itvl = setInterval(\"f\", 2000);            ",
         "foreach": [],
         "name": "securitycenter_link",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "GotoSecurityCenter",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a83x2"
}
