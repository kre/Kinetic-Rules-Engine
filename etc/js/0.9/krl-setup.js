;

window['$KOBJ'] = $$KOBJ;

if (typeof($K) == 'undefined') {
    window['$K'] = $$KOBJ;
}

//if(typeof(window['KOBJ']) == "undefined")
//{
    window['KOBJ'] = { name: "KRL Runtime Library",
        version: '0.9',
        copyright: "Copyright 2007-2009, Kynetx Inc.  All Rights reserved."
    };    
//}
//else
//{
//    $KOBJ.extend(KOBJ, { name: "KRL Runtime Library",
//        version: '0.9',
//        copyright: "Copyright 2007-2009, Kynetx Inc.  All Rights reserved."
//    });
//};
//


/* TODO: Not used as far as I can tell CID 4/13 */
KOBJ._log = new Array();

KOBJ['applications'] = {};
KOBJ['data'] = KOBJ['data'] || {};
KOBJ['extra_page_vars'] = {};
KOBJ['external_resources'] = {};

KOBJ['defaults'] = {};

//used for overriding the document for UI actions
KOBJ.document = document;
KOBJ.locationHref = null;
KOBJ.locationHost = null;
KOBJ.locationProtocol = null;
KOBJ.delay_execution = false;




