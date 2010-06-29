/* modified from jGrowl 1.1.2 to fit KOBJ needs */
 (function($) {

    $.kGrowl = function(m, in_config) {
        var config = {};
		$.extend(config,$.kGrowl.defaults, in_config);
        // To maintain compatibility with older version that only supported one instance we'll create the base container.
        var styling = {
            "padding": "10px",
            "z-index": 9999,
            "position": "fixed"
        };

        var pos = config.position.split("-");

        styling[pos[0]] = "0px";
        //vert
        styling[pos[1]] = "0px";
        //horz
        if ($.browser.msie) {
            // degrade for IE
            styling["position"] = "absolute";
        }

        config["kid"] = "kGrowl"  + config.position

        if ($("#" + config["kid"]).size() == 0)
        {
            $('<div id="'+ config["kid"]  +'"></div>').css(styling).appendTo('body');
        }
        // Create a notification on the container.
        $("#" + config["kid"]).kGrowl(m, config);
    };


    /** Raise kGrowl Notification on a kGrowl Container **/
    $.fn.kGrowl =
    function(m, config) {
        if ($.isFunction(this.each)) {
            var args = arguments;

            return this.each(function() {
                var self = this;

                /** Create a kGrowl Instance on the Container if it does not exist **/
                if ($(this).data('kGrowl.instance') == undefined) {
                    $(this).data('kGrowl.instance', new $.fn.kGrowl());
                    $(this).data('kGrowl.instance').startup(this);
                }

                /** Optionally call kGrowl instance methods, or just raise a normal notification **/
                if ($.isFunction($(this).data('kGrowl.instance')[m])) {
                    $(this).data('kGrowl.instance')[m].apply($(this).data('kGrowl.instance'), $.makeArray(args).slice(1));
                } else {
                    $(this).data('kGrowl.instance').notification(m, config);
                }
            });
        }
    };

    $.extend($.fn.kGrowl.prototype, {

        /** Default JGrowl Settings **/
        defaults: {
            background_color: "#222",
            color: "#fff",
            font_size: "12px",
            header_font_size: "13px",
            width: "235px",
            header: '',
            sticky: false,
            position: 'top-right',
            glue: 'after',
            theme: 'default',
            corners: '10px',
            check: 500,
            life: 3000,
            opacity: .85,
            speed: 'normal',
            easing: 'swing',
            closer: true,
            closeTemplate: '&times;',
            closerTemplate: '<div>[ close all ]</div>',
            log: function(e, m, o) {},
            beforeOpen: function(e, m, o) {},
            open: function(e, m, o) {},
            beforeClose: function(e, m, o) {},
            close: function(e, m, o) {},
            animateOpen: {
                opacity: 'show'
            },
            animateClose: {
                opacity: 'hide'
            }
        },

        /** kGrowl Container Node **/
        element: null,

        /** Interval Function **/
        interval: null,

        /** Create a Notification **/
        notification: function(message, config) {
            var self = this;

            config.log.apply(this.element, [this.element, message, config]);

            var header = $('<div>').addClass("KOBJ_header").css(
            {
                "font-weight": "bold",
                "font-size": config.header_font_size
            }).html(config.header);

            var message = $('<div>').addClass("KOBJ_message").html(message);

            var close = $('<div>').addClass("close").css(
            {
                "float": "right",
                "font-weight": "bold",
                "font-size": config.font_size,
                "cursor": "pointer"
            }
            ).html(config.closeTemplate);

            var notification_style = {
                "-moz-border-radius": "5px",
                "-webkit-border-radius": "5px",
                "background-color": config.background_color,
                "color": config.color,
                "display": "none",
                "filter": "alpha(opacity = " + config.opacity * 100 + ")",
                "font-family": "Tahoma, Arial, Helvetica, sans-serif",
                "font-size": config.font_size,
                "margin-bottom": "5px",
                "margin-top": "5px",
                "min-height": "40px",
                "opacity": config.opacity,
                "padding": "10px",
                "text-align": "left",
                "width": config.width,
                "zoom": "1"
            };

            var closer_style = {
                "cursor": "pointer",
                "font-weight": "bold",
                "height": "15px",
                "padding-bottom": "4px",
                "padding-top": "4px",
                "text-align": "center"
            };
            jQuery.each(notification_style,
            function(i, v) {
                if (!closer_style[i]) closer_style[i] = v;
            });
            closer_style["min-height"] = undefined;

            var notification = $('<div>').addClass("kGrowl-notification").css(notification_style).append(close).append(header).append(message).data("kGrowl", config).addClass(config.theme).children('div.close').bind("click.kGrowl",
            function() {
                $(this).unbind('click.kGrowl').parent().trigger('kGrowl.beforeClose').animate(config.animateClose, config.speed, config.easing,
                function() {
                    $(this).trigger('kGrowl.close').remove();
                });
            }).parent();

            (config.glue == 'after') ? $('div.kGrowl-notification:last', this.element).after(notification) : $('div.kGrowl-notification:first', this.element).before(notification);

            /** Notification Actions **/
            $(notification).bind("mouseover.kGrowl",
            function() {
                $(this).data("kGrowl").pause = true;
            }).bind("mouseout.kGrowl",
            function() {
                $(this).data("kGrowl").pause = false;
            }).bind('kGrowl.beforeOpen',
            function() {
                config.beforeOpen.apply(self.element, [self.element, message, config]);
            }).bind('kGrowl.open',
            function() {
                config.open.apply(self.element, [self.element, message, config]);
            }).bind('kGrowl.beforeClose',
            function() {
                config.beforeClose.apply(self.element, [self.element, message, config]);
            }).bind('kGrowl.close',
            function() {
                config.close.apply(self.element, [self.element, message, config]);
            }).trigger('kGrowl.beforeOpen').animate(config.animateOpen, config.speed, config.easing,
            function() {
                $(this).data("kGrowl").created = new Date();
            }).trigger('kGrowl.open');

            /** Optional Corners Plugin **/
            if ($.fn.corner != undefined) $(notification).corner(config.corners);

            /* For IE put iframe behide it to cover flash */
            $(".kGrowl-notification").parent().bgiframe({
                "opacity": true,
                "left": 10,
                "top": -15
            });

            /** Add a Global Closer if more than one notification exists **/
            if ($('div.kGrowl-notification:parent', this.element).size() > 1 && $('div.kGrowl-closer', this.element).size() == 0 && config.closer != false) {
                $(config.closerTemplate).addClass('kGrowl-closer').css(closer_style).addClass(config.theme).appendTo(this.element).animate(config.animateOpen, config.speed, config.easing).bind("click.kGrowl",
                function() {
                    $(this).siblings().children('div.close').trigger("click.kGrowl");

                    if ($.isFunction(config.closer)) config.closer.apply($(this).parent()[0], [$(this).parent()[0]]);
                });
            };
        },

        /** Update the kGrowl Container, removing old kGrowl notifications **/
        update: function() {
            $(this.element).find('div.kGrowl-notification:parent').each(function() {
                if ($(this).data("kGrowl") != undefined && $(this).data("kGrowl").created != undefined && ($(this).data("kGrowl").created.getTime() + $(this).data("kGrowl").life) < (new Date()).getTime() && $(this).data("kGrowl").sticky != true &&
                ($(this).data("kGrowl").pause == undefined || $(this).data("kGrowl").pause != true)) {
                    $(this).children('div.close').trigger('click.kGrowl');
                }
            });
        
            if ($(this.element).find('div.kGrowl-notification:parent').size() < 2) {
                $(this.element).find('div.kGrowl-closer').animate($.kGrowl.defaults.animateClose, $.kGrowl.defaults.speed, $.kGrowl.defaults.easing,
                function() {
                    $(this).remove();
                });
            };
        },

        /** Setup the kGrowl Notification Container **/
        startup: function(e) {
            this.element = $(e).addClass('kGrowl').append('<div class="kGrowl-notification"></div>');
            this.interval = setInterval(function() {
                jQuery(e).data('kGrowl.instance').update();
            },
            $.kGrowl.defaults.check);

        },

        /** Shutdown kGrowl, removing it and clearing the interval **/
        shutdown: function() {
            $(this.element).removeClass('kGrowl').find('div.kGrowl-notification').remove();
            clearInterval(this.interval);
        }
    });

    /** Reference the Defaults Object for compatibility with older versions of kGrowl **/
    $.kGrowl.defaults = $.fn.kGrowl.prototype.defaults;

})(jQuery);