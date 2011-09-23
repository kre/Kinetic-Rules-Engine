// This file is part of the Kinetic Rules Engine (KRE).
// Copyright (C) 2007-2011 Kynetx, Inc.
// Licensed under: GNU Public License version 2 or later

// Set up logging
KOBJ.log4js = log4javascript;

KOBJ.loggers = {
    general:        KOBJ.log4js.getLogger("general") ,
    application:    KOBJ.log4js.getLogger("application"),
    datasets:       KOBJ.log4js.getLogger("datasets"),
    events:       KOBJ.log4js.getLogger("events"),
    resources:       KOBJ.log4js.getLogger("resources"),
    actions:        KOBJ.log4js.getLogger("actions"),
    runtime:        KOBJ.log4js.getLogger("runtime"),
    annotate:       KOBJ.log4js.getLogger("annotate"),
    percolate:      KOBJ.log4js.getLogger("percolate"),
    domwatch:       KOBJ.log4js.getLogger("domwatch")
};

KOBJ.popup_appender = new log4javascript.PopUpAppender();
KOBJ.popup_appender.setLayout(new log4javascript.PatternLayout("%d{HH:mm:ss} %p %c %m{4}"));
KOBJ.console_appender = new log4javascript.BrowserConsoleAppender();
KOBJ.console_appender.setLayout(new log4javascript.PatternLayout("%d{HH:mm:ss} %p %c %m{4}"));
KOBJ.log4js.getLogger().addAppender(KOBJ.console_appender);

KOBJ.enable_popup_logging = function() {
    KOBJ.log4js.getLogger().addAppender(KOBJ.popup_appender);
    $KOBJ.each(KOBJ.loggers, function(k, v) {
        v.addAppender(KOBJ.popup_appender);
    });
};

// Set the default logging level
$KOBJ.each(KOBJ.loggers, function(k, v) {
    v.setLevel(log4javascript.Level.INFO);
    v.addAppender(KOBJ.console_appender);
});


KOBJ.trace_domwatch = function() {
  KOBJ.loggers.domwatch.setLevel(log4javascript.Level.TRACE);
};


KOBJ.mega_debug = function() {
    KOBJ.enable_popup_logging();
    KOBJ.log4js.getLogger().setLevel(log4javascript.Level.TRACE);
    $KOBJ.each(KOBJ.loggers, function(k, v) {
        // Dom watch is a little to much by default even for mega debug.
//        if(k != "domwatch")
        {
            v.setLevel(log4javascript.Level.TRACE);
        }
    });
    KOBJ.popup_appender.show();
};


if(typeof(KOBJMegaDebug) != "undefined")
{
    KOBJ.mega_debug();
}