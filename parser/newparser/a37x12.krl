{
   "dispatch": [
      {"domain": "www.google.com"},
      {"domain": "search.yahoo.com"},
      {"domain": "www.bing.com"},
      {"domain": "search.microsoft.com"},
      {"domain": "1800flowers.com"}
   ],
   "global": [
      {
         "content": ".deepivy_callout {        position: absolute;        background-color: #E9F2DB;        /* easy rounded corners for modern browsers */        -moz-border-radius: 6px;        -webkit-border-radius: 6px;        border-radius: 6px;        z-index: 99;        margin: -55px 67px;    }        .deepivy_callout_ie8 {        position: absolute;        background-color: #E9F2DB;                -moz-border-radius: 6px;        -webkit-border-radius: 6px;        border-radius: 6px;        z-index: 99;        margin: -5px 0px;        width: 325px;    }        .deepivy_callout .notch {        position: absolute;        top: 20px;        left: -18px;        margin: 0;        border-left: none;        border-top: 10px solid transparent;        border-right: 20px solid #E9F2DB;        border-bottom: 10px solid transparent;        padding: 0;        width: 0;        height: 0;        /* ie6 height fix */        font-size: 0;        line-height: 0%;         /* ie6 transparent fix */        _border-top-color: pink;        _border-bottom-color: pink;        _filter: chroma(color=pink);    }        .border-callout { border: 2px solid #2B5A13; padding: 2px 2px; }    .border-callout .border-notch { border-right-color: #2B5A13; left: -21px;}        .deepivy_callout .heading {         font-weight:bold;         color: black;         font-family: Sans-serif;         width: 100%;         text-align:left;         margin: 5px 10px;    }        .deepivy_callout_ie8 .heading {         font-weight:bold;         color: black;         font-family: Sans-serif;         width: 100%;         text-align:left;         margin: 5px 10px;    }        .deepivy_callout .content {         font-weight:normal;         color: black;         font-family: Sans-serif;         text-align:left;         padding-left: 0;         border: 2px solid #2B5A13;         margin: 10px 5px;         background-color: white;                  -moz-border-radius: 6px;         -webkit-border-radius: 6px;         border-radius: 6px;    }        .deepivy_callout_ie8 .content {         font-weight:normal;         color: black;         font-family: Sans-serif;         text-align:left;         padding-left: 0;         border: 2px solid #2B5A13;         margin: 10px 5px;         background-color: white;                  -moz-border-radius: 6px;         -webkit-border-radius: 6px;         border-radius: 6px;    }        .deepivy_callout .controls {         float: right;         margin-right: 5px;         margin-bottom: 0px;    }        .deepivy_callout_ie8 .controls {         float: right;         margin-right: 5px;         margin-bottom: 0px;    }            .deepivy_callout table {         border: none;    }        .deepivy_callout_ie8 table {         border: none;    }        .deepivy_callout table, .deepivy_callout th {         font-weight:bold;         color: orange;         padding-left: 5px;    }        .deepivy_callout_ie8 table, .deepivy_callout_ie8 th {         font-weight:bold;         color: orange;         padding-left: 5px;    }        .deepivy_callout table, .deepivy_callout td {         font-weight:normal;         color: black;         padding-left: 5px;         white-space:nowrap;    }        .deepivy_callout_ie8 table, .deepivy_callout_ie8 td {         font-weight:normal;         color: black;         padding-left: 5px;         white-space:nowrap;    }    ",
         "type": "css"
      },
      {"emit": "\nKOBJ.showDiCallout = function (placeholder, callout) {      $K(placeholder).parent().hover(    \tfunction() { $K(callout).show(); },            function() { $K(callout).hide(); }      );    };          eval(function(p,a,c,k,e,r){e=function(c){return(c<62?'':e(parseInt(c/62)))+((c=c%62)>35?String.fromCharCode(c+29):c.toString(36))};if('0'.replace(0,e)==0){while(c--)r[e(c)]=k[c];k=[function(e){return r[e]||e}];e=function(){return'([3-9a-zB-Z]|1\\\\w)'};c=1};while(c--)if(k[c])p=p.replace(new RegExp('\\\\b'+e(c)+'\\\\b','g'),k[c]);return p}('(6($){6 Z(f,3){4 7=n;f=b(f);4 5=b(document.createElement(\\'div\\')).B(3.10).B((3.p)?3.11:\\'\\').B((3.C)?3.12:\\'\\').13(3.q).appendTo(f);a(!3.14)5.t();o 5.r();a(!3.C){f.hover(6(c){7.t(c)},6(){7.r()});a(!3.p){f.mousemove(6(c){a(5.D(\\'N\\')!==\\'u\\')7.E(c)})}}o{f.click(6(c){a(c.15===f.16(0)){a(5.D(\\'N\\')!==\\'u\\')7.r();o 7.t()}});b(v).mousedown(6(c){a(5.D(\\'N\\')!==\\'u\\'){4 17=(3.O)?b(c.15).parents(\\'.5\\').andSelf().filter(6(){d n===5.16(0)}).length:0;a(17===0)7.r()}})};b.18(7,{getVersion:6(){d[1,2,0]},getParent:6(){d f},getTooltip:6(){d 5},getPos:6(){d 5.i()},19:6(8,9){4 e=f.i();a(s 8==\\'F\\')8=G(8)+e.k;a(s 9==\\'F\\')9=G(9)+e.l;5.D({k:8,l:9});d 7},t:6(c){3.1a.m(7);7.E((3.p)?P:c);Q(3.1b){g\\'H\\':5.fadeIn(3.I);h;g\\'1c\\':5.slideDown(3.I,7.E);h;g\\'1d\\':3.1e.m(5,3.I);h;w:g\\'u\\':5.t();h};5.B(3.R);3.1f.m(7);d 7},r:6(){3.1g.m(7);Q(3.1h){g\\'H\\':5.fadeOut(3.J);h;g\\'1c\\':5.slideUp(3.J);h;g\\'1d\\':3.1i.m(5,3.J);h;w:g\\'u\\':5.r();h};5.removeClass(3.R);3.1j.m(7);d 7},update:6(q){5.13(q);3.q=q;d 7},1k:6(1l,K){3.1m.m(7);5.1k(1l,K,6(){3.1n.m(7)});d 7},L:6(8,9){4 1o=8+5.S();4 1p=9+5.T();4 1q=b(v).width()+b(v).scrollLeft();4 1r=b(v).height()+b(v).scrollTop();d[(1o>=1q),(1p>=1r)]},E:6(c){4 x=5.S();4 y=5.T();a(!c&&3.p){a(3.j.constructor==Array){8=G(3.j[0]);9=G(3.j[1])}o a(b(3.j).attr(\\'nodeType\\')===1){4 i=b(3.j).i();8=i.k;9=i.l}o{4 e=f.i();4 z=f.S();4 M=f.T();Q(3.j){g\\'l\\':4 8=e.k-(x/2)+(z/2);4 9=e.l-y;h;g\\'bottom\\':4 8=e.k-(x/2)+(z/2);4 9=e.l+M;h;g\\'k\\':4 8=e.k-x;4 9=e.l-(y/2)+(M/2);h;g\\'right\\':4 8=e.k+z;4 9=e.l-(y/2)+(M/2);h;w:g\\'w\\':4 8=(z/2)+e.k+20;4 9=e.l;h}}}o{4 8=c.pageX;4 9=c.pageY};a(s 3.j!=\\'object\\'){8=8+3.i[0];9=9+3.i[1];a(3.L){4 U=7.L(8,9);a(U[0])8=8-(x/2)-(2*3.i[0]);a(U[1])9=9-(y/2)-(2*3.i[1])}}o{a(s 3.j[0]==\"F\")8=1s(8);a(s 3.j[1]==\"F\")9=1s(9)};7.19(8,9);d 7}})};b.fn.V=6(3){4 W=b(n).eq(s 3==\\'number\\'?3:0).K(\"V\");a(W)d W;4 X={q:\\'A simple 5\\',C:1t,O:1t,14:Y,j:\\'w\\',i:[0,0],L:Y,p:Y,1b:\\'H\\',I:1u,1e:P,1h:\\'H\\',J:1u,1i:P,10:\\'5\\',R:\\'active\\',11:\\'p\\',12:\\'C\\',focusClass:\\'O\\',1a:6(){},1f:6(){},1g:6(){},1j:6(){},1m:6(){},1n:6(){}};b.18(X,3);n.each(6(){4 el=new Z(b(n),X);b(n).K(\"V\",el)});d n}})();',[],93,'|||conf|var|tooltip|function|self|posX|posY|if|jQuery|event|return|elemPos|elem|case|break|offset|position|left|top|call|this|else|fixed|content|hide|typeof|show|none|window|default|tooltipWidth|tooltipHeight|elemWidth||addClass|persistent|css|updatePos|string|parseInt|fade|showTime|hideTime|data|boundryCheck|elemHeight|display|focus|null|switch|activeClass|outerWidth|outerHeight|overflow|simpletip|api|defaultConf|true|Simpletip|baseClass|fixedClass|persistentClass|html|hidden|target|get|check|extend|setPos|onBeforeShow|showEffect|slide|custom|showCustom|onShow|onBeforeHide|hideEffect|hideCustom|onHide|load|uri|beforeContentLoad|onContentLoad|newX|newY|windowWidth|windowHeight|String|false|150'.split('|'),0,{}));                "}
   ],
   "meta": {
      "author": "Jeesmon Jacob",
      "description": "\nDeepIvy     \n",
      "logging": "off",
      "name": "DeepIvy"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": [
               {
                  "name": "remote",
                  "value": {
                     "type": "str",
                     "val": "http://www.deepivy.com/site/kynetx/json?jsoncallback=?"
                  }
               },
               {
                  "name": "name",
                  "value": {
                     "type": "str",
                     "val": "DKOBJ"
                  }
               }
            ],
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": {"success": [{
            "attribute": "class",
            "trigger": null,
            "type": "click",
            "value": "KOBJ_deepivy"
         }]},
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": null,
         "foreach": [],
         "name": "search",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://www.google.com|^http://search.yahoo.com|^http://www.bing.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": ""
               },
               {
                  "type": "var",
                  "val": "onsite_callout_html"
               }
            ],
            "modifiers": [
               {
                  "name": "sticky",
                  "value": {
                     "type": "bool",
                     "val": "true"
                  }
               },
               {
                  "name": "opacity",
                  "value": {
                     "type": "str",
                     "val": "1.0"
                  }
               },
               {
                  "name": "position",
                  "value": {
                     "type": "str",
                     "val": "top-left"
                  }
               },
               {
                  "name": "background_color",
                  "value": {
                     "type": "str",
                     "val": "#FFF"
                  }
               },
               {
                  "name": "width",
                  "value": {
                     "type": "str",
                     "val": "406px"
                  }
               },
               {
                  "name": "height",
                  "value": {
                     "type": "str",
                     "val": "201px"
                  }
               }
            ],
            "name": "notify",
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
         "name": "onsite",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "^http://\\w+.1800flowers.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      }
   ],
   "ruleset_name": "a37x12"
}
