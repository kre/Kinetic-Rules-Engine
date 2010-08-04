{
   "dispatch": [
      {"domain": "zappos.com"},
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "shoes.com"},
      {"domain": "secure.shoes.com"},
      {"domain": "expedia.com"},
      {"domain": "travelocity.com"}
   ],
   "global": [
      {
         "cachable": 1,
         "datatype": "JSON",
         "name": "ksearch",
         "source": "http://qa.ahika.com/page/jSample.html?req=3",
         "type": "dataset"
      },
      {"emit": "\nfunction kNotifyDup(config, header, msg) {    \t        uniq = (Math.round(Math.random()*100000000)%100000000);    \t\t$K.kGrowl.defaults.header = header;    \t\tif(typeof config === 'object') {    \t\t\tjQuery.extend($K.kGrowl.defaults,config);    \t\t}    \t\t$K.kGrowl(msg);    \t\t\t    \t}                            "}
   ],
   "meta": {
      "logging": "off",
      "name": "BankOfAmerica"
   },
   "rules": [
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "top-right"
                  },
                  {
                     "type": "str",
                     "val": "#FFF"
                  },
                  {
                     "type": "str",
                     "val": "#000"
                  },
                  {
                     "type": "str",
                     "val": "Save money on shoes!"
                  },
                  {
                     "type": "bool",
                     "val": "true"
                  },
                  {
                     "type": "var",
                     "val": "invite"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"emit": "\n$K(\"span.no_thanks\").bind(\"click.kGrowl\", function() {       $K(this).unbind('click.kGrowl').parent().parent().parent().parent().trigger('kGrowl.beforeClose').animate({opacity: \t'hide'}, \"normal\", \"swing\", function() {  \t\t\t\t\t$K(this).trigger('kGrowl.close').remove();  \t\t\t\t\t});});                  "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.fill_card = function() {   $K('input[name=ccard_z_number]').attr('value','372155554444432');   $K('select[name=ccard_z_exp_month]>option[value=02]').attr('selected','selected');   $K('select[name=ccard_z_exp_year]>option[value=2011]').attr('selected','selected');  $K('select[name=ccard_type]>option[value=amex]').attr('selected','selected');  $K(\"div.kGrowl\").trigger(\"kGrowl.close\").remove();    };    $K.kGrowl.defaults.opacity = 1.0;  $K.kGrowl.defaults.width = \"250px\";            ",
         "foreach": [],
         "name": "zapposnotify",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://shopping.zappos.com/(r|reqauth)/checkout.cgi",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #cf9414;    width: 240px;    text-align: center\">  <p style=\"color: #fff\" >  Use your American Express card and save 5% off your entire purchase  <\/p>  <p style=\"color: #000; background-color: #fff; margin:0;padding:0;\">  <img width=\"218px\" src=\"http://img8.imageshack.us/img8/5348/cardri.gif\">  <\/p>  <p style=\"color: #fff; text-align: center\">  Offer Expires 07/20/09  <\/p>  <p style=\"color: #fff; text-align: center; margin: 0; padding: 0;\">  <a href=\"http://offers.amexnetwork.com/selects/us/grid?categoryPath=/amexnetwork/category/Shopping&issuerName=us_prop\" target=\"_blank\" style=\"color: #fff\">Click here to learn more<\/a>  <\/p>  <p style=\"color: #000\">  <img style=\"cursor: pointer;\" href=\"http://www.travelocity.com\" style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/button.png\" width=\"100px\">  <span class=\"no_thanks\" style=\"cursor: pointer; \"><img  style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/red_button.png\" width=\"100px\"><\/span>  <\/p>  <\/div>     \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "search_selector"
            }],
            "modifiers": null,
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction search_selector(obj){    function mk_anchor (o, key) {      var link_text = {        \"ksearch\": \"<img style='padding-top: 5px' src='http://img8.imageshack.us/img8/6153/amexlogo.jpg' border='0'>\"      };      return $K('<a href=' + o.link + '/>').attr(        {\"class\": 'KOBJ_'+key,         \"title\": o.text || \"Click here for discounts!\"        }).html(link_text[key]);    }      var host = KOBJ.get_host($K(obj).find(\"span.url, cite, span.a\").text());    var o = KOBJ.pick(KOBJ['data']['ksearch'][host]);    if(o) {       return mk_anchor(o,'ksearch');    } else {      false;    }  }            ",
         "foreach": [],
         "name": "search",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.google.com|search.yahoo.com|www.bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "top-right"
                  },
                  {
                     "type": "str",
                     "val": "#FFF"
                  },
                  {
                     "type": "str",
                     "val": "#000"
                  },
                  {
                     "type": "str",
                     "val": "Save money on shoes!"
                  },
                  {
                     "type": "bool",
                     "val": "true"
                  },
                  {
                     "type": "var",
                     "val": "invite"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"emit": "\n$K(\"span.no_thanks\").bind(\"click.kGrowl\", function() {       $K(this).unbind('click.kGrowl').parent().parent().parent().parent().trigger('kGrowl.beforeClose').animate({opacity: \t'hide'}, \"normal\", \"swing\", function() {  \t\t\t\t\t$K(this).trigger('kGrowl.close').remove();  \t\t\t\t\t});});                  "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.fill_card = function() {    \t$K('input[name=ctl00$cphPageMain$AddressSelector$FirstName]').val('John');  \t$K(\"#ctl00_cphPageMain_AddressSelector_LastName\").val('Doe');  \t$K(\"#ctl00_cphPageMain_AddressSelector_txtAddressLine1\").val(\"123 Fake Street\");  \t$K(\"#ctl00_cphPageMain_AddressSelector_txtCity\").val(\"New York\");  \t$K(\"#ctl00_cphPageMain_AddressSelector_ucState_ddlListItems\").val(\"NY\");  \t$K(\"#ctl00_cphPageMain_AddressSelector_txtZip\").val(\"10001\");  \t$K(\"#ctl00_cphPageMain_AddressSelector_txtDayTimePhone\").val(\"5558675309\");  \t$K('input[name=ctl00$cphPageMain$PaymentTypeSelector$CreditCardNumber]').attr('value','372155554444432');  \t$K('input[name=ctl00$cphPageMain$PromoCodeAndGiftCodeUC$Code]').attr('value','SUMMER');  \t$K('input[name=ctl00$cphPageMain$PromoCodeAndGiftCodeUC$SubmitButton]').click();  \t$K('select[name=ctl00$cphPageMain$PaymentTypeSelector$ExpiryMonth]>option[value=2]').attr('selected','selected');  \t$K('select[name=ctl00$cphPageMain$PaymentTypeSelector$ExpiryYear]>option[value=2011]').attr('selected','selected');  \t$K('input[name=ctl00$cphPageMain$PaymentTypeSelector$PaymentMethods]').val('RadioButton_New_Amex');  \t$K('input[id=ctl00_cphPageMain_PaymentTypeSelector_RadioButton_New_Amex]').attr('checked','checked');  \t$K(\"div.kGrowl\").trigger(\"kGrowl.close\").remove();    };    $K.kGrowl.defaults.opacity = 1.0;  $K.kGrowl.defaults.width = \"250px\";            ",
         "foreach": [],
         "name": "shoes",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://secure.shoes.com/Checkout2/BillingInfo.aspx",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #cf9414;    width: 240px;    text-align: center\">  <p style=\"color: #fff\" >  Use your American Express card and save 20% off your entire purchase with Free shipping and Free returns  <\/p>  <p style=\"color: #000; background-color: #fff; margin:0;padding:0;\">  <img width=\"218px\" src=\"http://img8.imageshack.us/img8/5348/cardri.gif\">  <\/p>  <p style=\"color: #fff; text-align: center\">  Offer Expires 12/31/09  <\/p>  <p style=\"color: #fff; text-align: center; margin: 0; padding: 0;\">  <a href=\"http://offers.amexnetwork.com/portal/site/selects/menuitem.5e69a2019665ca81e0ba4d10101000f7/?vgnextoid=3fe92f824aa8f110VgnVCM1000001445640aRCRD&localLocale=en-us&categoryPath=%2Famexnetwork%2Fcategory%2FShopping&localCountryId=ccfb43b68d898110VgnVCM2000007cc6410aRCRD&countryId=ccfb43b68d898110VgnVCM2000007cc6410aRCRD&issuerName=us_prop\" target=\"_blank\" style=\"color: #fff\">Click here to learn more<\/a>  <\/p>  <p style=\"color: #000\">  <img style=\"cursor: pointer;\" href=\"http://www.travelocity.com\" style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/button.png\" width=\"100px\" onclick=\"KOBJ.fill_card()\">  <span class=\"no_thanks\" style=\"cursor: pointer; \"><img  style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/red_button.png\" width=\"100px\"><\/span>  <\/p>  <\/div>     \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "top-right"
                  },
                  {
                     "type": "str",
                     "val": "#FFF"
                  },
                  {
                     "type": "str",
                     "val": "#000"
                  },
                  {
                     "type": "str",
                     "val": "Save money!"
                  },
                  {
                     "type": "bool",
                     "val": "true"
                  },
                  {
                     "type": "var",
                     "val": "invite"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"emit": "\n$K(\"span.no_thanks\").bind(\"click.kGrowl\", function() {       $K(this).unbind('click.kGrowl').parent().parent().parent().parent().trigger('kGrowl.beforeClose').animate({opacity: \t'hide'}, \"normal\", \"swing\", function() {  \t\t\t\t\t$K(this).trigger('kGrowl.close').remove();  \t\t\t\t\t});});                  "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.fill_card = function() {    $K(\"div.kGrowl\").trigger(\"kGrowl.close\").remove();    };    $K.kGrowl.defaults.opacity = 1.0;  $K.kGrowl.defaults.width = \"250px\";            ",
         "foreach": [],
         "name": "expedia",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "expedia.com/$",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #cf9414;    width: 240px;    text-align: center\">  <p style=\"color: #fff\" >  Expedia gives no deals to American Express card holders. Would you like to go to Travelocity which does?  <\/p>  <p style=\"color: #000; background-color: #fff; margin:0;padding:0;\">  <img width=\"218px\" src=\"http://img8.imageshack.us/img8/5348/cardri.gif\">  <\/p>  <p style=\"color: #000\">  <a href=\"http://www.travelocity.com\"><img style=\"cursor: pointer;\" style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/button.png\" width=\"100px\"><\/a>  <span class=\"no_thanks\" style=\"cursor: pointer; \"><img  style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/red_button.png\" width=\"100px\"><\/span>  <\/p>  <\/div>       \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "top-right"
                  },
                  {
                     "type": "str",
                     "val": "#FFF"
                  },
                  {
                     "type": "str",
                     "val": "#000"
                  },
                  {
                     "type": "str",
                     "val": "Frequent Flier?"
                  },
                  {
                     "type": "bool",
                     "val": "true"
                  },
                  {
                     "type": "var",
                     "val": "invite"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"emit": "\n$K(\"span.no_thanks\").bind(\"click.kGrowl\", function() {       $K(this).unbind('click.kGrowl').parent().parent().parent().parent().trigger('kGrowl.beforeClose').animate({opacity: \t'hide'}, \"normal\", \"swing\", function() {  \t\t\t\t\t$K(this).trigger('kGrowl.close').remove();  \t\t\t\t\t});});                  "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.fill_card = function() {    $K(\"input[value=optional]\").val(\"1984927138724\");  $K(\"div.kGrowl\").trigger(\"kGrowl.close\").remove();    };    $K.kGrowl.defaults.opacity = 1.0;  $K.kGrowl.defaults.width = \"250px\";            ",
         "foreach": [],
         "name": "travelocity",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://travel.travelocity.com/checkout/PostReview.do",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #cf9414;    width: 240px;    text-align: center\">  <p style=\"color: #fff\" >  Pay with a AMX card and get double frequent flier miles!  <\/p>  <p style=\"color: #000; background-color: #fff; margin:0;padding:0;\">  <img width=\"218px\" src=\"http://img8.imageshack.us/img8/5348/cardri.gif\">  <\/p>  <p style=\"color: #000\">  <img border=\"none\" style=\"cursor: pointer;\" style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/button.png\" width=\"100px\" onclick=\"KOBJ.fill_card();\">  <span class=\"no_thanks\" style=\"cursor: pointer; \"><img  style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/red_button.png\" width=\"100px\"><\/span>  <\/p>  <\/div>       \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "top-right"
                  },
                  {
                     "type": "str",
                     "val": "#FFF"
                  },
                  {
                     "type": "str",
                     "val": "#000"
                  },
                  {
                     "type": "str",
                     "val": "Use AMX"
                  },
                  {
                     "type": "bool",
                     "val": "true"
                  },
                  {
                     "type": "var",
                     "val": "invite"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"emit": "\n$K(\"span.no_thanks\").bind(\"click.kGrowl\", function() {       $K(this).unbind('click.kGrowl').parent().parent().parent().parent().trigger('kGrowl.beforeClose').animate({opacity: \t'hide'}, \"normal\", \"swing\", function() {  \t\t\t\t\t$K(this).trigger('kGrowl.close').remove();  \t\t\t\t\t});});                      "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [
               {
                  "args": [{
                     "type": "str",
                     "val": "title"
                  }],
                  "predicate": "env",
                  "source": "page",
                  "type": "qualified"
               },
               {
                  "type": "str",
                  "val": "CheckoutBilling"
               }
            ],
            "op": "eq",
            "type": "ineq"
         },
         "emit": "\nKOBJ.fill_card = function() {  \t  \t$K(\"input[name=paymentMethodNumber]\").val(\"0000111144443333\");  \t$K(\"#otherCCV\").val(\"123\");  \t$K(\"div.kGrowl\").trigger(\"kGrowl.close\").remove();    };    $K.kGrowl.defaults.opacity = 1.0;  $K.kGrowl.defaults.width = \"250px\";            ",
         "foreach": [],
         "name": "travelocity_checkout",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://travel.travelocity.com/checkout/PostDisplaySeatMaps.do",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "pageTitle",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "title"
                  }],
                  "predicate": "env",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "invite",
               "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;  \t  -moz-border-radius: 5px;  \t  -webkit-border-radius: 5px;  \t  background-color: #cf9414;  \t  width: 240px;  \t  text-align: center\">  \t<p style=\"color: #fff\" >  \tPay with your American Express card and get double Frequent Flier miles! Would you like to purchase your tickets with American Express?  \t<\/p>  \t<p style=\"color: #000; background-color: #fff; margin:0;padding:0;\">  \t<img width=\"218px\" src=\"http://img8.imageshack.us/img8/5348/cardri.gif\">  \t<\/p>  \t<p style=\"color: #000\">  \t<img border=\"none\" style=\"cursor: pointer;\" style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/button.png\" width=\"100px\" onclick=\"KOBJ.fill_card();\">  \t<span class=\"no_thanks\" style=\"cursor: pointer; \"><img  style=\"opacity: 1.0;\" src=\"http://caandb.com/kynetx/red_button.png\" width=\"100px\"><\/span>  \t<\/p>  \t<\/div>  \t  \t   \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [
            {"action": {
               "args": [
                  {
                     "type": "str",
                     "val": "top-right"
                  },
                  {
                     "type": "str",
                     "val": "#FFF"
                  },
                  {
                     "type": "str",
                     "val": "#000"
                  },
                  {
                     "type": "str",
                     "val": "Thanks for coming!"
                  },
                  {
                     "type": "bool",
                     "val": "true"
                  },
                  {
                     "type": "var",
                     "val": "invite"
                  }
               ],
               "modifiers": null,
               "name": "notify",
               "source": null
            }},
            {"emit": "\nreferred = true;      $K(\"span.no_thanks\").bind(\"click.kGrowl\", function() {      $K(this).unbind('click.kGrowl').parent().parent().parent().parent().trigger('kGrowl.beforeClose').animate({opacity: \t'hide'}, \"normal\", \"swing\", function() {  \t\t\t\t\t$K(this).trigger('kGrowl.close').remove();  \t\t\t\t\t});});                        "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [
               {
                  "args": [{
                     "type": "str",
                     "val": "referer"
                  }],
                  "predicate": "env",
                  "source": "page",
                  "type": "qualified"
               },
               {
                  "type": "str",
                  "val": "http://www.expedia.com/"
               }
            ],
            "op": "eq",
            "type": "ineq"
         },
         "emit": "\nreferred = false;    $K.kGrowl.defaults.opacity = 1.0;  $K.kGrowl.defaults.width = \"250px\";            ",
         "foreach": [],
         "name": "travelocity_from_expedia",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "travelocity.com/$",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "invite",
            "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;    -moz-border-radius: 5px;    -webkit-border-radius: 5px;    background-color: #cf9414;    width: 240px;    text-align: center\">  \t<p style=\"color: #fff\" >  \t\tYou just came from Expedia! When you confirm payment details, we'll give more details.  \t<\/p>  \t<p style=\"color: #000; background-color: #fff; margin:0;padding:0;\">  \t\t<img width=\"218px\" src=\"http://img8.imageshack.us/img8/5348/cardri.gif\">  \t<\/p>  <\/div>       \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "str",
               "val": "#kobj_discount"
            }],
            "modifiers": null,
            "name": "close_notification",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif(typeof(referred) == \"undefined\") {  \treferred = false;  }    truthTest = (temp > 80 && referred != true);      $K.kGrowl.defaults.opacity = 1.0;  $K.kGrowl.defaults.width = \"250px\";    if(truthTest) {  \tconfig = $K.kGrowl.defaults;  \tkNotifyDup(config,\"It sure is hot!\",warm);  }            ",
         "foreach": [],
         "name": "travelocity_hot",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "travelocity.com/$",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "warm",
               "rhs": " \n<div id=\"kobj_discount\" style=\"padding: 3pt;  \t  -moz-border-radius: 5px;  \t  -webkit-border-radius: 5px;  \t  background-color: #cf9414;  \t  width: 240px;  \t  text-align: center\">  \t\t<p style=\"color: #fff\" >  \t\t\tWhew! It sure is hot! Why not go someplace cool like <a href=\"http://www.travelocity.com/deals-d103-canada-vacations\">Canada<\/a> and get double Frequent Flier miles!  \t\t<\/p>  \t\t<p style=\"color: #000; background-color: #fff; margin:0;padding:0;\">  \t\t\t<img id=\"AMXimg\" width=\"218px\" src=\"http://img8.imageshack.us/img8/5348/cardri.gif\">  \t\t<\/p>  \t<\/div>    \n ",
               "type": "here_doc"
            },
            {
               "lhs": "temp",
               "rhs": {
                  "args": [],
                  "predicate": "curr_temp",
                  "source": "weather",
                  "type": "qualified"
               },
               "type": "expr"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [{
               "type": "str",
               "val": "#kobj_discount"
            }],
            "modifiers": null,
            "name": "close_notification",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif(typeof(referred) == \"undefined\") {  \treferred = false;  }    truthTest = (temp < 30 && referred != true);      $K.kGrowl.defaults.opacity = 1.0;  $K.kGrowl.defaults.width = \"250px\";    if(truthTest) {  \tconfig = $K.kGrowl.defaults;  \tkNotifyDup(config,\"It sure is cold!\",cold);  }            ",
         "foreach": [],
         "name": "travelocity_cold",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "travelocity.com/$",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "cold",
            "rhs": " \ntemp = weather:curr_temp;    \t<div id=\"kobj_discount\" style=\"padding: 3pt;  \t  -moz-border-radius: 5px;  \t  -webkit-border-radius: 5px;  \t  background-color: #cf9414;  \t  width: 240px;  \t  text-align: center\">  \t\t<p style=\"color: #fff\" >  \t\t\tBrrr! It's cold! Go someplace warm, like <a href=\"http://leisure.travelocity.com/Promotions/0,,TRAVELOCITY|2045|pkg_main,00.html\">The Caribbean<\/a>, and get double Frequent Flier Miles!  \t\t<\/p>  \t\t<p style=\"color: #000; background-color: #fff; margin:0;padding:0;\">  \t\t\t<img id=\"AMXimg\" width=\"218px\" src=\"http://img8.imageshack.us/img8/5348/cardri.gif\">  \t\t<\/p>  \t<\/div>    \n ",
            "type": "here_doc"
         }],
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
         "emit": "\n$K(\"#ctl00_cphPageMain_PromoCode_Code\").val(\"CWIN10\");  \tsetTimeout(function() {  \t$K(\"#ctl00_cphPageMain_PromoCode_SubmitButton\").click();  \t},800);            ",
         "foreach": [],
         "name": "shoes_clear",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.shoes.com/Checkout/Cart.aspx",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a41x48"
}
