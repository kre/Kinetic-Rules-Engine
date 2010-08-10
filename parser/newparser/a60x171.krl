{
   "dispatch": [{"domain": "entity.dnb.com"}],
   "global": [],
   "meta": {
      "author": "Mike Grace",
      "keys": {"errorstack": "70ed00b78d263e253536c8f329ca433f "},
      "logging": "on",
      "name": "d&b investigate"
   },
   "rules": [
      {
         "actions": [{"emit": "\n$K(\"head\").append(errorScript).append(catchAll);\n    $K(\"head\").append(tracking);\n              "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "error_setup",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https:\\/\\/www.entity.dnb.com\\/EntityInvestigate\\/search\\/databases|https://www.entity.dnb.com:8443/EntityInvestigate",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "errorScript",
               "rhs": " \n<script type=\"text/javascript\">\n    \terrorStack = function(msg,url,l){\n    \t\tvar txt=\"_s=70ed00b78d263e253536c8f329ca433f&_r=img\";\n    \t\ttxt+=\"&Msg=\"+escape(msg);\n    \t\ttxt+=\"&URL=\"+escape(url);\n    \t\ttxt+=\"&Line=\"+l;\n    \t\ttxt+=\"&Platform=\"+escape(navigator.platform);\n    \t\ttxt+=\"&UserAgent=\"+escape(navigator.userAgent);\n    \t\tvar i = document.createElement(\"img\");\n    \t\ti.setAttribute(\"src\", ((\"https:\" == document.location.protocol) ? \"https://errorstack.appspot.com\" : \"http://www.errorstack.com\") + \"/submit?\" + txt);\n    \t\tdocument.body.appendChild(i);\n    \t}\n    <\/script>\n  \n ",
               "type": "here_doc"
            },
            {
               "lhs": "catchAll",
               "rhs": " \n<script type=\"text/javascript\">\n      window.onerror = function(msg,url,l) {\n       errorStack(msg,url,l);\n       //return true;\n      }\n    <\/script>\n  \n ",
               "type": "here_doc"
            },
            {
               "lhs": "tracking",
               "rhs": " \n<script type=\"text/javascript\">\n  \t\tclickReport = function(msg,url,l){\n  \t\t\tvar txt=\"_s=62de9d5c8aec60ce7e8822ff79279633&_r=img\";\n  \t\t\ttxt+=\"&Msg=\"+escape(msg);\n  \t\t\ttxt+=\"&URL=\"+escape(url);\n  \t\t\ttxt+=\"&Line=\"+l;\n  \t\t\ttxt+=\"&Platform=\"+escape(navigator.platform);\n  \t\t\ttxt+=\"&UserAgent=\"+escape(navigator.userAgent);\n  \t\t\tvar i = document.createElement(\"img\");\n  \t\t\ti.setAttribute(\"src\", ((\"https:\" == document.location.protocol) ? \n  \t\t\t\t\"https://errorstack.appspot.com\" : \"http://www.errorstack.com\") + \"/submit?\" + txt);\n  \t\t\tdocument.body.appendChild(i);\n  \t\t}\n\t\t<\/script>\n  \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [
            {"emit": "\nwindow.generate_single_line = function(name,value)\n{ \n\tif(value != null && value != '')\n\t{\n\t\treturn \"<div class='single_line'>\" +\n\t\t\t\t\t\"<div class='line_name' style='width:25%;'>\" + \n\t\t\t\t\t\tname + \n\t\t\t\t\t\"<\/div>\" +\n\t\t\t\t\t\"<div class='line_value'>\" + value + \"<\/div>\" + \n\t\t\t\t\"<\/div>\" +\n\t\t\t\t\"<div style='clear:both;'> <\/div>\";\n\t}\n\telse\n\t{\n\t\treturn \"\";\n\t}\n\t\n};\n\nwindow.convert_to_array_hash = function(array_entry)\n{\n\tvar result = {};\n\tfor(var i = 0;i< array_entry.length;i++)\n\t{\n\t\t$KOBJ.extend(result,array_entry[i]);\n\t}\n\treturn result;\n};\n\nwindow.isblank = function(data)\n{\n\tif(data != null && data != '')\n\t\treturn false;\n\telse\n\t\treturn true;\n};\nwindow.format_money = function (amount)\n{\n\tif(isblank(amount))\n\t\treturn null;\n\telse\n\t{\n\n var num = amount;\nnum = num.toString().replace(/\\$|\\,/g,'');\nif(isNaN(num))\nnum = \"0\";\nsign = (num == (num = Math.abs(num)));\nnum = Math.floor(num*100+0.50000000001);\ncents = num%100;\nnum = Math.floor(num/100).toString();\nif(cents<10)\ncents = \"0\" + cents;\nfor (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)\nnum = num.substring(0,num.length-(4*i+3))+','+\nnum.substring(num.length-(4*i+3));\nreturn (((sign)?'':'-') + '$' + num + '.' + cents);\n\n\t}\n};\n\nwindow.format_phone = function(phone)\n{\n\tif(isblank(phone))\n\t\treturn null;\n\telse\n\t{\n\t\tvar matcher = /([0-9][0-9][0-9])([0-9][0-9][0-9])([0-9][0-9][0-9][0-9])/;\n\t\tvar data = matcher.exec(phone);\n\t\treturn \"(\" + data[1] + \") \" + data[2] + \"-\"  + data[3];\n\t}\n\n};\nwindow.format_blocked_date = function(date)\n{\n\tif(isblank(date))\n\t\treturn null;\n\telse\n\t{\n\t\tvar matcher = /([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])/;\n\t\tvar data = matcher.exec(date);\n\t\treturn data[2] + \"/xx/\"  + data[1];\n\t}\n\n};\n\nwindow.format_ssn =  function(ssn)\n{\n\tif(isblank(ssn))\n\t\treturn null;\n\telse\n\t{\n\t\tvar tempssn = \"\"+ ssn;\n\t\treturn tempssn.substring(0,4) +\"XXXX\";\n\t}\n\n};\n\nwindow.format_date = function(date)\n{\n\tif(isblank(date))\n\t\treturn null;\n\telse\n\t{\n\t\tvar matcher = /([0-9][0-9][0-9][0-9])([0-9][0-9])([0-9][0-9])/;\n\t\tvar data = matcher.exec(date);\n\t\treturn data[2] + \"/\" +  data[3]  +\"/\"  + data[1];\n\t}\n\n};\nwindow.format_small_address = function(address)\n{\n\tif(isblank(address))\n\t\treturn null;\n\telse\n\t{\n\t\tvar result = \"\";\n\t\tif(!isblank(address.addressLine))\n\t\t\tresult = result +  address.addressLine + \"<br>\";\n\t\t\t\n\t\tif(!isblank(address.city))\n\t\t\tresult = result +  address.city + \", \";\n\t\t\t\n\t\tif(!isblank(address.state))\n\t\t\tresult = result +  address.state + \" \";\n\t\t\t\n\t\tif(!isblank(address.zip))\n\t\t\tresult = result +  address.zip ;\n\t\t\t\n\t\treturn result;\n\t}\n\n};\nwindow.format_full_address = function(address)\n{\n\tif(isblank(address))\n\t\treturn null;\n\telse\n\t{\n\t\tvar result = \"\";\n\t\tif(!isblank(address.addressLine))\n\t\t\tresult = result +  address.addressLine + \"<br>\";\n\t\tif(!isblank(address.poBox))\n\t\t\tresult = result +  address.poBox + \"<br>\";\n\t\t\t\n\t\tif(!isblank(address.city))\n\t\t\tresult = result +  address.city + \", \";\n\t\t\t\n\t\tif(!isblank(address.state))\n\t\t\tresult = result +  address.state + \" \";\n\t\t\t\n\t\tif(!isblank(address.zip))\n\t\t\tresult = result +  address.zip ;\n\n\t\tif(!isblank(address.unitNumber))\n\t\t\tresult = result +  \"<br>Ste #\" + address.unitNumber ;\n\t\t\t\n\t\treturn result;\n\t}\n\n};\n\nwindow.generate_header  = function(name, value)\n{\n\treturn \"<h2 class='header'>\" + name + \":\" + value + \"<\/h2>\";\n};\n\nwindow.start_wrapper = function(name)\n{\n\treturn \"<div class='wrapper'><div><b>\" + name + \"<\/b><\/div>\";\n};\n\nwindow.end_wrapper = function ()\n{\n\treturn \"<\/div>\";\n};\n\nwindow.full_wrap_start = function()\n{\n\treturn \"<div class='full_wrapper'>\";\n};\n\nwindow.full_wrap_end = function()\n{\n\treturn \"<\/div>\";\n};\n                "},
            {"emit": "\n$K(\"div#main\").append(setup);\n    $K(\"form#db\").append(ajaxLoader);\n    $K(\"head\").append(pageVariables);\n    $K(\"form#db\").append(buttons);\n    \n\nfunction parse_the_data_set_vars_for_crim()\n{\n    var name = null;\n    name = $K(\"table#foo tr:eq(1) td:eq(0) span\").text().split(/\\s/);\n    if(name.length != 1)\n    {\n      name = $K(\"table#foo tr:eq(1) td:eq(0) span:eq(0)\").text().split(/\\s/);\n    }\n      \n    var address = $K(\"table#foo tr:eq(1) td:eq(2)\").text();\n    var addressParts = /,\\s*([A-Z]{2})?\\s*([0-9]*)?/.exec($K(\"table#foo tr:eq(1) td:eq(2)\").text());\n    var streetAddressElement = $K(\"table#foo tr:eq(1) td:eq(2)\").html();\n    var streetAddressParts = streetAddressElement.split(\"<BR>\");\n    var streetAddress = streetAddressParts[0];\n    var tempdata = $K(\"table#foo tr:eq(1) td:eq(0) \").text().split(/\\s/);\n    for(i=0; i<tempdata.length; i++) {\n      if(/[0-9]{6}XX/.test(tempdata[i])) {\n        var birthdate = /([0-9]{4})([0-9]{2})XX/.exec(tempdata[i]);\n        kvars.birthdate = birthdate[1]+birthdate[2];\n        kvars.birthmonth = birthdate[2];\n        kvars.birthyear = birthdate[1];\n      }\n    }\n    \n    if(name.length == 1) {\n      kvars.firstname = name;\n      kvars.lastname = \"\";\n      errorStack(\"No name found\",window.location.href,1000);\n    } else if(name.length == 2) {\n      kvars.firstname = name[0];\n      kvars.lastname = name[1];\n    } else if(name.length == 3) {\n      kvars.firstname = name[0];\n      kvars.lastname = name[2];\n    } else {\n      errorStack(\"-\",window.location.href,1000);\n    }\n    \n    if(addressParts.length == 3) {\n      kvars.state = addressParts[1];\n      kvars.zip = addressParts[2];\n    } else {\n      var title = document.title;\n      errorStack(\"Unexpected address: \" + addressParts + \" ## Page title: \" + title, window.location.href, 1010);\n    }\n    \n    if( streetAddress.length ) {\n      kvars.streetAddress = streetAddress;\n    } else {\n      kvars.streetAddress = \"\";\n      errorStack(\"Street Address Error! Street address element: \" + streetAddressElement, window.location.href, 1021345);\n    }\n\n\n\n}\n\n    \n    financialSearched = false;\n    criminalSearched = false;\n\n    $K(\"#kynetx-search-buttons img.criminal\").click(function() {\n      if(!criminalSearched) {\n        $K(\"#ajax-loader\").show();\n\n\t$K(\"#kynetx-criminal\").show();\n\tkvars = {};\n\n\t parse_the_data_set_vars_for_crim();\n\n    if(KOBJ.get_application(\"a60x174\"))\n      {\n\tKOBJ.get_application(\"a60x174\").reload();\n      }\n      else\n      {\n      KOBJ.add_app_config({'rids':['a60x174']});\n      var mypp = KOBJ.get_application(\"a60x174\");\n      mypp.reload();\n      }\n\n        criminalSearched = true;\n      } else {\n        $K(\"#kynetx-criminal\").slideToggle();\n      }\n    });\n    \n                  "},
            {"emit": "\nclickit = function(index,address, city, state,zip) {\n   kvars = {};\n\n    parse_the_data_set_vars_for_crim();\n    var full_name = $K(\"table#foo tr td span\").html();\n    var name = full_name.split(\" \");\n\n    if(name.length == 1) {\n      kvars.firstname = name;\n      kvars.lastname = \"\";\n    } else if(name.length == 2) {\n      kvars.firstname = name[0];\n      kvars.lastname = name[1];\n    } else if(name.length == 3) {\n      kvars.firstname = name[0];\n      kvars.lastname = name[2];\n    }\n\n      kvars.state = state;\n      kvars.zip = zip;\n      kvars.city = city;\n\n      kvars.search_button = \"#searchbutton\" + index;     \n\n      kvars.streetAddress = address;\n     $K(\"#kynetx-financial\").show();\n\n     $K(\".SEARCHFIN\").hide();\n\t$K(\"#searchbutton\" + index).html(\"<img src='https:\\/\\/kynetx-apps.s3.amazonaws.com/dnb-investigate/ajax-loader.gif' />\");\n$K(\"#searchbutton\"+index).show();\n\n      if(KOBJ.get_application(\"a60x181\"))\n      {\n\tKOBJ.get_application(\"a60x181\").reload();\n      }\n      else\n      {\t\t\t \n   KOBJ.add_app_config({'rids':['a60x181']});\n        var mypp = KOBJ.get_application(\"a60x181\");\n        mypp.reload();\n      }\n\n}; \n\ndata = $K(\"body div.outerDiv div#main div.widget_form table#foo.widget tbody tr.RowWhite td.leftAlign img\");\n\nif(data.length == 0)\n{\n  data = $K(\"body div.outerDiv div#main div.widgetForm table#foo.widget tbody tr.RowWhite td.leftAlign img\");\n}\ndata.each(function(index) { \n\tvar the_address_element = $K(this).parent().next() ;\n\n\n\tvar address = $K(the_address_element).contents()[0].data;\n\n\tvar city_state_zip = $K(the_address_element).contents()[2].data;\n\tvar city_name = city_state_zip.split(\",\")[0];\n\n\tvar matcher = /[A-Z][A-Z][A-Z]*/;\n\tvar state_name =matcher.exec(city_state_zip.split(\",\")[1])[0];\n\tvar matcher = /[0-9]+/;\n\tvar zipcode =matcher.exec(city_state_zip.split(\",\")[1])[0];\n\n        var temp_click = \"<a href='#' class='SEARCHFIN' id='searchbutton\" + index + \"'>Bankruptcy/Judgment/Lien \";\n\t\n\tthe_address_element.append(temp_click + \"<img src='https:\\/\\/kynetx-apps.s3.amazonaws.com/dnb-investigate/search.png'/><\/a>\");\n\n\n        $K(\"#searchbutton\" + index).click(function() {\n\t\tclickit(index,address,city_name ,state_name,zipcode);\n\t\treturn false;\t\t\n \t });\n\n});\n                "}
         ],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "set_up",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https:\\/\\/www.entity.dnb.com\\/EntityInvestigate\\/search\\/databases|https://www.entity.dnb.com:8443/EntityInvestigate",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "pageVariables",
               "rhs": " \n<script type=\"text/javascript\">\n     var kvars = {};\n   <\/script>\n  \n ",
               "type": "here_doc"
            },
            {
               "lhs": "ajaxLoader",
               "rhs": " \n<style>\n      #ajax-loader {\n        position:absolute;\n        right:235px;\n        top:133px;\n        display: none;\n      }\n      \n      form#db {\n        position: relative;\n      }\n\n      #kynetx-search-buttons {\n        position:absolute;\n        right:80px;\n        top:10px;\n        width:200px;\n      }\n\n      #kynetx-financial, #kynetx-criminal {\n       \n      }\n\n      #kynetx-financial h1, #kynetx-criminal h1 {\n        border-bottom:1px solid #FFC500;\n        font-size:23px;\n        width:927px;\n      }\n      \n    <\/style>\n\n<style>\n\n.full_wrapper {\n    background-color:#D0DAFD;\n        color:#004397;\n        font-size:12px;\n        padding:3px;\n        border: 2px solid;\n        padding-bottom: 20px;\n\tmargin-bottom: 20px;\n}\n.header {\n\tborder:2px solid #FFC500;\n    font-size:16px;\n    background-color:#E7ECFF;\n    padding:5px;        \n}\n\n.wrapper {\n\tpadding-left: 20px;\n\tpadding-bottom: 5px;\n\twidth: 95%;\n\tcolor:black;\n}\n\n.single_line {\n\tpadding-left: 20px;\n\twidth: 95%;\n}\n\n.line_name {\n\tfloat : left;\t\n\tmargin-bottom: 3px;\n}\n\n.line_value {\n\tfloat:left;\n}\n\n\n<\/style>\n\n    <img id=\"ajax-loader\" src=\"https://kynetx-apps.s3.amazonaws.com/dnb-investigate/ajax-loader.gif\" />\n  \n ",
               "type": "here_doc"
            },
            {
               "lhs": "setup",
               "rhs": " \n<div id=\"kynetx-search-results\">\n      <div id=\"kynetx-financial\" style=\"display:none;\">\n        <h1>Bankruptcy/Judgment/Lien<\/h1>\n        \n      <\/div>\n      <div id=\"kynetx-criminal\"  style=\"display:none;\">\n        <h1>Criminal / Infraction<\/h1>\n        \n      <\/div>\n    <\/div>\n    \n\n    <style type=\"text/css\">\n      #ajax-loader {\n        display: none;\n      }\n      .offender-identity {\n        margin-left: 20px;\n      }\n      \n      .offense-count img {\n        margin-left: -20px;\n      }\n      \n      .offenses-wrapper {\n        margin-left: 20px;\n        \n      }\n      \n      #offender-stamp, #offense-stamp {\n        display: none;\n      }\n      \n      .offender > h2, .transaction > h2 {\n        background-color:#D0DAFD;\n        border-bottom:1px solid #004397;\n        color:#004397;\n        font-size:14px;\n        padding:5px;\n      }\n      \n      .offender, .transaction {\n        background-color:#E7ECFF;\n        padding-bottom:5px;\n      }\n      \n      /* FINANCIAL */\n      #financial-stamp {\n\n      }\n      \n      .type-meta, .defendant-meta-wrapper {\n        margin-left: 20px;\n        \n      }\n      \n      #kynetx-financial h2.l {\n        margin-left: -17px;\n      }\n      \n      .transaction > p, .transaction > div {\n        margin-left: 20px;\n      }\n      \n      p.type.l {\n        margin-left: 3px !important;\n      }\n      \n      .defendant-meta {\n        margin-left: 3px !important;\n      }\n      \n      .type-meta p, .defendant-meta-wrapper p {\n        margin-left: 20px;\n      }\n      \n    <\/style>\n  \n ",
               "type": "here_doc"
            },
            {
               "lhs": "buttons",
               "rhs": " \n<div id=\"kynetx-search-buttons\">\n<!--      <p>Bankruptcy/Judgment/Lien<\/p>\n      <img class=\"financial\" src=\"https://kynetx-apps.s3.amazonaws.com/dnb-investigate/search.png\"/>\n-->\n      <p>Criminal / Infraction<\/p>\n      <img class=\"criminal\" src=\"https://kynetx-apps.s3.amazonaws.com/dnb-investigate/search.png\"/>\n    <\/div>\n  \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      }
   ],
   "ruleset_name": "a60x171"
}
