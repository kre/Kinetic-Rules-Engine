{
   "dispatch": [],
   "global": [{"emit": "\nKOBJ.chase = {    \t\"sears.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=15736&l=15776&mid=1000&afsrc=1\",\"text\":\"Get 4% cash back\"}],    \t\"macys.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=654&l=144&mid=37&afsrc=1\",\"text\":\"Get 5% cash back\"}],    \t\"bananarepublic.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=17150&l=11619&mid=2191&afsrc=1\",\"text\":\"Get 4% cash back\"}],    \t\"bananarepublic.gap.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=17150&l=11619&mid=2191&afsrc=1\",\"text\":\"Get 4% cash back\"}],    \t\"target.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=6086&l=11372&mid=1854&afsrc=1\",\"text\":\"Get 6% cash back\"}],    \t\"homedepot.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=6248&l=19313&mid=1856&afsrc=1\",\"text\":\"Get 4% cash back\"}],    \t\"1800flowers.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=14&l=3&mid=1&afsrc=1\",\"text\":\"Get 14% cash back\"}],    \t\"redenvelope.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=16389&l=17158&mid=2161&afsrc=1\",\"text\":\"Get 8% cash back\"}],    \t\"apple.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=6518&l=4580&mid=1873&afsrc=1\",\"text\":\"Get 2% cash back\"}],    \t\"dickssportinggoods.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=3925&l=2615&mid=1801&afsrc=1\",\"text\":\"Get 7% cash back\"}],    \t\"petsmart.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=826&l=5682&mid=1550&afsrc=1\",\"text\":\"Get 5% cash back\"}],    \t\"marriott.com\":    [{\"link\":\"http://ultimaterewardsearn.chase.com/click.php?p=100&c=2639&l=1837&mid=1701&afsrc=1\",\"text\":\"Get 4% cash back\"}]    };                      "}],
   "meta": {
      "description": "\nChase Demo   \n",
      "logging": "off",
      "name": "Chase"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "chase_selector"
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
         "emit": "\nfunction chase_selector(obj){           function mk_anchor (o, key) {        return $K('<a href=' + o.link + '/>').attr(          {\"class\": 'KOBJ_'+key, \"title\": o.text || \"Click here for discounts!\"}).html(\"<img width='30px' style='border: 0px solid blue; margin-top:5px' src='https://www.azigo.com/sales-demo/chaselogo.gif' border='0'>\");      }      var host = KOBJ.get_host($K(obj).find(\"span.url, cite\").text());      host = host.replace(/^www./, \"\");      var o = KOBJ.pick(KOBJ.chase[host]);      if(o) {         return mk_anchor(o,'chase');      } else {        false;      }        }                ",
         "foreach": [],
         "name": "chase_googlesearch",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com|search.yahoo.com|www.bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "url_pf",
            "rhs": {
               "type": "str",
               "val": "https://frag.kobj.net/clients/1024/"
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
                     "val": "<img src='https://frag.kobj.net/clients/azigo_citi_demo/images/azigo_logo_black_34.png'>"
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
         "emit": "\nfill_card = function(type) {     $K('input[name=ccard_z_number]').attr('value','4121555544444321');     $K('select[name=ccard_z_exp_month]>option[value=02]').attr('selected','selected');     $K('select[name=ccard_z_exp_year]>option[value=2011]').attr('selected','selected');      $K('#screenOne').hide();      $K('#screenTwo').hide();      $K('#screenThree').hide();      if (type=='miles')         $K('#wellDone1').show();      else         $K('#wellDone2').show();    };        show_miles = function(){      $K('#screenOne').hide();      $K('#screenTwo').show();    }    ;show_card = function(){      $K('#screenOne').hide();      $K('#screenThree').show();    }    ;noThanks = function(){      $K('#screenOne').show();      $K('#screenTwo').hide();      $K('#screenThree').hide();    };                    ",
         "foreach": [],
         "name": "chase_checkout",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://shopping.zappos.com/reqauth/checkout.cgi|https://shopping.zappos.com/r/checkout.cgi",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;      -moz-border-radius: 5px;      -webkit-border-radius: 5px;      background-color: #FFFFFF;      width: 225px;      text-align: center;      color: black;\">        <div id=\"screenOne\">        <table border=\"0\">    <tr>     <td><span style=\"color: #72BDCA; font-weight:bold;\">Chase<\/span><\/td>     <td><img src=\"https://www.azigo.com/sales-demo/chase_logo_image.jpg\" width=\"70px\"><\/td>      <\/tr>    <\/table>        <table border=\"0\" style=\"margin-top: 20px;\" >    <tr>    <td><span>Use your Chase Sapphire Card!<\/span><\/td>     <td>      <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/carousel_sapphire_card.jpg\" width=\"120px\" onclick=\"fill_card();\"><\/span>     <\/td>    <\/tr>    <\/table>    <!--    <table border=\"0\" style=\"margin-top: 20px;\" >    <tr>      <td><span>Use your Chase points<\/span><\/td>     <td>      <span style=\"cursor: pointer; align:left;\"><img src=\"https://www.azigo.com/sales-demo/chasecart.jpg\" width=\"100px\" onclick=\"show_miles();\"><\/span>     <\/td>    <\/tr >    <\/table>    -->    <table border=\"0\" style=\"margin-top: 20px;\" >    <tr align=\"center\">     <td colspan=\"2\" align=\"center\">      <span class=\"no_thanks\" style=\"cursor: pointer; align:center; margin-left:17px;\"><img src=\"https://www.azigo.com/sales-demo/NoThanksButton.png\"><\/span>     <\/td>    <\/tr>    <\/table>        <\/div>                            <div id=\"screenTwo\" style=\"display:none;\">    <table>    <tr style=\"margin-top: 30px;\">     <td><span style=\"color: #72BDCA; font-weight:bold\">Two ways to buy!<\/span><\/td>     <td><img src=\"https://www.azigo.com/sales-demo/chase_logo_image.jpg\" width=\"70px\"><\/td>      <\/tr>    <\/table><br/>    <div style=\"align: center; \">    <img src=\"https://www.azigo.com/sales-demo/chasecart.jpg\" width=\"100px\"><br/>    <span style=\"font-weight:bold;margin-top:3px;\">Use your Chase points!<\/span><br/>      <div class=\"info\" style=\"margin: 20px;\">        Balance: 150,351<br/>        Needed: 7,200<br/>      <\/div>    <span style=\"cursor: pointer; margin-left:-5px;\"><img src=\"https://www.azigo.com/sales-demo/UsePointsButton.png\" onclick=\"fill_card('miles');\" width=\"200px\"><br/>    <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/GoBackButton.png\" onclick=\"noThanks();\">    <\/div>    <\/div>                            <div id=\"screenThree\" style=\"display:none;\">    <table>    <tr style=\"margin-top: 30px;\">     <td><span style=\"color: #72BDCA; font-weight:bold\">Don't forget...<\/span><\/td>     <td><img src=\"https://www.azigo.com/sales-demo/chase_logo_image.jpg\" width=\"80px\"><\/td>      <\/tr>    <\/table><br/>    <div style=\"align: center; margin-top:20px;\">    <span style=\"font-weight:bold;\">Use your SkyMiles AMEX card now and earn even more miles!<\/span><br/>    <div style=\"margin-top: 20px;\">    <img src=\"https://www.azigo.com/sales-demo/carousel_sapphire_card.jpg\" width=\"160px\">    <\/div>    <br/>    <span style=\"font-weight:bold;\">Want to use your SkyMiles AMEX?<\/span><br/>    <div style=\"margin-top: 30px;\">    <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/LetsUseItButton.png\" onclick=\"fill_card('card');\" width=\"200px\"><br/>    <span style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/NoThanksButton.png\" onclick=\"noThanks();\">    <\/div>    <\/div>    <\/div>            <div id=\"wellDone1\" style=\"display:none; margin:15px; font-weight:bold; align: center;\">      Thank you, Jack. You've just saved $72.00 with Chase Sapphire Card.<br/><br/><br/>      Your confirmation number is <span style=\"color:red\">GP965J23<\/span>.<br/><br/><br/>     <span class=\"no_thanks\" style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/CloseButton.png\">    <\/div>        <div id=\"wellDone2\" style=\"display:none; margin:15px; font-weight:bold; align: center;\">      Thank you, Jack. You've just earned 7,200 Chase Points.<br/><br/><br/>      Your confirmation number is <span style=\"color:red\">GP592J23<\/span>.<br/><br/><br/>    <span class=\"no_thanks\" style=\"cursor: pointer;\"><img src=\"https://www.azigo.com/sales-demo/CloseButton.png\">    <\/div>            <\/p>    <\/div>       \n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a58x2"
}
