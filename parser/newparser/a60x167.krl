{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "search.yahoo.com"},
      {"domain": "amazon.com"}
   ],
   "global": [{
      "content": "\n      /**************\n      CROSS DOMAIN RESET\n      **************/\n      .my-amazon-search-links, .my-amazon-search-links * {\n        margin: 0;\n        padding: 0;\n        border: 0;\n        outline: 0;\n        font-size:24px;\n        font-size: 100%;\n        font-weight:normal;\n        vertical-align: baseline;\n        background: transparent;\n        color: #000;\n        font-family:arial,sans-serif;\n        direction: ltr;\n        line-height: 1;\n        letter-spacing: normal;\n        text-align: left; \n        text-decoration: none;\n        text-indent: 0;\n        text-shadow: none;\n        text-transform: none;\n        vertical-align: baseline;\n        white-space: normal;\n        word-spacing: normal;\n        font: normal normal normal medium/1 sans-serif ;\n        list-style: none;\n        clear: none;\n      }\n\n      /**************\n      MAIN CONTAINER\n      **************/\n      .my-amazon-search-links {\n        background-color: white;\n        float:right;\n        min-height:100%;\n        position:absolute;\n        right:0;\n        top:0;\n        width:300px;\n        z-index: 30000;\n      }\n\n      img.toggle {\n        position: fixed;\n        bottom: 0px;\n        right: 0px;\n        z-index: 90000;\n      }\n\n      /**************\n      PRODUCT DETAILS\n      **************/\n      .my-amazon-search-links .product {\n        -moz-border-radius:3px 3px 3px 3px;\n        border:1px solid #888888;\n        min-height:100px;\n        padding:5px;\n        clear: both;\n        position: relative;\n      }\n\n      /* product image */\n      .product-image {\n        float: left;\n      }\n\n      .product-image img {\n        max-height:100px;\n        max-width:100px;\n      }\n\n      /* product details */\n      .product-details {\n        float: left;\n        margin-left:5px;\n        max-width:180px;\n        height: 105px;\n        position: relative;\n      }\n\n      .detail-link {\n        font-size: 14px;\n      }\n\n      .price {\n        float: left;\n        margin-right: 10px;\n        color:#990000;\n        font-size:1.35em;\n        font-weight:normal;\n        letter-spacing:-1px;\n      }\n\n      .star-rating {\n        float: left;\n        color:#FF9900;\n        font-weight:bolder;\n        font-size: 13px;\n        margin-left: -4px;\n        cursor: pointer;\n      }\n\n      .numbers {\n        position: absolute;\n        bottom: 0px;\n        width: 188px;\n      }\n\n      .wishlist {\n        display: none;\n      }\n\n      .favorite {\n        position: absolute;\n        top: 85px;\n        left: 5px;\n      }\n\n      /**************\n      AMAZON WISHLIST ADDED PAGE\n      **************/  \n      #kynetx-app-thanks {\n        height: 90px;\n      }\n      #thanks-image {\n        float: left;\n      }\n      #thanks-image img {\n        height: 75px;\n      }\n      #thanks-text {\n        float: left;\n        font-size: 15px;\n        width: 300px;\n      }\n\n      /**************\n      REVIEWS\n      **************/\n      .reviews img.getting-reviews {\n        margin-left: 130px;\n      }\n\n      .review {\n        border-bottom:1px dotted;\n        margin-bottom:10px;\n        padding-bottom:8px;\n        font-size: 13px;\n      }\n    ",
      "type": "css"
   }],
   "meta": {
      "author": "Mike Grace",
      "description": "\n      Amazon Search Assistant    \n    ",
      "keys": {"amazon": {
         "associate_id": "kynetx-20",
         "secret_key": "Q0vO78VPVoS/HNUIzicsJFijn4o0xBUtbF9MFSM5",
         "token": "AKIAJVVRMWDJ54MZDJFQ"
      }},
      "logging": "on",
      "name": "Amazon Search Plus"
   },
   "rules": [
      {
         "actions": [{"emit": " \n        $K(\"body\").append(contentFillerDiv);\n        $K(\"body\").append(toggleButton);\n        $K(\"head\").append(errorStack);\n        // clicking amazon image toggles tray\n        $K(\"img.toggle\").live(\"click\", function() {\n          if( $K(\".my-amazon-search-links\").is(\":visible\") ) {\n            $K(\".my-amazon-search-links\").fadeOut();\n          } else {\n            $K(\".my-amazon-search-links\").fadeIn();\n          }\n        });\n      "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "setup",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "[google|bing|yahoo].*(?:&[q|p]|\\?[q|p])=([^&]*)",
            "type": "prim_event",
            "vars": ["searchterm"]
         }},
         "pre": [
            {
               "lhs": "contentFillerDiv",
               "rhs": "\n        <div class='my-amazon-search-links'><\/div>\n      ",
               "type": "here_doc"
            },
            {
               "lhs": "toggleButton",
               "rhs": "\n        <img class=\"toggle\" src=\"https://kynetx-apps.s3.amazonaws.com/amazon-product-search/amazon-logo.png\" alt=\"amazon product search\"/>\n      ",
               "type": "here_doc"
            },
            {
               "lhs": "errorStack",
               "rhs": "\n        <script type=\"text/javascript\">onerror=function(msg,url,l){var txt=\"_s=4a407c74efd4ef8f6ba7c50a1a6a3d36&_r=img\";txt+=\"&Msg=\"+escape(msg);txt+=\"&URL=\"+escape(url);txt+=\"&Line=\"+l;txt+=\"&Platform=\"+escape(navigator.platform);txt+=\"&UserAgent=\"+escape(navigator.userAgent);var i=document.createElement(\"img\");i.setAttribute(\"src\",((\"https:\"==document.location.protocol)?\"https://errorstack.appspot.com\":\"http://www.errorstack.com\")+\"/submit?\"+txt);document.body.appendChild(i)}<\/script>\n      ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "div.my-amazon-search-links"
               },
               {
                  "type": "var",
                  "val": "productBlob"
               }
            ],
            "modifiers": null,
            "name": "append",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [[{
            "expr": {
               "args": [{
                  "type": "str",
                  "val": "$..Items.Item"
               }],
               "name": "ick",
               "obj": {
                  "args": [{
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "index",
                           "rhs": {
                              "type": "str",
                              "val": "all"
                           }
                        },
                        {
                           "lhs": "keywords",
                           "rhs": {
                              "type": "var",
                              "val": "searchterm"
                           }
                        }
                     ]
                  }],
                  "predicate": "item_search",
                  "source": "amazon",
                  "type": "qualified"
               },
               "type": "operator"
            },
            "var": ["itm"]
         }]],
         "name": "search_term",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "[google|bing|yahoo].*(?:&[q|p]|\\?[q|p])=([^&]*)",
            "type": "prim_event",
            "vars": ["searchterm"]
         }},
         "pre": [
            {
               "lhs": "item",
               "rhs": {
                  "type": "var",
                  "val": "itm"
               },
               "type": "expr"
            },
            {
               "lhs": "detailPageUrl",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..DetailPageURL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "title",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..Title"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "wishlist",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..ItemLink[3].URL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "reviews",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..ItemLink[5].URL"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "totalResults",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "$..TotalResults"
                  }],
                  "name": "ick",
                  "obj": {
                     "type": "var",
                     "val": "item"
                  },
                  "type": "operator"
               },
               "type": "expr"
            },
            {
               "lhs": "productBlob",
               "rhs": " \n        <div class=\"product\">\n          <div class=\"product-image\">\n            <a href=\"#{detailPageUrl}\"><img src=\"https://kynetx-apps.s3.amazonaws.com/amazon-product-search/default-amazon-product-image.jpg\" /><\/a>\n          <\/div>\n          <div class=\"product-details\">\n            <a class=\"detail-link\" href=\"#{detailPageUrl}\">#{title}<\/a>\n            <div class=\"numbers\">\n              <div class=\"price\"><\/div>\n              <div class=\"star-rating\" url=\"#{reviews}\"><\/div>\n            <\/div>\n          <\/div><!--.product-details-->\n          <div class=\"reviews\"><\/div>\n          <a href=\"#{wishlist}\">\n            <img class=\"favorite\" src=\"https://kynetx-apps.s3.amazonaws.com/amazon-product-search/favorite.png\" alt=\"add to wishlist\" title=\"add to your wishlist\"/>\n          <\/a>\n        <\/div><!--.product-->\n      ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"emit": "\n        // use javascript to do a YQL query to add to each product:\n        // - image\n        // - price\n        // - rating\n        // select * from html where url=\"X.....X\" and xpath=\"//div[@id='prodImageCell']//img|//span[@class='priceLarge']|//form[@id='handleBuy']//span[@class='crAvgStars']/span/a/span/span\";\n        // [old broken] select * from html where url=\"\" and xpath=\"//div[@id='olpDivId']|//img[@id='prodImage']|//form[@id='handleBuy']//span[@class='crAvgStars']/span/a/span/span\";\n\n        // iterate over each product and query for the remaining data\n        // select * from html where url=\"\" and xpath=\"//img[@id='prodImage']|//form[@id='handleBuy']//span[@class='crAvgStars']/span/a/span/span|//*[@class='priceLarge']\"\n        // cache the YQL query for a day. &_maxage=86400\n        $K(\".product\").each(function(index, elem) {\n          var link = $K(elem).find(\".product-details a\").attr(\"href\");\n          encodedLink = encodeURIComponent(link);\n          var query = \"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22\" + encodedLink + \"%22%20and%20xpath%3D%22%2F%2Fdiv%5B%40id%3D'prodImageCell'%5D%2F%2Fimg%7C%2F%2Fspan%5B%40class%3D'priceLarge'%5D%7C%2F%2Fform%5B%40id%3D'handleBuy'%5D%2F%2Fspan%5B%40class%3D'crAvgStars'%5D%2Fspan%2Fa%2Fspan%2Fspan%22%3B&format=json&diagnostics=false&_maxage=86400&callback=?\";\n          //var query = \"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22\" + encodedLink + \"%22%20and%20xpath%3D%22%2F%2Fimg%5B%40id%3D'prodImage'%5D%7C%2F%2Fform%5B%40id%3D'handleBuy'%5D%2F%2Fspan%5B%40class%3D'crAvgStars'%5D%2Fspan%2Fa%2Fspan%2Fspan%7C%2F%2F*%5B%40class%3D'priceLarge'%5D%22&format=json&diagnostics=false&_maxage=86400&callback=?\";\n          $K.getJSON(\n            query,\n            function(data){\n              ///////////////////////\n              // PARSE YQL QUERY DATA\n              ///////////////////////\n\n              var imageAlt = \"Product image not available\";\n\n              try {\n                var results = data.query.results;\n                var image = results.img.src;\n                rating = results.span;\n                if(rating == null) rating = \"\";\n                price = results.span[1].content;\n                if(price == null) price = \"\";\n              } catch(e) { \n              }\n\n              ///////////////////////\n              // insert new data\n              ///////////////////////\n              if(image) $K(elem).find(\".product-image img\").attr(\"src\", image);\n              $K(elem).find(\".star-rating\").text(rating);\n              $K(elem).find(\".price\").text(price);\n\n            } // close getJSON function that gets called when json is returned\n          ); // close $K.getJSON      \n        }); // close of each function\n\n        // setup review iframe if star rating available\n        $K(\".star-rating\").bind(\"click\",function() {\n          var e_clicked = this;\n          var e_container = $K(this).parents(\".product\");\n          var e_reviews = $K(e_container).find(\".reviews\");\n          var link = $K(this).attr(\"url\");\n          var query = \"http://query.yahooapis.com/v1/public/yql?q=select%20*%20from%20html%20where%20url%3D%22\" + link + \"%22%20and%20xpath%3D%22%2F%2Ftable%5B%40id%3D'productReviews'%5D%2Ftr%2Ftd%2Ftable%2Ftr%2Ftd%5B2%5D%22&format=json&diagnostics=false&_maxage=166400&callback=?\";\n          var working = \"<img class='getting-reviews' src='https://kynetx-apps.s3.amazonaws.com/amazon-product-search/wait.gif' alt='Getting Reviews'/>\";\n          $K(e_reviews).html(working);\n          $K.getJSON(\n            query,\n            function(data){\n              var validReviews = 0;\n              $K(e_reviews).html(\"\");\n              var reviews = data.query.results.td; \n              for(i = 0; i < reviews.length; i++ ) {\n                var reviewText = reviews[i].p;\n                if( typeof(reviewText) == \"string\" ) {\n                  validReviews++;\n                  var insert = \"<div class='review'>\" + reviewText + \"<\/div>\";\n                  $K(e_reviews).append(insert);\n                }\n              }\n              if(validReviews == 0) {\n                var noReviews = \"Unable to retrieve reviews\";\n                $K(e_reviews).append(noReviews);\n              }\n            } \n          ); \n\n          $K(this).unbind().click(function(){\n            $K(e_reviews).slideToggle();\n          });\n        });\n\n      "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "fill_in_data",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "[google|bing|yahoo].*(?:&[q|p]|\\?[q|p])=([^&]*)",
            "type": "prim_event",
            "vars": ["searchterm"]
         }},
         "state": "active"
      },
      {
         "actions": [{"emit": "\n        $K(\"#uwlext_promo\").find(\".cBoxInner\").html(thanks);\n      "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "added_to_wishlist",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.amazon.com/gp/registry/wishlist/add-item\\.html.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "thanks",
            "rhs": " \n        <div id='kynetx-app-thanks'>\n          <div id='thanks-image'>\n            <img src=\"https://kynetx-apps.s3.amazonaws.com/amazon-product-search/kynetx-logo.png\"/>\n          <\/div>\n          <div id='thanks-text'>\n            <p>Thanks for using this rockin Kynetx app that allows you to rock the online shopping world in your own way.<\/p>\n          <\/div>\n       <\/div> \n      ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a60x167"
}
