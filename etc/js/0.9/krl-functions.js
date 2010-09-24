/* Injects a javascript fragment into the page */
// TODO: Remove only used by the widget weather.pl
KOBJ.fragment = function(base_url) {
    var e = KOBJ.document.createElement("script");
    e.src = base_url;
    var body = KOBJ.document.getElementsByTagName("body")[0];
    body.appendChild(e);
};

/* Replaces the html contents of an element */
// TODO: Remove only used by the widget weather.pl
KOBJ.update_elements = function (params) {
    for (var mykey in params) {
        $KOBJ("#kobj_" + mykey).html(params[mykey]);
    }
};

// wrap some effects for use in embedded HTML
KOBJ.Fade = function (id) {
    $KOBJ(id).fadeOut();
};

KOBJ.BlindDown = function (id) {
    $KOBJ(id).slideDown();
};

KOBJ.BlindUp = function (id) {
    $KOBJ(id).slideUp();
};

KOBJ.BlindUp = function (id, speed) {
    $KOBJ(id).slideUp(speed);
};

KOBJ.hide = function (id) {
    $KOBJ(id).hide();
};

// TODO: Remove as I hate this
KOBJ.letitsnow = function(config) {
    $KOBJ(KOBJ.document).snowfall();
};

// TODO: Remove not used use side tab now
KOBJ.createPopIn = function(config, content) {

    var defaults = {
        "position": "left-center",
        "imageLocation": "http://k-misc.s3.amazonaws.com/actions/pop_in_feedback.jpg",
        "bg_color": "#FFFFFF",
        "link_color": "#FF0000",
        "overlay_color": "#000000"
    };
    if (typeof config === 'object') {
        jQuery.extend(defaults, config);
    }

    var side1;
    var side2;
    var distance;

    switch (defaults["position"]) {
        case "top-left":
            side1 = "top";
            side2 = "left";
            distance = "10%";
            break;
        case "top-center":
            side1 = "top";
            side2 = "left";
            distance = "45%";
            break;
        case "top-right":
            side1 = "top";
            side2 = "right";
            distance = "10%";
            break;
        case "bottom-left":
            side1 = "bottom";
            side2 = "left";
            distance = "10%";
            break;
        case "bottom-center":
            side1 = "bottom";
            side2 = "left";
            distance = "45%";
            break;
        case "bottom-right":
            side1 = "bottom";
            side2 = "right";
            distance = "10%";
            break;
        case "left-top":
            side1 = "left";
            side2 = "top";
            distance = "10%";
            break;
        case "left-center":
            side1 = "left";
            side2 = "top";
            distance = "45%";
            break;
        case "left-bottom":
            side1 = "left";
            side2 = "bottom";
            distance = "10%";
            break;
        case "right-top":
            side1 = "right";
            side2 = "top";
            distance = "10%";
            break;
        case "right-center":
            side1 = "right";
            side2 = "top";
            distance = "45%";
            break;
        case "right-bottom":
            side1 = "right";
            side2 = "bottom";
            distance = "10%";
            break;
        default:
            side1 = "left";
            side2 = "top";
            distance = "45%";
            break;
    }

    $KOBJ('body').append('<div id="KOBJ_PopIn_Link" style="' + side1 + ': 0; ' + side2 + ':' + distance + '; -moz-border-radius-bottomright: 12px; -moz-border-radius-topright: 12px; background-color:' + defaults["link_color"] + '; display:block; margin-top:-45px; position: fixed;  z-index:100001;"><a href="javascript:KOBJ_create_pop_in()"><img src="' + defaults["imageLocation"] + '" alt="KOBJ_pop_in" border="none" /></a>');
    KOBJ_create_pop_in = function() {
        var OverlayPresent = $KOBJ('#KOBJ_PopIn_Overlay').length;
        var ContentPresent = $KOBJ('#KOBJ_PopIn_Dialog').length;

        if (OverlayPresent) {
            $KOBJ('#KOBJ_PopIn_Overlay').fadeIn('slow');
        }
        if (ContentPresent) {
            $KOBJ('#KOBJ_PopIn_Dialog').fadeIn('slow');
        }
        if (!OverlayPresent) {
            $KOBJ('body').append('<div id="KOBJ_PopIn_Overlay" style="display: block; position: fixed; background-color: ' + defaults["overlay_color"] + '; height: 100%; width: 100%; left: 0; filter:alpha(opacity=70); opacity: 0.7; top: 0; z-index: 100002; display: none;" />');
            $KOBJ('#KOBJ_PopIn_Overlay').fadeIn('slow');
        }
        if (!ContentPresent) {

            // TODO: Display is overridden remove which one?
            $KOBJ('body').append('<div id="KOBJ_PopIn_Dialog" style="top: 45%; right: 40%; -moz-border-radius: 5px; display: block; height: auto; width: 20%; position: fixed; margin: 0 auto; text-align: center; z-index: 100003; display: none; background: ' + defaults["bg_color"] + '; filter:alpha(opacity=85); opacity: .85; "><div class="close" id="KOBJ_Close" style="cursor: pointer; float: right; font-weight: bold; margin-right: 8px; margin-top: 5px;">x</div><div id="KOBJ_PopIn_Content" style="padding: 10px; ">' + content + '</div></div>');
            $KOBJ("#KOBJ_Close").click(function() {
                KOBJ_close_pop_in();
            });
            $KOBJ('#KOBJ_PopIn_Dialog').fadeIn('slow');
        }

    };

    KOBJ_close_pop_in = function() {

        $KOBJ('#KOBJ_PopIn_Overlay').fadeOut('slow');
        $KOBJ('#KOBJ_PopIn_Dialog').fadeOut('slow');

    };

};

// TODO: Broken as it resets defaults based on config.  It should copy the config
// and use the copied hash
KOBJ.statusbar = function(config, content) {

    var defaults = {


        "sticky": false,
        "width": "98.5%",
        "height": "30px",
        "id": "KOBJ_status_bar",
        "bg_color": "#222222",
        "delay": 3000,
        "position": "bottom",
        "opacity": ".8",
        "color": "#ffffff"

    };
    if (typeof config === 'object') {
        if (config["sticky"] === true) {
            config["delay"] = false;
        }
        jQuery.extend(defaults, config);

    }
    var side = "";
    var corners = "";
    var direction = "";

    switch (defaults["position"]) {
        case "top":
            side = "top";
            corners = "bottom";
            direction = "down";
            break;
        case "bottom":
            side = "bottom";
            corners = "top";
            direction = "up";
            break;
        default:
            side = "bottom";
            corners = "top";
            direction = "up";
            break;
    }


    $KOBJ('body').append('<div id="' + defaults["id"] + '_wrapper" style="display: none; position: fixed; ' + side + ': 0; width: 100%; height: ' + defaults["height"] + ';"><div id="' + defaults["id"] + '" style="color: ' + defaults["color"] + '; height: ' + defaults["height"] + '; background: ' + defaults["bg_color"] + '; opacity: ' + defaults["opacity"] + '; -moz-border-radius-' + corners + 'right: 5px; -moz-border-radius-' + corners + 'left: 5px; margin-left: 12px; margin-right: 30px;"><div class="close" style="float: right; font-weight: bold; font-size: 20px; cursor: pointer; margin-right: 10px; margin-top: 5px;">x</div><div class="KOBJ_statusbar_content" style="color: ' + defaults["color"] + ';">' + content + '</div></div>');
    $KOBJ('#' + defaults["id"] + '>.close').click(function() {
        KOBJ.statusbar_close(defaults["id"]);
    });
    $KOBJ('#' + defaults["id"] + '_wrapper').slideDown('slow');
    if (defaults["sticky"] === false) {
        setTimeout(function() {
            KOBJ.statusbar_close(defaults["id"]);
        }, defaults["delay"]);
    }


};


//TODO: Broken Assumes only one status base. Maybe that is ok.
KOBJ.statusbar_close = function(id) {
    $KOBJ('#' + id).fadeOut('slow');
};

//end new jessie actions

KOBJ.page_collection_content_event = function (uniq, label, top_selector, parent_selector, selectors, config) {
    var app = KOBJ.get_application(config.rid);

    var found_data = [];

    // First find the top_selector elements.
    $KOBJ(top_selector).each(function() {

        // Now using that top selector as a context find each row
        $KOBJ(parent_selector, this).each(function() {
            var parent = this;
            var the_data = { "parent" : parent};
            var data = {};
            the_data["data"] = data;

            $KOBJ.each(selectors, function(name, selector) {
                var result = $KOBJ(selector["selector"], parent);
                if (selector["type"] == "text")
                    result = result.text();
                else if (selector["type"] == "form")
                    result = result.val();
                else
                    result = "invalid select type";

                data[name] = result;
            });


            found_data.push(the_data);

        })
    });

    if (config.callback != null) {
        config.callback(label, found_data);
    }
};


// helper functions used by float
KOBJ.buildDiv = function (uniq, pos, top, side, config) {
    var vert = top.split(/\s*:\s*/);
    var horz = side.split(/\s*:\s*/);
    var div_style = {
        position: pos,
        zIndex: '9999',

        display: 'none'
    };
    var class_name = "";
    if (typeof(config) != "undefined" && typeof(config.class_name) != "undefined") {
        class_name = config.class_name;
    }
    div_style[vert[0]] = vert[1];
    div_style[horz[0]] = horz[1];
    var id_str = 'kobj_' + uniq;
    var div = KOBJ.document.createElement('div');
    return $KOBJ(div).attr({'id': id_str}).css(div_style).addClass(class_name);
};


// randomly pick a member of a list
KOBJ.pick = function(o) {
    if (o) {
        return o[Math.floor(Math.random() * o.length)];
    } else {
        return o;
    }
};

// attach a close event to an element inside a notification
KOBJ.close_notification = function(s) {
    $KOBJ(s).bind("click.kGrowl",
                 function(e) {
                     $KOBJ(this).unbind('click.kGrowl');
                     $KOBJ(s).parents(".kGrowl-notification").trigger('kGrowl.beforeClose').animate({opacity: 'hide'}, "normal", "swing", function() {
                         $KOBJ(this).trigger('kGrowl.close').remove();
                     });
                 });
};


/* Inject requested CSS via a style tag */
KOBJ.css = function(css) {
    var head = KOBJ.document.getElementsByTagName('head')[0];
    var style = KOBJ.document.createElement('style');
    var rules = KOBJ.document.createTextNode(css);

    style.type = 'text/css';
    style.id = 'KOBJ_stylesheet';

    var KOBJstyle = KOBJ.document.getElementById('KOBJ_stylesheet');
    if (KOBJstyle == null) {
        if (style.styleSheet) {
            style.styleSheet.cssText = rules.nodeValue;
        } else {
            style.appendChild(rules);
        }
        head.appendChild(style);
    } else {
        if (KOBJstyle.styleSheet) {
            KOBJstyle.styleSheet.cssText += rules.nodeValue;
        } else {
            KOBJstyle.appendChild(rules);
        }
    }
};


KOBJ.parseURL = function(url) {
    var a = KOBJ.document.createElement('a');
    a.href = url;
    return {
        source: url,
        protocol: a.protocol.replace(':', ''),
        host: a.hostname,
        port: a.port,
        query: a.search,
        params: (function() {
            var ret = {},
                    seg = a.search.replace(/^\?/, '').split('&'),
                    len = seg.length, i = 0, s;
            for (; i < len; i++) {
                if (!seg[i]) {
                    continue;
                }
                s = seg[i].split('=');
                ret[s[0]] = s[1];
            }
            return ret;
        })(),
        file: (a.pathname.match(/\/([^\/?#]+)$/i) || [,''])[1],
        hash: a.hash.replace('#', ''),
        path: a.pathname.replace(/^([^\/])/, '/$1'),
        relative: (a.href.match(/tps?:\/\/[^\/]+(.+)/) || [,''])[1],
        segments: a.pathname.replace(/^\//, '').split('/')
    };
};

KOBJ.parseURLParams = function(param_string) {
    var ret = {};
    var seg = param_string.replace(/^\?/, '').split('&');
    var len = seg.length;
    var i = 0;
    var s = null;
    for (; i < len; i++) {
        if (!seg[i]) {
            continue;
        }
        s = seg[i].split('=');
        ret[s[0]] = s[1];
    }
    return ret;
};


KOBJ.urlDecode = function (psEncodeString)
{
  // Create a regular expression to search all +s in the string
  var lsRegExp = /\+/g;
  // Return the decoded string
  return unescape(String(psEncodeString).replace(lsRegExp, " "));
};
