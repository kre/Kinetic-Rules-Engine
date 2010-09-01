;

window['$KOBJ'] = $$KOBJ;

if (typeof($K) == 'undefined') {
    window['$K'] = $$KOBJ;
}

window['KOBJ'] = { name: "KRL Runtime Library",
    version: '0.9',
    copyright: "Copyright 2007-2009, Kynetx Inc.  All Rights reserved."
};

KOBJ['extra_page_vars'] = {};
KOBJ['applications'] = {};
KOBJ['data'] = KOBJ['data'] || {};
KOBJ['external_resources'] = {};

KOBJ.in_bx_extention = false;
KOBJ.can_ajax_post = false;

//used for overriding the document for UI actions
KOBJ.document = document;
KOBJ.locationHref = null;
KOBJ.locationHost = null;
KOBJ.locationProtocol = null;
KOBJ.delay_execution = false;
