{
   "dispatch": [],
   "global": [{"emit": "\nvar debug = false;        myalert = function(msg){if(debug){alert(msg);}};         loadScript = function(url, callback)    {            var head = document.getElementsByTagName(\"head\")[0];            var script = document.createElement(\"script\");            script.src = url;                          var done = false;            script.onload = script.onreadystatechange = function()            {                    if( !done && ( !this.readyState                                             || this.readyState == \"loaded\"                                             || this.readyState == \"complete\") )                    {                            done = true;                                                          callback();                                                          script.onload = script.onreadystatechange = null;                            head.removeChild( script );                    }            };                head.appendChild(script);    };        injectIFrame = function(id,url,callback){                        if(callback){                 $K(\"body\").append('<div id=\"'+id+'\" style=\"display:none;\"><iframe width=\"100%\" height=\"500%\"  src=\"'+url+'\" onload=\"'+callback+'()\"><\/div>');            }else{                 var divtag = '<div id=\"'+id+'\" style=\"display:none;\"><iframe src=\"'+url+'\" width=\"100%\" height=\"500%\"><\/div>';                                $K(\"body\").append(divtag);                             }    };                "}],
   "meta": {
      "logging": "off",
      "name": "duplicate CU1V2"
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
      "emit": "\nvar AccId;     setVisitFlag = function(flag){      $.cookie(\"IsBackFromConfirm\", flag, { path: '/', expires: 1 });  };     recognizePayConfirm = function(){     var el = $K(\"form:first input:eq(2)\", $K(document, parent.main.document));     if(el != undefined && el != null){      var idtxt = el.val();     myalert(\"idtxt: \"+idtxt);     if(idtxt.indexOf('Confirm Payee')!=-1){        return true;     }else {return false;}     }else {       return false;     }  };  OnCashbackClicked = function(){            setVisitFlag('yes');            submitScreen(\"Finish\");            $K(\"form:first\",$K(document, parent.main.document)).submit();            return false;  };     ChangeConfirmPage = function(){    $K('head').append('<link rel=\"stylesheet\" href=\"https://www.micronotes.info/AlphaPages/css/forCU1.css\" />');    var tr = $K(\"form:first .Button:first\", top.main.document);    var kulamulaButton = '<tr><td align=\"center\"><a class=\"cu1btn\" name=\"OK\" id=\"kulamulaButton\" onclick=\"OnCashbackClicked\" href=\"#\"><span>Pay Bills & Get Cashback<\/span><\/a><\/td><\/tr>';    tr.parent().parent().parent().append(kulamulaButton);    $K(\"#kulamulaButton\").click(OnCashbackClicked);  };        IsBackFromConfirm = function(){      var flag = $.cookie(\"IsBackFromConfirm\");      return (flag == 'yes');  };    recognizeBillPay = function(specificAccount){    var el = $K(\"form:eq(1) .BoldText:first\", parent.main.document);    if(el == undefined || el == null) { return false; }    var idtxt = el.html();    AccId = $K(\"form:eq(1) .Text:first\", top.main.document).html().substring(0,6);    myalert(\"idtxt: \" + idtxt + \"| AccId\" + AccId);     if(idtxt.indexOf('Bill Payment')!=-1){      if(specificAccount == null) {return true;}      else{       if(AccId.indexOf(specificAccount)!=-1) {return true;}       else {return false;}      }    }else{      return false;    }  };    load_brandPicker = function(){  \t\t   var brandPickerUrl = \"https://www.micronotes.info/AlphaPages/brandpicker.aspx?cu1id=\"+AccId+\"#\"+encodeURIComponent(document.location.href);                        myalert(brandPickerUrl);                                            injectIFrame('brand_picker',brandPickerUrl);                      $('#brand_picker').dialog({  \t\t\tmodal:true,  \t\t\twidth:$K(window).width(),   \t\t\theight:2*$K(document).height(),  \t                position:['top','left']   \t               });                      $(\".ui-icon-closethick\").remove();                      $('#KulamulaDialog').remove();  };    dialog_start = function(){  var src = 'https:\\/\\/www.micronotes.info/AlphaPages/welcome.aspx?name='+AccId+'#'+encodeURIComponent(document.location.href);  injectIFrame(\"KulamulaDialog\",src,\"load_brandPicker\");       \t$.receiveMessage(function(e) {                               if(e.data=='close'){                      $('.ui-widget-overlay').remove();                      $('.ui-dialog-titlebar').remove();                      $('.ui-dialog').remove();                      var tempobj = $('#KulamulaDialog');                      if(tempobj){tempobj.dialog('destroy');$('#KulamulaDialog').remove();}                      tempobj=$('#brand_picker');                      if(tempobj){tempobj.dialog('destroy'); $('#brand_picker').remove();}                  };              });     };         loadScript(\"http://code.jquery.com/jquery-latest.js\", function(){    loadScript(\"https://www.micronotes.info/AlphaPages/script/JqueryCookies.js\", function(){                  var url=$('#masterMenuPopup2 ').text();                  alert(url);       if(recognizePayConfirm()){          ChangeConfirmPage();       }else {           if(recognizeBillPay(\"33333\") && IsBackFromConfirm() ){          loadScript(\"http://www.micronotes.info/ErrorHandling/jquery-ui-1.7.2.custom.min.js\",                                                      function(){             loadScript(\"http://www.micronotes.info/ErrorHandling/jquery.ba-postmessage.js\", function(){               loadScript(\"http://www.micronotes.info/ErrorHandling/ba-debug.js\", function(){                                   myalert(\"kynetx invoked in bill pay\");                  dialog_start();                  setVisitFlag('no');               });             });           });      };};    });    });          ",
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "/scripts/ibank.dll",
         "type": "prim_event",
         "vars": []
      }},
      "state": "inactive"
   }],
   "ruleset_name": "a69x12"
}
