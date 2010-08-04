{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "facebook.com"},
      {"domain": "ashleyfurniture.com"},
      {"domain": "bing.com"},
      {"domain": "search.yahoo.com"},
      {"domain": "ikea.com"}
   ],
   "global": [
      {"emit": "\n(function (b) { var a = { width: 800, height: 600, overlayOpacity: 0.85, id: \"modal\", src: function (c) { return jQuery(c).attr(\"href\") }, fadeInSpeed: 0, fadeOutSpeed: 0 }; b.modal = function (c) { return _modal(this, c) }; b.modal.open = function () { _modal.open() }; b.modal.close = function () { _modal.close() }; b.fn.modal = function (c) { return _modal(this, c) }; _modal = function (c, d) { this.options = { parent: null, overlayOpacity: null, id: null, content: null, width: null, height: null, modalClassName: null, imageClassName: null, closeClassName: null, overlayClassName: null, src: null }; this.options = b.extend({}, options, _defaults); this.options = b.extend({}, options, a); this.options = b.extend({}, options, d); this.close = function () { jQuery(\".\" + options.modalClassName + \", .\" + options.overlayClassName).fadeOut(a.fadeOutSpeed, function () { jQuery(this).unbind().remove() }) }; this.open = function () { if (typeof options.src == \"function\") { options.src = options.src(c) } else { options.src = options.src || _defaults.src(c) } var e = /^.+\\.((jpg)|(gif)|(jpeg)|(png)|(jpg))$/i; var f = \"\"; if (e.test(options.src)) { f = '<div class=\"' + options.imageClassName + '\"><img src=\"' + options.src + '\"/><\/div>' } else { f = '<iframe width=\"' + options.width + '\" height=\"' + options.height + '\" frameborder=\"0\" scrolling=\"no\" allowtransparency=\"true\" src=\"' + options.src + '\"><\/iframe>' } options.content = options.content || f; if (jQuery(\".\" + options.modalClassName).length && jQuery(\".\" + options.overlayClassName).length) { jQuery(\".\" + options.modalClassName).html(options.content) } else { $overlay = jQuery((_isIE6()) ? '<iframe src=\"BLOCKED SCRIPT\\'<html><\/html>\\';\" scrolling=\"no\" frameborder=\"0\" class=\"' + options.overlayClassName + '\"><\/iframe><div class=\"' + options.overlayClassName + '\"><\/div>' : '<div class=\"' + options.overlayClassName + '\"><\/div>'); $overlay.hide().appendTo(options.parent); $modal = jQuery('<div id=\"' + options.id + '\" class=\"' + options.modalClassName + '\" style=\"width:' + options.width + \"px; height:\" + options.height + \"px; margin-top:-\" + (options.height / 2) + \"px; margin-left:-\" + (options.width / 2) + 'px;\">' + options.content + \"<\/div>\"); $modal.hide().appendTo(options.parent); $close = jQuery('<a class=\"' + options.closeClassName + '\"><\/a>'); $close.appendTo($modal); var g = _getOpacity($overlay.not(\"iframe\")) || options.overlayOpacity; $overlay.fadeTo(0, 0).show().not(\"iframe\").fadeTo(a.fadeInSpeed, g); $modal.fadeIn(a.fadeInSpeed); $close.click(function () { jQuery.modal().close() }); $overlay.click(function () { jQuery.modal().close() }) } }; return this }; _isIE6 = function () { if (document.all && document.getElementById) { if (document.compatMode && !window.XMLHttpRequest) { return true } } return false }; _getOpacity = function (c) { $sender = jQuery(c); opacity = $sender.css(\"opacity\"); filter = $sender.css(\"filter\"); if (filter.indexOf(\"opacity=\") >= 0) { return parseFloat(filter.match(/opacity=([^)]*)/)[1]) / 100 } else { if (opacity != \"\") { return opacity } } return \"\" }; _defaults = { parent: \"body\", overlayOpacity: 85, id: \"modal\", content: null, width: 800, height: 600, modalClassName: \"modal-window\", imageClassName: \"modal-image\", closeClassName: \"close-window\", overlayClassName: \"modal-overlay\", src: function (c) { return jQuery(c).attr(\"href\") } } })(jQuery);                    "},
      {
         "content": "#hotDealsHeader {    \tbackground-attachment: scroll;    \tbackground-clip: border-box;    \tbackground-color: transparent;    \tbackground-origin: padding-box;    \tcolor: #00E;    \tcursor: pointer;    \tdisplay: block;    \theight: 39px;    \ttext-decoration: underline;    \twidth: 340px;    }        #hotDeals {    \tbackground-attachment: scroll;    \tbackground-clip: border-box;    \tbackground-color: transparent;    \tbackground-origin: padding-box;    \tcolor: #00E;    \tcursor: pointer;    \tdisplay: block;    \theight: 190px;    \ttext-decoration: underline;    \twidth: 340px;    }        .modal-overlay {    \tposition: fixed;    \ttop: 0;    \tright: 0;    \tbottom: 0;    \tleft: 0;    \theight: 100%;    \twidth: 100%;    \tmargin: 0;    \tpadding: 0;    \tbackground: #131313;    \topacity: .85;    \tfilter: alpha(opacity=85);    \tz-index: 101;    }    .modal-window {    \tposition: fixed;    \ttop: 50%;    \tleft: 50%;    \tmargin: 0;    \tpadding: 0;    \tz-index: 102;    \tbackground: #fff;    \tborder: solid 8px #000;    \t-moz-border-radius: 8px;    \t-webkit-border-radius: 8px;    }    .close-window {    \tposition: absolute;    \twidth: 47px;    \theight: 47px;    \tright: -23px;    \ttop: -23px;    \tbackground: transparent url(http:\\/\\/grigglee.com/random/fancybox/fancy_close.png) no-repeat scroll right top;    \ttext-indent: -99999px;    \toverflow: hidden;    \tcursor: pointer;    }            ",
         "type": "css"
      }
   ],
   "meta": {
      "logging": "off",
      "name": "rc_willey_demo"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#res>div>ol"
               },
               {
                  "type": "var",
                  "val": "samsung_message"
               }
            ],
            "modifiers": null,
            "name": "prepend",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif(!KOBJ.a41x94.watching){  \tKOBJ.a41x94.watching = true;  \tKOBJ.watchDOM(\"#rso>li:last\",function(){  \t\tdelete KOBJ['a41x94'].pendingClosure;  \t\tKOBJ.reload();  \t});  }            ",
         "foreach": [],
         "name": "samsung_insert_google",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)www.google.com(/|/webhp\\?hl=en|search).*(samsung|tv|lcd|big.screen|$)",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "samsung_message",
            "rhs": " \n<li class=\"g w0\">  \t\t\t<h3 class=\"r\">  \t\t\t\t<a href=\"http:\\/\\/www.rcwilley.com/Electronics/TV-Video/LCD-TVs/UN55B8000/1909680/Samsung-55-LED-LCD-TV-View.jsp\" class=\"l\">  \t\t\t\t\tSamsung 55\" Inch <em>TV<\/em>  \t\t\t\t<\/a>  \t\t\t<\/h3>  \t\t\t<div class=\"s\">  \t\t\t\t<div style=\"float: right; width: auto; height: 40px; font-size: 12px; line-height: normal; font-family: Verdana, Geneva, sans-serif; \">  \t\t\t\t\t<div style=\"float: left; display: inline; height: 40px; margin-left: 15px; padding-right: 15px; \">  \t\t\t\t\t\t<ul style=\"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px; list-style-type: none; list-style-position: initial; list-style-image: initial; \" id=\"KOBJ_anno_list\">    \t\t\t\t\t\t\t<li class=\"KOBJ_item\" style=\"float: left; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; vertical-align: middle; padding-left: 4px; color: rgb(204, 204, 204); white-space: nowrap; text-align: center; \">  \t\t\t\t\t\t\t\t<a href=\"http:\\/\\/www.rcwilley.com\" style=\"border: none;\">  \t\t\t\t\t\t\t\t\t<img src=\"http:\\/\\/grigglee.com/random/rc_willey/logo.png\" style=\"border: none; height: 60px;\" />  \t\t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t\t<\/li>    \t\t\t\t\t\t\t<li class=\"KOBJ_item\" style=\"float: left; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; vertical-align: middle; padding-left: 4px; color: rgb(204, 204, 204); white-space: nowrap; text-align: center; \">  \t\t\t\t\t\t\t\t<a href=\"http:\\/\\/dme-studios.com/swf/player-licensed.swf?file=../flv/RCWsuperbowl_PortSample_600x338.flv&autostart=true&skin=../swf/modieus.swf\" onclick='$K(this).modal({width:833, height:453}).open(); return false;' style=\"border: none;\" >  \t\t\t\t\t\t\t\t\t<img src=\"http:\\/\\/grigglee.com/random/rc_willey/rc_demo.jpg\" style=\"height: 50px; border: 5px ridge black;\" />  \t\t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t\t<\/li>  \t\t\t\t\t\t<\/ul>  \t\t\t\t\t<\/div>  \t\t\t\t<\/div>    \t\t\t\tSamsung ultra-slim LED TVs combine breakthrough picture quality, eco-friendly design and advanced connectivity options. Purchase now and get free shipping! <b>...<\/b><br>  \t\t\t\t<cite>www.rcwilley.com - <\/cite>  \t\t\t<\/div>  \t\t\t<div class=\"wce\">  \t\t\t<\/div><!--n--><!--m-->  \t\t<\/li>  \t\n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "#rightCol"
               },
               {
                  "type": "var",
                  "val": "facebook_message"
               }
            ],
            "modifiers": null,
            "name": "prepend",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.watchDOM(\"#contentArea\",function(){ $K(\"#rightCol\").prepend(facebook_message); });            ",
         "foreach": [],
         "name": "social_media",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.facebook.com/",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "facebook_message",
            "rhs": " \n<div id=\"KynetxProxy\" style=\"margin-bottom: 10px;\">  \t\t  \t\t  \t\t\t\t<div class=\"UIHomeBox UITitledBox\" id=\"Kynetx_Logo\" style=\"margin-bottom: 0px;\">  \t\t  \t\t\t\t\t<div class=\"UITitledBox_Content\" style=\"text-align: center;\">  \t\t\t\t\t\t<div>  \t\t\t\t\t\t\t<a href=\"http:\\/\\/www.rcwilley.com\">  \t\t\t\t\t\t\t\t<img src=\"http:\\/\\/grigglee.com/random/rc_willey/logo.png\" alt=\"Kynetx\" style=\"position: relative; right: -6px; margin-bottom: 5px;\" />  \t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t\t<a href=\"http:\\/\\/www.facebook.com/pages/RC-Willey/112045124326\">  \t\t\t\t\t\t\t\t<img src=\"http:\\/\\/k-misc.s3.amazonaws.com/resources/a41x53/image4.jpg\" alt=\"Become a RC Willey Fan\" style=\"margin-top: -10px; margin-bottom: 10px;\" />  \t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t<\/div>    \t\t\t\t\t<\/div>  \t\t\t\t<\/div>  \t\t  \t\t  \t\t\t<\/div>  \t\t\n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "form[name=f]"
               },
               {
                  "type": "var",
                  "val": "message"
               }
            ],
            "modifiers": null,
            "name": "after",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "google_home",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)^http://www.google.com/($|webhp\\?hl=en$)",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "message",
            "rhs": " \n<div class=\"rc_willey_promo\">  \t\t\t<a href=\"http:\\/\\/www.rcwilley.com/PromoCircular.jsp\" alt=\"Hot Deals\" id=\"hotDealsHeader\" style=\"background:url(http:\\/\\/www.rcwilley.com/media/imageLink/161.jpg)\" />  \t\t\t<a href=\"http:\\/\\/www.rcwilley.com/Appliances/Laundry/Search.jsp?m=FRG\" alt=\"Category Killer- Laundry\" id=\"hotDeals\" style=\"background:url(http:\\/\\/www.rcwilley.com/media/imageLink/190.jpg)\"/>  \t\t<\/div>  \t\n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [null],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "samsung_insert_bing",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.bing.com/search.*(?:&|\\?)q=(.*?)(?:&|$)",
            "type": "prim_event",
            "vars": ["search_terms"]
         }},
         "post": {
            "cons": [null],
            "type": null
         },
         "pre": [{
            "lhs": "bing_search_insert",
            "rhs": " \n<li>  \t\t\t<div class=\"sa_cc\">  \t\t\t\t<div class=\"sb_tlst\">  \t\t\t\t\t<h3>  \t\t\t\t\t\t<a href=\"http:\\/\\/www.rcwilley.com/Electronics/TV-Video/LCD-TVs/UN55B8000/1909680/Samsung-55-LED-LCD-TV-View.jsp\">  \t\t\t\t\t\t\tSamsung 55\" <strong>TV<\/strong>  \t\t\t\t\t\t<\/a>  \t\t\t\t\t<\/h3>  \t\t\t\t<\/div>  \t\t\t\t<p>  \t\t\t\t\t<div style=\"float: right; width: auto; height: 40px; font-size: 12px; line-height: normal; font-family: Verdana, Geneva, sans-serif; \">  \t\t\t\t\t\t<div style=\"float: left; display: inline; height: 40px; margin-left: 15px; padding-right: 15px; \">  \t\t\t\t\t\t\t<ul style=\"margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; padding-top: 0px; padding-right: 0px; padding-bottom: 0px; padding-left: 0px; list-style-type: none; list-style-position: initial; list-style-image: initial; \" id=\"KOBJ_anno_list\">  \t  \t\t\t\t\t\t\t\t<li class=\"KOBJ_item\" style=\"float: left; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; vertical-align: middle; padding-left: 4px; color: rgb(204, 204, 204); white-space: nowrap; text-align: center; \">  \t\t\t\t\t\t\t\t\t<a href=\"http:\\/\\/www.rcwilley.com\" style=\"border: none;\">  \t\t\t\t\t\t\t\t\t\t<img src=\"http:\\/\\/grigglee.com/random/rc_willey/logo.png\" style=\"border: none; height: 60px;\" />  \t\t\t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t\t\t<\/li>  \t  \t\t\t\t\t\t\t\t<li class=\"KOBJ_item\" style=\"float: left; margin-top: 0px; margin-right: 0px; margin-bottom: 0px; margin-left: 0px; vertical-align: middle; padding-left: 4px; color: rgb(204, 204, 204); white-space: nowrap; text-align: center; \">  \t\t\t\t\t\t\t\t\t<a href=\"http:\\/\\/dme-studios.com/swf/player-licensed.swf?file=../flv/RCWsuperbowl_PortSample_600x338.flv&autostart=true&skin=../swf/modieus.swf\" onclick='$K(this).modal({width:833, height:453}).open(); return false;' style=\"border: none;\" >  \t\t\t\t\t\t\t\t\t\t<img src=\"http:\\/\\/grigglee.com/random/rc_willey/rc_demo.jpg\" style=\"height: 50px; border: 5px ridge black;\" />  \t\t\t\t\t\t\t\t\t<\/a>  \t\t\t\t\t\t\t\t<\/li>  \t\t\t\t\t\t\t<\/ul>  \t\t\t\t\t\t<\/div>  \t\t\t\t\t<\/div>  \t\t\t\t\tThe best source for free videos, show and episode info, <strong>TV<\/strong> listings guide, cast lists, <strong>TV<\/strong> gossip, and entertainment news.  \t\t\t\t<\/p>  \t\t\t\t<ul class=\"sb_meta\">  \t\t\t\t\t<li>  \t\t\t\t\t\t<cite>  \t\t\t\t\t\t\twww.rcwilley.com  \t\t\t\t\t\t<\/cite>  \t\t\t\t\t<\/li>  \t\t\t\t<\/ul>  \t\t\t<\/div>  \t\t<\/li>    \t\n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a41x94"
}
