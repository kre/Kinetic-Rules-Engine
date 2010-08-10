{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "search.yahoo.com"}
   ],
   "global": [{
      "content": ".superSearchNav img {    \t\twidth: 12px;    \t\tborder: none;    \t}    ",
      "type": "css"
   }],
   "meta": {
      "logging": "on",
      "name": "Super Search"
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
         "emit": "\nfunction superSearch(){    \t$K('body').append(messageBing);  \t  \t$K('#bingDiv').tabSlideOut({tabHandle: '#bingTab','pathToTabImage':'http:\\/\\/www.jessiemorris.com/random/a41x79/bing.png',imageHeight: '122px',imageWidth: '58px',tabLocation: 'right',speed: 300,action: 'click',topPos: '30px',fixedPosition: true});    \t$K('#bingTab').click(bingFunc = function(){ $K('#bingIframe').append('<iframe id=\"bing\" name=\"bing\" src=\"http://www.bing.com/search?q='+searchTerms+'\" width=\"996px\" height=\"400px\" style=\"border: groove; background-color: white;\" onload=\"$K(\\'#bingTab\\').unbind(\\'click\\',bingFunc);$K(\\'#bingLoading\\').slideUp(\\'fast\\'); $K(\\'#bingIframe\\').slideDown(\\'fast\\');\" />');});    \t$K('body').append(messageYahoo);  \t  \t$K('#yahooDiv').tabSlideOut({tabHandle: '#yahooTab','pathToTabImage':'http:\\/\\/www.jessiemorris.com/random/a41x79/yahoo.png',imageHeight: '102px',imageWidth: '60px',tabLocation: 'right',speed: 300,action: 'click',topPos: '260px',fixedPosition: true});  \t  \t$K('#yahooTab').click(yahooFunc = function(){ $K('#yahooIframe').append('<iframe id=\"yahoo\" name=\"yahoo\" src=\"http://search.yahoo.com/search?p='+searchTerms+'\" width=\"996px\" height=\"400px\" style=\"border: groove; background-color: white;\" onload=\"$K(\\'#yahooTab\\').unbind(\\'click\\',yahooFunc);$K(\\'#yahooLoading\\').slideUp(\\'fast\\'); $K(\\'#yahooIframe\\').slideDown(\\'fast\\');\" />');});  \tvar shouldReplace = Math.ceil(Math.random() * 10);  \t  \t$K(\"#mbEnd\").html('<tr><td><iframe src=\"http://www.caandb.com/ads/250x250.php?keywords='+searchTermsURL+'\" height=\"282px\" width=\"258px\" style=\"border: none;\" /><\/td><\/tr>');    }    superSearch();              ",
         "foreach": [],
         "name": "google",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.com/search.*(?:&|\\?)q=([^&]*)(?:&|$)",
            "type": "prim_event",
            "vars": ["searchTermsURL"]
         }},
         "pre": [
            {
               "lhs": "searchTerms",
               "rhs": {
                  "type": "var",
                  "val": "searchTermsURL"
               },
               "type": "expr"
            },
            {
               "lhs": "messageBing",
               "rhs": " \n<div id=\"bingDiv\" style=\"z-index: 50; width: 1000px;\">  \t\t\t<a href=\"#\" id=\"bingTab\">  \t\t\t\tBing  \t\t\t<\/a>  \t\t\t<div class=\"searchLoading\" id=\"bingLoading\" style=\"width: 1000px; text-align: center; background-color: #fff;\">  \t\t\t\t<img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/ajax-loader.gif\" alt=\"Loading...\" style=\"margin: 0 auto; \"/><p><h2>Loading...<\/h2><\/p>  \t\t\t<\/div>  \t\t\t<div id=\"bingIframe\" style=\"display: none;\">  \t\t\t\t<div id=\"bingNav\" class=\"superSearchNav\" style=\"height: 20px; background-color: white;\">  \t\t\t\t\t<a href=\"javascript:frames['bing'].history.back();\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/back.png\" alt=\"Back\" /><\/a>  \t\t\t\t\t<a href=\"javascript:frames['bing'].history.forward();\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/forward.png\" alt=\"Forward\" /><\/a>  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\t<\/div>  \t\n ",
               "type": "here_doc"
            },
            {
               "lhs": "messageYahoo",
               "rhs": " \n<div id=\"yahooDiv\" style=\"z-index: 51; width: 1000px;\">  \t\t\t<a href=\"#\" id=\"yahooTab\">  \t\t\t\tYahoo  \t\t\t<\/a>  \t\t\t<div class=\"searchLoading\" id=\"yahooLoading\" style=\"width: 1000px; text-align: center; background-color: #fff;\">  \t\t\t\t<img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/ajax-loader.gif\" alt=\"Loading...\" style=\"margin: 0 auto; \"/><p><h2>Loading...<\/h2><\/p>  \t\t\t<\/div>  \t\t\t  \t\t\t<div id=\"yahooIframe\" style=\"display: none;\">  \t\t\t\t<div id=\"yahooNav\" class=\"superSearchNav\" style=\"height: 20px; background-color: white;\">  \t\t\t\t\t<a href=\"javascript:frames['yahoo'].history.back();\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/back.png\" alt=\"Back\" /><\/a>  \t\t\t\t\t<a href=\"javascript:frames['yahoo'].history.forward();\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/forward.png\" alt=\"Forward\" /><\/a>  \t\t\t\t<\/div>  \t\t\t<\/div>  \t\t<\/div>  \t\n ",
               "type": "here_doc"
            }
         ],
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
         "emit": "\nvar url = window.location.href;  \tsearchTerms = url.replace(/.*?q=(.*?)&.*/i,\"$1\");  \tif(url == searchTerms){  \t\tsearchTerms = '';  \t}    \tfunction superSearch(){  \t  \t\t\tmessageBing = '<div id=\"bingDiv\" style=\"z-index: 50; width: 1000px;\"><a href=\"#\" id=\"bingTab\">Bing<\/a><div class=\"searchLoading\" id=\"bingLoading\" style=\"width: 1000px; text-align: center; background-color: #fff;\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/ajax-loader.gif\" alt=\"Loading...\" style=\"margin: 0 auto; \"/><p><h2>Loading...<\/h2><\/p><\/div><div id=\"bingIframe\" style=\"display: none;\"><div id=\"bingNav\" class=\"superSearchNav\" style=\"height: 20px; background-color: white;\"><a href=\"javascript:frames[\\'bing\\'].history.back();\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/back.png\" alt=\"Back\" /><\/a><a href=\"javascript:frames[\\'bing\\'].history.forward();\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/forward.png\" alt=\"Forward\" /><\/a><\/div><\/div><\/div>';    \tmessageYahoo = '<div id=\"yahooDiv\" style=\"z-index: 51; width: 1000px;\"><a href=\"#\" id=\"yahooTab\">Yahoo<\/a><div class=\"searchLoading\" id=\"yahooLoading\" style=\"width: 1000px; text-align: center; background-color: #fff;\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/ajax-loader.gif\" alt=\"Loading...\" style=\"margin: 0 auto; \"/><p><h2>Loading...<\/h2><\/p><\/div><div id=\"yahooIframe\" style=\"display: none;\"><div id=\"yahooNav\" class=\"superSearchNav\" style=\"height: 20px; background-color: white;\"><a href=\"javascript:frames[\\'yahoo\\'].history.back();\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/back.png\" alt=\"Back\" /><\/a><a href=\"javascript:frames[\\'yahoo\\'].history.forward();\"><img src=\"http:\\/\\/www.jessiemorris.com/random/a41x79/forward.png\" alt=\"Forward\" /><\/a><\/div><\/div><\/div>';  \t\t  \t  \t\t$K('body').append(messageBing);  \t\t$K('body').append(messageYahoo);  \t\t  \t\t$K('#bingDiv').tabSlideOut({tabHandle: '#bingTab','pathToTabImage':'http:\\/\\/k-misc.s3.amazonaws.com/resources/a41x79/bing.png',imageHeight: '122px',imageWidth: '58px',tabLocation: 'right',speed: 300,action: 'click',topPos: '30px',fixedPosition: true});  \t  \t\t$K('#bingTab').click(bingFunc = function(){ $K('#bingIframe').append('<iframe src=\"http:\\/\\/www.bing.com/search?q='+searchTerms+'\" width=\"994px\" height=\"400px\" style=\"border: groove; background-color: white;\" onload=\"$K(\\'#bingLoading\\').slideUp(\\'fast\\'); $K(\\'#bingIframe\\').slideDown(\\'fast\\');\" />'); $K('#bingTab').unbind('click',bingFunc);});  \t  \t\t  \t\t$K('#yahooDiv').tabSlideOut({tabHandle: '#yahooTab','pathToTabImage':'http:\\/\\/k-misc.s3.amazonaws.com/resources/a41x79/yahoo.png',imageHeight: '102px',imageWidth: '60px',tabLocation: 'right',speed: 300,action: 'click',topPos: '260px',fixedPosition: true});  \t\t  \t\t$K('#yahooTab').click(yahooFunc = function(){ $K('#yahooIframe').append('<iframe src=\"http:\\/\\/search.yahoo.com/search?p='+searchTerms+'\" width=\"994px\" height=\"400px\" style=\"border: groove; background-color: white;\" onload=\"$K(\\'#yahooLoading\\').slideUp(\\'fast\\'); $K(\\'#yahooIframe\\').slideDown(\\'fast\\');\" />'); $K('#yahooTab').unbind('click',yahooFunc);});    \t\tvar shouldReplace = true;  \t\t  \t\tif(shouldReplace){  \t\t\t$K(\"#mbEnd\").html('<tr><td><iframe src=\"http://www.caandb.com/ads/250x250.php?keywords='+searchTerms+'\" height=\"282px\" width=\"258px\" style=\"border: none;\" /><\/tr><\/td>');  \t\t}  \t  \t}  \t  \tsuperSearch();  \t  \tfunction newSearch(){  \t\tvar url = window.location.href;  \t\tsearchTerms = url.replace(/.*?q=(.*?)&.*/i,\"$1\");  \t\tif(url == searchTerms){  \t\t\tsearchTerms = '';  \t\t}  \t\tif($K('#bingIframe iframe').length){  \t\t\t$K('#bingIframe iframe').attr('src','http:\\/\\/www.bing.com/search?q='+searchTerms);  \t\t        $K('#yahooIframe iframe').attr('src','http:\\/\\/search.yahoo.com/search?p='+searchTerms);  \t\t\t$K('#bingIframe,#yahooIframe').slideUp('fast');  \t\t\t$K('#bingLoading,#yahooLoading').slideDown('fast');  \t\t} else { }  \t  \t\t$K(\"#mbEnd\").html('<tr><td><iframe src=\"http://www.caandb.com/ads/250x250.php?keywords='+searchTerms+'\" height=\"282px\" width=\"258px\" style=\"border: none;\" /><\/td><\/tr>');    \t}  \t  \tKOBJ.watchDOM(\"#search,#footer\",newSearch);              ",
         "foreach": [],
         "name": "google_ajax",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.google.com/(?!search).*(webhp|hl|$)",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [],
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\nfunction bingButton(){  var googleSearchButton = $K(\"#canvas_frame\").contents().find(\"#\\\\:rf\");  var googleSearchTerms = $K(\"#canvas_frame\").contents().find(\"#\\\\:re\").val();  var bingSearchButton = '<div id=\"bingButton\" class=\"J-K-I J-J5-Ji L3\"><div class=\"J-J5-Ji J-K-I-Kv-H\"><div class=\"J-J5-Ji J-K-I-J6-H\"><div class=\"J-K-I-KC\"><div class=\"J-K-I-K9-KP\" /><div class=\"J-K-I-Jz\">Search Bing<\/div><\/div><\/div><\/div><\/div>';    $K(googleSearchButton).after(bingSearchButton);    var bingSearchButton = $K(\"#canvas_frame\").contents().find(\"#bingButton\");  $K(bingSearchButton).bind(\"click\",function(){var googleSearchTerms = $K(\"#canvas_frame\").contents().find(\"#\\\\:re\").val();window.location='http:\\/\\/www.bing.com/search?q='+googleSearchTerms;});  }    bingButton();    KOBJ.watchDOM(\"body\",bingButton);                    "},
            {"action": {
               "args": [],
               "modifiers": null,
               "name": "noop",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "bing_gmail",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "mail.google.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a41x79"
}
