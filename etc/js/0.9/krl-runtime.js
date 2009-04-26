


;

var $K = jQuery.noConflict();

// dummy up the Firebug console commands so a rogue console call doesn't kill code
if(!("console"in window)||!("firebug"in console)){var names=["log","debug","info","warn","error","assert","dir","dirxml","group","groupEnd","time","timeEnd","count","trace","profile","profileEnd"];window.console={};for(var i=0;i<names.length;++i)window.console[names[i]]=function(){};}


var KOBJ= KOBJ ||
  { name: "KRL Runtime Library",
    version: '0.9',
    copyright: "Copyright 2007-2009, Kynetx LLC.  All Rights reserverd."
  };


// this can be removed next update cycle
KOBJ.search_annotation = {};
KOBJ.search_annotation.defaults = {
  "name": "KOBJ",
  "sep": "<div style='padding-top: 13px'>|</div>",
  "text_color":"#CCC",
  "height":"40px",
  "left_margin": "46px",
  "right_padding" : "15px",
  "font_size":"12px",
  "font_family": "Verdana, Geneva, sans-serif"
};

KOBJ.annotate_search_results = function(annotate, config) {

  var defaults = {
  "name": "KOBJ",
  "sep": "<div style='padding-top: 13px'>|</div>",
  "text_color":"#CCC",
  "height":"40px",
  "left_margin": "15px",
  "right_padding" : "15px",
  "font_size":"12px",
  "font_family": "Verdana, Geneva, sans-serif"
  };

  // if config exists, then update
  if(typeof config === 'object') {
    jQuery.extend(defaults,config);
  }

  function mk_list_item(i) {
    return $K("<li class='"+defaults.name+"_item'>").css(
          {"float": "left",
	   "margin": "0",
	   "vertical-align": "middle",
	   "padding-left": "4px",
	   "color": defaults.text_color,
	   "white-space": "nowrap",
           "text-align": "center"
          }).append(i);
  }

  function mk_rm_div (anchor) {
    var name = defaults.name;
    var logo_item = mk_list_item(anchor);
    var logo_list = $K('<ul>').css(
          {"margin": "0",
           "padding": "0",
           "list-style": "none"
          }).attr("id", name+"_anno_list").append(logo_item);
    var inner_div = $K('<div>').css(
          {"float": "left",
           "display": "inline",
           "height": defaults.height,
           "margin-left": defaults.left_margin,
           "padding-right": defaults.right_padding
          }).append(logo_list);
    if (typeof defaults != 'undefined' &&
        defaults['tail_image']){
      inner_div.css({
           "background-image": "url(" + defaults['tail_image'] + ")",
           "background-repeat": "no-repeat",
           "background-position": "right top"
		    });
    }
    var rm_div = $K('<div>').css(
          {"float": "right",
           "width": "auto",
           "height": defaults.height,
           "font-size": defaults.font_size,
           "line-height": "normal",
           "font-family": defaults.font_familty
	   }).append(inner_div);
    if (typeof defaults != 'undefined' &&
        defaults['head_image']){
     rm_div.css({
           "background-image": "url(" + defaults['head_image'] +")",
           "background-repeat": "no-repeat",
           "background-position": "left top"
		});
    }
    return rm_div;
  }

  $K("li.g, li div.res").each(function() {
        var contents = annotate(this);
        if (contents) {
          if($K(this).find('#'+defaults.name+'_anno_list li').is('.'+defaults.name+'_item')) {
             $K(this).find('#'+defaults.name+'_anno_list').append(mk_list_item(defaults.sep)).append(mk_list_item(contents));
          } else {
             $K(this).find("div.s,div.abstr").prepend(mk_rm_div(contents));
          }
        }
   });

};

KOBJ.logger = function(type,txn_id,element,url,sense,rule) {
    e=document.createElement("script");
    e.src=KOBJ.callback_url+"?type="+type+"&txn_id="+txn_id+"&element="+element+"&ts="+KOBJ.d+"&sense="+sense+"&url="+escape(url)+"&rule="+rule;
    body=document.getElementsByTagName("body")[0];
    body.appendChild(e);
};

KOBJ.obs = function(type, txn_id, name, sense, rule) {
    if(type == 'class') {
	$K('.'+name).click(function(e1) {
	    var tgt = $K(this);
	    var b = tgt.attr('href') || '';
	    KOBJ.logger("click",
			txn_id,
			name,
			b,
			sense,
			rule
	    );
            if(b) { tgt.attr('href','#'); }  // # gets replaced by redirect
	    });
    } else {
	$K('#'+name).click(function(e1) {
	    var tgt = $K(this);
	    var b = tgt.attr('href') || '';
	    KOBJ.logger("click",
			txn_id,
			name,
			b,
			sense,
			rule
	    );
            if(b) { tgt.attr('href','#'); }  // # gets replaced by redirect
	    });
    }
};



KOBJ.fragment = function(base_url) {
    e=document.createElement("script");
    e.src=base_url;
    body=document.getElementsByTagName("body")[0];
    body.appendChild(e);
};

KOBJ.update_elements  = function (params) {
    for (var mykey in params) {
 	$K("#kobj_"+mykey).html(params[mykey]);
    };
};

// wrap some effects for use in embedded HTML
KOBJ.Fade = function (id) {
  $K(id).fadeOut();
};

KOBJ.BlindDown = function (id) {
  $K(id).slideDown();
};

KOBJ.BlindUp = function (id) {
  $K(id).slideUp();
};

KOBJ.BlindUp = function (id, speed) {
  $K(id).slideUp(speed);
};

KOBJ.hide = function (id) {
    $K(id).hide();
};

// helper functions used by float
KOBJ.buildDiv = function (uniq, pos, top, side) {
    var vert = top.split(/\s*:\s*/);
    var horz = side.split(/\s*:\s*/);
    var div_style = {
        position: pos,
        zIndex: '9999',
        opacity: 0.999999,
        display: 'none'
    };
    div_style[vert[0]] = vert[1];
    div_style[horz[0]] = horz[1];
    var id_str = 'kobj_'+uniq;
    var div = document.createElement('div');
    return $K(div).attr({'id': id_str}).css(div_style);
};

// return the host portion of a URL
KOBJ.get_host = function(s) {
 var h = "";
 try {
   h = s.match(/^(?:\w+:\/\/)?([\w.]+)/)[1];
 } catch(err) {
 }
 return h;
};

// randomly pick a member of a list
KOBJ.pick = function(o) {
    if (o) {
        return o[Math.floor(Math.random()*o.length)];
    } else {
        return o;
    }
};

// attach a close event to an element inside a notification
KOBJ.close_notification = function(s) {
  $K(s).bind("click.kGrowl",
             function(e) {
               $K(this).unbind('click.kGrowl');
               $K(s).parents(".kGrowl-notification").trigger('kGrowl.beforeClose').animate({opacity: 'hide'}, "normal", "swing", function() {$K(this).trigger('kGrowl.close').remove();});});
};



if(typeof(kvars) != "undefined") {
    KOBJ.kvars_json = $K.toJSON(kvars);
} else {
    KOBJ.kvars_json = '';
}

KOBJ['data'] = KOBJ['data'] || {};

// initialization vars
KOBJ.proto = 'http://';
KOBJ.init_host = 'init.kobj.net';
KOBJ.eval_host = 'cs.kobj.net';
KOBJ.callback_host = 'log.kobj.net';


// I don't think we need this anymore.
// KOBJ.startKJQuery = function(){
// 		      if(typeof($K) != "undefined"){
// 			$K.isReady = true;
// 		      } else {
// 			setTimeout("startKJQuery()", 50);
// 		      }
// };
// KOBJ.startKJQuery;

KOBJ.init = function(init_obj) {

  $K.each(init_obj,function(k,v) {
		      KOBJ[k] = v;
		    });
};

KOBJ.css = function(css) {
  if($K("style[title=KOBJ_stylesheet]").length == 0) {
    var r=document.createElement("style");
     r.innerHTML= css;
     r.type= "text/css";
     r.media = "screen";
     r.rel = "stylesheet";
     r.title="KOBJ_stylesheet"
     var head=document.getElementsByTagName("head")[0];
     head.appendChild(r);
  }
  $K("style[title=KOBJ_stylesheet]").append(css + '\n');
};


KOBJ.require = function(url) {
  var r=document.createElement("script");
  r.src= url;
  r.type= "text/javascript";
  var body=document.getElementsByTagName("body")[0];
  body.appendChild(r);
};

KOBJ.reload = function(delay) {
  var r=document.createElement("script");
  r.type= "text/javascript";
  r.innerHTML=  "KOBJ.eval(KOBJ_config);"
  var body=document.getElementsByTagName("body")[0];
  setTimeout(function(){body.appendChild(r)},delay);
};


KOBJ.eval = function(params) {
  if(! params.rids && typeof(params.rids) !== 'array') {
    return;
  }

  KOBJ.site_id = params.rids.join(";");

  // datasets
  var data_url = KOBJ.proto+KOBJ.init_host+"/js/datasets/" + KOBJ.site_id + "/";
  KOBJ.require(data_url);



  var d = (new Date).getTime();
  var url = KOBJ.proto+KOBJ.eval_host+"/ruleset/eval/" + KOBJ.site_id;
  KOBJ.callback_url = KOBJ.proto+KOBJ.callback_host+"/log/" + KOBJ.site_id;

  var param_str = "";
  if(params) {
    $K.each(params,function(k,v) {
	      if(!(k == 'rids' || k == 'init')) {
		param_str += "&" + k + "=" + v;
		}
	      });
  }

  var eval_url = url + "/"
             + d
	     + ".js?caller="
             + escape(document.URL)
	     + "&referer="
             + escape(document.referrer)
	     + "&kvars="
             + escape(KOBJ.kvars_json)
	     + "&title="
             + encodeURI(document.title)
             + param_str;
//  console.log(eval_url);

//    $K('<script type="text/javascript">').attr(
//         {"src": eval_url}).appendTo("body");

  KOBJ.require(eval_url);


};

if(typeof(KOBJ_config) == 'object') {
  if(typeof(KOBJ_config.init) == 'object') {
    KOBJ.init(KOBJ_config.init);
  }
  KOBJ.eval(KOBJ_config);
}

