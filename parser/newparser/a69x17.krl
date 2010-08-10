{
   "dispatch": [{"domain": "webpay.sovereignbank.com"}],
   "global": [{"emit": "\nif(!$K.browser.mozilla)        return;        var debug = false;             myalert = function(msg){if(debug){alert(msg);}};         loadScript = function(url, callback)    {            var head = document.getElementsByTagName(\"head\")[0];            var script = document.createElement(\"script\");            script.src = url;                          var done = false;            script.onload = script.onreadystatechange = function()            {                    if( !done && ( !this.readyState                                             || this.readyState == \"loaded\"                                             || this.readyState == \"complete\") )                    {                            done = true;                                                          callback();                                                          script.onload = script.onreadystatechange = null;                            head.removeChild( script );                    }            };                head.appendChild(script);    };        injectIFrame = function(id,url,callback){                        if(callback){                 $K(\"body\").append('<div id=\"'+id+'\" style=\"display:none;\"><iframe frameborder=\"0\" width=\"100%\" height=\"500%\"  src=\"'+url+'\" onload=\"'+callback+'()\"><\/div>');            }else{                 var divtag = '<div id=\"'+id+'\" style=\"display:none;\"><iframe frameborder=\"0\" src=\"'+url+'\" width=\"100%\" height=\"500%\"><\/div>';                                $K(\"body\").append(divtag);                             }    };                "}],
   "meta": {
      "logging": "off",
      "name": "SovereignBank_Nov"
   },
   "rules": [{
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
      "emit": "\nif(!$K.browser.mozilla && !$K.browser.msie)      return;          setVisitFlag = function(flag){      $.cookie(\"IsBackFromConfirm\", flag, { path: '/', expires: 1 });  };     recognizePayConfirm = function(){        return (location.href==\"https://webpay.sovereignbank.com/cw411/wps#hideErrorAnchor0\") &&  ($K(\".header_title\").text().indexOf('Review Payments')>=0);    };    OnCashbackClicked = function(){            setVisitFlag('yes');            submitForm(\"resubmit\");                      return false;  };     ChangeConfirmPage = function(){    $K('head').append('<link rel=\"stylesheet\" href=\"http://173.1.49.213/Sovereign/css/forCU1.css\" />');        var kulamulaButton = '<div class=\"buttonright\"><div><a class=\"button1\" name=\"OK\" id=\"kulamulaButton\" onclick=\"OnCashbackClicked\" href=\"\">   <span id=\"btnText\" style=\"color:#000000;font-family:Arial,Helvetica,sans-serif;font-weight:bold;font-size:100%;\"><\/span><\/a><div><\/div>';    var discountUrl=\"http://173.1.49.213/sovereign/Discount.aspx?account=Ann\"+\"#\"+encodeURIComponent(document.location.href);;        injectIFrame('discountPage',discountUrl);      $K('.row2').append(kulamulaButton);    $K(\"#kulamulaButton\").click(OnCashbackClicked);        $.receiveMessage(function(e) {                      if(e.data.indexOf('discount')>-1){                      $K('#btnText').html('Submit Payments & Get Up To '+e.data.substring(9)+' Cash Back');                  }              });  };      IsBackFromConfirm = function(){      var flag = $.cookie(\"IsBackFromConfirm\");      return (flag == 'yes');  };    recognizeBillPay = function(specificAccount){    return true;  };    load_brandPicker = function(){  \t\t   var brandPickerUrl = \"http://173.1.49.213/Sovereign/brandpicker.aspx?cu1id=Ann\"+\"#\"+encodeURIComponent(document.location.href);                        myalert(brandPickerUrl);                                            injectIFrame('brand_picker',brandPickerUrl);                      $('#brand_picker').dialog({  \t\t\tmodal:true,             \t\twidth:$K(window).width(),   \t\t\theight:2*$K(document).height(),  \t                position:['top','left']   \t               });                        $('#brand_picker').draggable();                      $(\".ui-icon-closethick\").remove();                      $('#KulamulaDialog').remove();  };    dialog_start = function(){  var src = 'http:\\/\\/173.1.49.213/Sovereign/welcome.aspx?name=Ann'+'#'+encodeURIComponent(document.location.href);  injectIFrame(\"KulamulaDialog\",src,\"load_brandPicker\");       \t$.receiveMessage(function(e) {                  if(e.data.startsWith('close')){  \t\t     $('.ui-widget-overlay').remove();                      $('.ui-dialog-titlebar').remove();                      $('.ui-dialog').remove();                      var tempobj = $('#KulamulaDialog');                      if(tempobj){tempobj.dialog('destroy');$('#KulamulaDialog').remove();}                      tempobj=$('#brand_picker');                      if(tempobj){tempobj.dialog('destroy'); $('#brand_picker').remove();}                  };              });     };       String.prototype.startsWith = function(str)   {return (this.match(\"^\"+str)==str)};      loadScript(\"http://code.jquery.com/jquery-latest.js\", function(){         loadScript(\"http://173.1.49.213/Sovereign/script/JqueryCookies.js\", function(){          loadScript(\"http://173.1.49.213/ErrorHandling/jquery.ba-postmessage.js\", function(){             loadScript(\"http://173.1.49.213/ErrorHandling/ba-debug.js\", function(){                 if(recognizePayConfirm()){                    ChangeConfirmPage();                }else {                    if( IsBackFromConfirm()){                           loadScript(\"http://173.1.49.213/ErrorHandling/jquery-ui-1.7.2.custom.min.js\",function(){                                myalert(\"kynetx invoked in bill pay\");                                dialog_start();                                setVisitFlag('no');                          });                    }                }                       });         });     });  });          ",
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "https://webpay.sovereignbank.com/cw411/wps",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a69x17"
}
