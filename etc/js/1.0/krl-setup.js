// This file is part of the Kinetic Rules Engine (KRE).
// Copyright (C) 2007-2011 Kynetx, Inc.
// Licensed under: GNU Public License version 2 or later

//window['$KOBJ'] = $$KOBJ;

if (typeof($K) == 'undefined') {
    window['$K'] = $KOBJ;
}

window['KOBJ'] = { name: "KRL Runtime Library",
    version: '0.9',
    copyright: "Portions of this file are part of the Kinetic Rules Engine (KRE). Copyright (C) 2007-2011 Kynetx, Inc. Licensed under: GNU Public License version 2 or later."
};

KOBJ['extra_page_vars'] = {};
KOBJ['applications'] = {};
KOBJ['data'] = KOBJ['data'] || {};
KOBJ['external_resources'] = {};

KOBJ.in_bx_extention = false;

//used for overriding the document for UI actions
KOBJ.window = window;
KOBJ.navigator = navigator;
KOBJ.document = document;

KOBJ.locationHref = null;
KOBJ.locationHost = null;
KOBJ.locationProtocol = null;
KOBJ.locationHash = null;
KOBJ.delay_execution = false;
