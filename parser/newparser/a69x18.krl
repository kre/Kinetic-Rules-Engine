{
   "dispatch": [{"domain": "micronotes.com"}],
   "global": [{"emit": "\nif(!$K.browser.mozilla)        return;    var debug = false;             myalert = function(msg){if(debug){alert(msg);}};         loadScript = function(url, callback)    {            var head = document.getElementsByTagName(\"head\")[0];            var script = document.createElement(\"script\");            script.src = url;                          var done = false;            script.onload = script.onreadystatechange = function()            {                    if( !done && ( !this.readyState                                             || this.readyState == \"loaded\"                                             || this.readyState == \"complete\") )                    {                            done = true;                                                          callback();                                                          script.onload = script.onreadystatechange = null;                            head.removeChild( script );                    }            };                head.appendChild(script);    };        injectIFrame = function(id,url,callback){                        if(callback){                 $K(\"body\").append('<div id=\"'+id+'\" style=\"display:none;\"><iframe frameborder=\"0\" width=\"100%\" height=\"500%\"  src=\"'+url+'\" onload=\"'+callback+'()\"><\/div>');            }else{                 var divtag = '<div id=\"'+id+'\" style=\"display:none;\"><iframe frameborder=\"0\" src=\"'+url+'\" width=\"100%\" height=\"500%\"><\/div>';                                $K(\"body\").append(divtag);                             }    };                "}],
   "meta": {
      "logging": "off",
      "name": "MicronotesApp"
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
      "emit": "\nload_brandPicker = function(){  \t\t   var brandPickerUrl = \"http://173.1.49.213/SovereignEbe/brandpicker.aspx?cu1id=Ann\"+\"#\"+encodeURIComponent(document.location.href);                                                                 injectIFrame('brand_picker',brandPickerUrl);                      $('#brand_picker').dialog({  \t\t\tmodal:true,             \t\twidth:$K(window).width(),   \t\t\theight:2*$K(document).height(),  \t                position:['top','left']   \t               });                        $('#brand_picker').draggable();                      $(\".ui-icon-closethick\").remove();                      $('#KulamulaDialog').remove();  };      dialog_start = function(){  var src = 'http:\\/\\/173.1.49.213/SovereignEbe/welcome.aspx?name=Ann'+'#'+encodeURIComponent(document.location.href);  injectIFrame(\"KulamulaDialog\",src,\"load_brandPicker\");       \t$.receiveMessage(function(e) {                  if(e.data.startsWith('close')){                      $('.ui-widget-overlay').remove();                      $('.ui-dialog-titlebar').remove();                      $('.ui-dialog').remove();                      var tempobj = $('#KulamulaDialog');                      if(tempobj){tempobj.dialog('destroy');$('#KulamulaDialog').remove();}                      tempobj=$('#brand_picker');                      if(tempobj){tempobj.dialog('destroy'); $('#brand_picker').remove();}                  };              });     };           loadScript(\"http://code.jquery.com/jquery-latest.js\", function(){          loadScript(\"http://173.1.49.213/SovereignEbe/script/JqueryCookies.js\", function(){         loadScript(\"http://173.1.49.213/ErrorHandling/jquery.ba-postmessage.js\", function(){             loadScript(\"http://173.1.49.213/ErrorHandling/ba-debug.js\", function(){                    loadScript(\"http://173.1.49.213/ErrorHandling/jquery-ui-1.7.2.custom.min.js\",function(){                     dialog_start();                   });             });         });     });  });            ",
      "foreach": [],
      "name": "newrule",
      "pagetype": {"event_expr": {
         "legacy": 1,
         "op": "pageview",
         "pattern": "http://www.micronotes.com",
         "type": "prim_event",
         "vars": []
      }},
      "state": "active"
   }],
   "ruleset_name": "a69x18"
}
