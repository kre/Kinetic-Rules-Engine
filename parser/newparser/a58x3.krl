{
   "dispatch": [
      {"domain": "www.zappos.com"},
      {"domain": "www.google.com"},
      {"domain": "search.yahoo.com"}
   ],
   "global": [{"emit": "\nKOBJ.bn = {\"www.barnesandnoble.com\" :                   [{\"link\":                     \"http://www.skymall.com/usairwaysmilesmall/store.htm?m=1117&nav=store\",    \t\t \"text\":    \t\t \"Earn 3 Dividend Miles per dollar spent\"                    }                   ]    \t\t};                           "}],
   "meta": {
      "description": "\nBarclay Demo   \n",
      "logging": "off",
      "name": "Barclay"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "bn_selector"
            }],
            "modifiers": [
               {
                  "name": "name",
                  "value": {
                     "type": "str",
                     "val": "remindme"
                  }
               },
               {
                  "name": "head_image",
                  "value": {
                     "type": "str",
                     "val": "http://frag.kobj.net/clients/1024/images/remindme_bar40_l.png"
                  }
               },
               {
                  "name": "tail_image",
                  "value": {
                     "type": "str",
                     "val": "http://frag.kobj.net/clients/1024/images/remindme_bar40_r.png"
                  }
               },
               {
                  "name": "height",
                  "value": {
                     "type": "str",
                     "val": "40px"
                  }
               },
               {
                  "name": "left_margin",
                  "value": {
                     "type": "str",
                     "val": "46px"
                  }
               }
            ],
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [],
            "function_expr": {
               "type": "var",
               "val": "truth"
            },
            "type": "app"
         },
         "emit": "\nfunction bn_selector(obj){       function mk_anchor (o, key) {      return $K('<a href=' + o.link + '/>').attr(        {\"class\": 'KOBJ_'+key, \"title\": o.text || \"Click here for discounts!\"}).html(\"<img src='http://www.azigo.com/sales-demo/usairways_logo_bug.png' border='0' width='30px' height='20px' style='margin-top:10px'>\");     }    var host = KOBJ.get_host($K(obj).find(\"span.url, cite\").text());    var o = KOBJ.pick(KOBJ.bn[host]);    if(o) {       return mk_anchor(o,'bn');    } else {      false;    }    }            ",
         "foreach": [],
         "name": "googlesearch",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com|search.yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "url_pf",
            "rhs": {
               "type": "str",
               "val": "http://frag.kobj.net/clients/1024/"
            },
            "type": "expr"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "<img src='http://frag.kobj.net/clients/azigo_citi_demo/images/azigo_logo_black_34.png'>"
                  },
                  {
                     "type": "var",
                     "val": "invite"
                  }
               ],
               "modifiers": [
                  {
                     "name": "opacity",
                     "value": {
                        "type": "num",
                        "val": 1
                     }
                  },
                  {
                     "name": "sticky",
                     "value": {
                        "type": "bool",
                        "val": "true"
                     }
                  }
               ],
               "name": "notify",
               "source": null
            }},
            {"action": {
               "args": [{
                  "type": "str",
                  "val": "span.no_thanks"
               }],
               "modifiers": null,
               "name": "close_notification",
               "source": null
            }}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfill_card = function(type) {   $K('input[name=ccard_z_number]').attr('value','4121555544444321');   $K('select[name=ccard_z_exp_month]>option[value=02]').attr('selected','selected');   $K('select[name=ccard_z_exp_year]>option[value=2011]').attr('selected','selected');    $K('#screenOne').hide();    $K('#screenTwo').hide();    $K('#screenThree').hide();    if (type=='miles')       $K('#wellDone1').show();    else       $K('#wellDone2').show();  };    show_miles = function(){    $K('#screenOne').hide();    $K('#screenTwo').show();  }  ;show_card = function(){    $K('#screenOne').hide();    $K('#screenThree').show();  }  ;noThanks = function(){    $K('#screenOne').show();    $K('#screenTwo').hide();    $K('#screenThree').hide();  };              ",
         "foreach": [],
         "name": "checkout",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://shopping.zappos.com/reqauth/checkout.cgi|https://secure-www.zappos.com/checkout",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #FFFFFF;    width: 225px;    text-align: center;    color: black;\">    <div id=\"screenOne\" style=\"margin-left:30px;\">  <table border=\"0\">  <tr>   <td><span style=\"color: #72BDCA; font-weight:bold;\"><\/span><\/td>   <td><img style=\"margin-left:-30px\" src=\"http://www.azigo.com/sales-demo/usairways_logo.jpg\" width=\"70px\"><\/td>    <\/tr>  <\/table>  <table border=\"0\" style=\"margin-top: 20px;\" align=\"center\" >  <tr>  <td><span>Remember to use your Dividend Miles Card!<\/span><\/td>  <\/tr><tr>   <td>    <span style=\"cursor: pointer;margin-left:15px;\"><img src=\"http://www.azigo.com/sales-demo/usairways_card.jpg\" width=\"120px\" sonclick=\"fill_card();\"><\/span>   <\/td>  <\/tr>  <\/table>  <!--  <table border=\"0\" style=\"margin-top: 20px;\" >  <tr>    <td><span>Use your Dividend Miles<\/span><\/td>   <td>    <span style=\"cursor: pointer; align:left;\"><img src=\"http://www.azigo.com/sales-demo/usairwayscart.png\" width=\"100px\" onclick=\"show_miles();\"><\/span>   <\/td>  <\/tr >  <\/table>  -->  <table border=\"0\" style=\"margin-top: 20px;\" >  <tr align=\"center\">   <td colspan=\"2\" align=\"center\">    <span class=\"no_thanks\" style=\"cursor: pointer; align:center; margin-left:-13px;\"><img src=\"http://www.azigo.com/sales-demo/NoThanksButton.png\"><\/span>   <\/td>  <\/tr>  <\/table>  <\/center>  <\/div>              <div id=\"screenTwo\" style=\"display:none;\">  <table>  <tr style=\"margin-top: 30px;\">   <td><span style=\"color: #72BDCA; font-weight:bold\">Two ways to buy!<\/span><\/td>   <td><img src=\"http://www.azigo.com/sales-demo/usairways_logo.jpg\" width=\"70px\"><\/td>    <\/tr>  <\/table><br/>  <div style=\"align: center; \">  <img src=\"http://www.azigo.com/sales-demo/usairwayscart.png\" width=\"100px\"><br/>  <span style=\"font-weight:bold;margin-top:3px;\">Use your Dividend Miles!<\/span><br/>    <div class=\"info\" style=\"margin: 20px;\">      Balance: 150,351<br/>      Needed: 7,200<br/>    <\/div>  <span style=\"cursor: pointer; margin-left:-5px;\"><img src=\"http://www.azigo.com/sales-demo/UseMilesButton.png\" onclick=\"fill_card('miles');\" width=\"200px\"><br/>  <span style=\"cursor: pointer;\"><img src=\"http://www.azigo.com/sales-demo/GoBackButton.png\" onclick=\"noThanks();\">  <\/div>  <\/div>              <div id=\"screenThree\" style=\"display:none;\">  <table>  <tr style=\"margin-top: 30px;\">   <td><span style=\"color: #72BDCA; font-weight:bold\">Don't forget...<\/span><\/td>   <td><img src=\"http://www.azigo.com/sales-demo/usairways_logo.jpg\" width=\"80px\"><\/td>    <\/tr>  <\/table><br/>  <div style=\"align: center; margin-top:20px;\">  <span style=\"font-weight:bold;\">Use your SkyMiles AMEX card now and earn even more miles!<\/span><br/>  <div style=\"margin-top: 20px;\">  <img src=\"http://www.azigo.com/sales-demo/usairways_card.jpg\" width=\"160px\">  <\/div>  <br/>  <span style=\"font-weight:bold;\">Want to use your SkyMiles AMEX?<\/span><br/>  <div style=\"margin-top: 30px;\">  <span style=\"cursor: pointer;\"><img src=\"http://www.azigo.com/sales-demo/LetsUseItButton.png\" onclick=\"fill_card('card');\" width=\"200px\"><br/>  <span style=\"cursor: pointer;\"><img src=\"http://www.azigo.com/sales-demo/NoThanksButton.png\" onclick=\"noThanks();\">  <\/div>  <\/div>  <\/div>      <div id=\"wellDone1\" style=\"display:none; margin:15px; font-weight:bold; align: center;\">    Thank you, Jack. You've just saved $72.00 with Dividend Miles Card.<br/><br/><br/>    Your confirmation number is <span style=\"color:red\">GP965J23<\/span>.<br/><br/><br/>   <span class=\"no_thanks\" style=\"cursor: pointer;\"><img src=\"http://www.azigo.com/sales-demo/CloseButton.png\">  <\/div>    <div id=\"wellDone2\" style=\"display:none; margin:15px; font-weight:bold; align: center;\">    Thank you, Jack. You've just earned 7,200 Dividend Miles.<br/><br/><br/>    Your confirmation number is <span style=\"color:red\">GP592J23<\/span>.<br/><br/><br/>  <span class=\"no_thanks\" style=\"cursor: pointer;\"><img src=\"http://www.azigo.com/sales-demo/CloseButton.png\">  <\/div>      <\/p>  <\/div>     \n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a58x3"
}
