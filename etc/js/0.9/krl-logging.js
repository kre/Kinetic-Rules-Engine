// Set up logging
KOBJ.log4js = log4javascript;

KOBJ.loggers = {
    general:        KOBJ.log4js.getLogger("general") ,
    application:    KOBJ.log4js.getLogger("application"),
    datasets:       KOBJ.log4js.getLogger("datasets"),
    actions:        KOBJ.log4js.getLogger("actions"),
    runtime:        KOBJ.log4js.getLogger("runtime"),
    annotate:       KOBJ.log4js.getLogger("annotate"),
    percolate:      KOBJ.log4js.getLogger("percolate"),
    domwatch:       KOBJ.log4js.getLogger("domwatch")
};

KOBJ.popup_appender = new KOBJ.log4js.PopUpAppender();
KOBJ.popup_appender.setLayout(new KOBJ.log4js.PatternLayout("%d{HH:mm:ss} %p %c %m{1}"));
KOBJ.console_appender = new KOBJ.log4js.BrowserConsoleAppender();
KOBJ.console_appender.setLayout(new KOBJ.log4js.PatternLayout("%d{HH:mm:ss} %p %c %m{1}"));
KOBJ.log4js.getLogger().addAppender(KOBJ.console_appender);

KOBJ.enable_popup_logging = function() {
    KOBJ.log4js.getLogger().addAppender(KOBJ.popup_appender);
    $KOBJ.each(KOBJ.loggers, function(k, v) {
        v.addAppender(KOBJ.popup_appender);
    });
};

// Set the default logging level
$KOBJ.each(KOBJ.loggers, function(k, v) {
    v.setLevel(KOBJ.log4js.Level.INFO);
    v.addAppender(KOBJ.console_appender);
});


KOBJ.mega_debug = function() {
    KOBJ.enable_popup_logging();
    KOBJ.log4js.getLogger().setLevel(KOBJ.log4js.Level.INFO);
    $KOBJ.each(KOBJ.loggers, function(k, v) {
        v.setLevel(KOBJ.log4js.Level.TRACE);
    });
    KOBJ.popup_appender.show();
};
