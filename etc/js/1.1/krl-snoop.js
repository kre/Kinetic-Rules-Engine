// This file is part of the Kinetic Rules Engine (KRE).
// Copyright (C) 2007-2011 Kynetx, Inc.
// Licensed under: GNU Public License version 2 or later

KRLSnoop = {};

KRLSnoop.browser_info = function() {
    var data = { nav : {}, screen: {}};


    data.nav.appCodeName = KOBJ.navigator.appCodeName;
    data.nav.appName = KOBJ.navigator.appName;
    data.nav.appVersion = KOBJ.navigator.appVersion;
    data.nav.userAgent = KOBJ.navigator.userAgent;
    data.nav.language = KOBJ.navigator.language;
    data.nav.cookiesEnabled = KOBJ.navigator.cookiesEnabled;
    data.nav.systemLanguage = KOBJ.navigator.systemLanguage;
    data.nav.userLanguage = KOBJ.navigator.userLanguage;
    data.screen.availHeight = KOBJ.window.screen.availHeight;
    data.screen.availWidth = KOBJ.window.screen.availWidth;
    data.screen.colorDepth = KOBJ.window.screen.colorDepth;
    data.screen.height = KOBJ.window.screen.height;
    data.screen.width = KOBJ.window.screen.width;
    data.screen.pixelDepth = KOBJ.window.screen.pixelDepth;

    return data;
};

KRLSnoop.exception_info = function(exception) {
    var data = { };

    data.script_url = (exception.fileName ? exception.fileName : (exception.filename ? exception.filename : null));
    if (!data.script_url) {
        data.script_url = (exception.sourceURL ? exception.sourceURL : "Unsupported");
    }

    data.message = (exception.message ? exception.message : e);
    data.lineNumber = (exception.lineNumber ? exception.lineNumber : (exception.line ? exception.line : "Unsupported"));
    data.description = exception.description ? exception.description : "";
    data.arguments = (exception.arguments ? exception.arguments : "Unsupported");
    data.type = (exception.type ? exception.type : "Unsupported");
    data.name = (exception.name ? exception.name : e);
    data.stack = (exception.stack ? exception.stack : "Unsupported");

    return data;
};



