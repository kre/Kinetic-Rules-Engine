{
   "dispatch": [],
   "global": [{"emit": "\n(function ($) {        $.format = (function () {         \t\tvar parseMonth = function(value){             \t\tswitch(value){        \t\tcase \"Jan\":        \t\t\treturn \"01\";             \t\tbreak;        \t\tcase \"Feb\":        \t\t\treturn \"02\";              \t\tbreak;        \t\tcase \"Mar\":        \t\t\treturn \"03\";              \t\tbreak;\t              \t\tcase \"Apr\":        \t\t\treturn \"04\";              \t\tbreak;\t              \t\tcase \"May\":        \t\t\treturn \"05\";              \t\tbreak;\t              \t\tcase \"Jun\":        \t\t\treturn \"06\";              \t\tbreak;\t              \t\tcase \"Jul\":        \t\t\treturn \"07\";              \t\tbreak;\t              \t\tcase \"Aug\":        \t\t\treturn \"08\";              \t\tbreak;        \t\tcase \"Sep\":        \t\t\treturn \"09\";              \t\tbreak;\t         \t\tcase \"Oct\":        \t\t\treturn \"10\";              \t\tbreak;\t         \t\tcase \"Nov\":        \t\t\treturn \"11\";              \t\tbreak;\t         \t\tcase \"Dec\":        \t\t\treturn \"12\";              \t\tbreak;\t         \t\t        \t\t        \t\t        \t\t\t              \t\t        \t\t        \t\t        \t\t        \t\t    \t\t\tdefault:    \t\t\t\treturn value;    \t\t\t}      \t\t};         \t\tvar parseTime = function(value){    \t\t\tvar retValue = value;    \t\t\tif(retValue.indexOf(\".\") != -1){    \t\t\t\tretValue =  retValue.substring(0, retValue.indexOf(\".\"));    \t\t\t}             \t\tvar values3 = retValue.split(\":\");        \t\t        \t\tif(values3.length == 3){    \t    \t\thour\t\t= values3[0];     \t    \t\tminute\t\t= values3[1];    \t    \t\tsecond\t\t= values3[2];         \t\t\t\treturn {    \t\t\t\t\t\ttime: retValue,    \t\t\t\t\t\thour: hour,    \t\t\t\t\t\tminute: minute,    \t\t\t\t\t\tsecond: second    \t\t\t\t};        \t\t} else {    \t\t\t\treturn {    \t\t\t\t\ttime: \"\",    \t\t\t\t\thour: \"\",    \t\t\t\t\tminute: \"\",    \t\t\t\t\tsecond: \"\"    \t\t\t};    \t\t\t        \t\t}    \t\t};                        return {                date: function(value, format){                \t          \t\t              \ttry{                \t\tvar values = value.split(\" \");                \t\tvar year \t\t= null;                \t\tvar month \t\t= null;                \t\tvar dayOfMonth \t= null;                \t\tvar time \t\t= null;               \t\t                \t\tswitch(values.length){                \t\tcase 6:              \t\t\tyear \t\t= values[5];            \t\t\t    \t            \t\tmonth \t\t= parseMonth(values[1]);    \t            \t\tdayOfMonth \t= values[2];    \t            \t\ttime\t\t= parseTime(values[3]);                \t\t\tbreak;                \t\tcase 2:              \t\t\tvar values2 = values[0].split(\"-\");                \t\t\tyear \t\t= values2[0];               \t\t\t                \t\t\tmonth \t\t= values2[1];    \t            \t\tdayOfMonth \t= values2[2];    \t            \t\ttime \t\t= parseTime(values[1]);                \t\t\tbreak;                \t\tdefault:                \t\t\treturn value;                \t\t}                \t\t                \t\t                \t\tvar pattern \t= \"\";                \t\tvar retValue \t= \"\";                \t\t                \t\tfor(i = 0; i < format.length; i++){                \t\t\tvar currentPattern = format.charAt(i);                \t\t\tpattern += currentPattern;                \t\t\tswitch(pattern){                    \t\tcase \"dd\":                    \t\t\tretValue += dayOfMonth;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;    \t\t\t\tcase \"mM\":    \t\t\t\t\tretValue += month.replace(/0/,\"\");    \t\t\t\t\tpatern = \"\";    \t\t\t\tbreak;                    \t\tcase \"MM\":                    \t\t\tretValue += month;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;\t            \t\t                    \t\tcase \"yyyy\":                    \t\t\tretValue += year;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;                    \t\tcase \"HH\":                    \t\t\tretValue += time.hour;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;    \t            \t\t                    \t\tcase \"hh\":                    \t\t\tretValue += time.hour;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;                    \t\tcase \"mm\":                    \t\t\tretValue += time.minute;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;                    \t\tcase \"ss\":                    \t\t\tretValue += time.second;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;                    \t\tcase \" \":                    \t\t\tretValue += currentPattern;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;                    \t\tcase \"/\":                    \t\t\tretValue += currentPattern;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;    \t            \t                    \t\tcase \":\":                    \t\t\tretValue += currentPattern;                    \t\t\tpattern   = \"\";        \t            \t\tbreak;    \t            \t    \t            \t\t                \t\t\tdefault:                \t\t\t\tif(pattern.length == 2 && pattern.indexOf(\"y\") != 0){                \t\t\t\t\tretValue += pattern.substring(0, 1);                \t\t\t\t\tpattern = pattern.substring(1, 2);                \t\t\t\t} else if((pattern.length == 3 && pattern.indexOf(\"yyy\") == -1)){                \t\t\t\t\tpattern   = \"\";                \t\t\t\t}                \t\t\t}                                    }                \t\treturn retValue;                \t} catch(e) {                    \treturn value;                \t}\t            \t}            };        })();    }($K));              KOBJ.a41x88 = KOBJ.a41x88 || {};    KOBJ.a41x88.forms = KOBJ.a41x88.forms || [];        KOBJ.stateMap = {        \"ALABAMA\":\"AL\",        \"ALASKA\":\"AK\",        \"AMERICAN SAMOA\":\"AS\",        \"ARIZONA\":\"AZ\",        \"ARKANSAS\":\"AR\",        \"CALIFORNIA\":\"CA\",        \"COLORADO\":\"CO\",        \"CONNECTICUT\":\"CT\",        \"DELAWARE\":\"DE\",        \"DISTRICT OF COLUMBIA\":\"DC\",        \"FEDERATED STATES OF MICRONESIA\":\"FM\",        \"FLORIDA\":\"FL\",        \"GEORGIA\":\"GA\",        \"GUAM\":\"GU\",        \"HAWAII\":\"HI\",        \"IDAHO\":\"ID\",        \"ILLINOIS\":\"IL\",        \"INDIANA\":\"IN\",        \"IOWA\":\"IA\",        \"KANSAS\":\"KS\",        \"KENTUCKY\":\"KY\",        \"LOUISIANA\":\"LA\",        \"MAINE\":\"ME\",        \"MARSHALL ISLANDS\":\"MH\",        \"MARYLAND\":\"MD\",        \"MASSACHUSETTS\":\"MA\",        \"MICHIGAN\":\"MI\",        \"MINNESOTA\":\"MN\",        \"MISSISSIPPI\":\"MS\",        \"MISSOURI\":\"MO\",        \"MONTANA\":\"MT\",        \"NEBRASKA\":\"NE\",        \"NEVADA\":\"NV\",        \"NEW HAMPSHIRE\":\"NH\",        \"NEW JERSEY\":\"NJ\",        \"NEW MEXICO\":\"NM\",        \"NEW YORK\":\"NY\",        \"NORTH CAROLINA\":\"NC\",        \"NORTH DAKOTA\":\"ND\",        \"NORTHERN MARIANA ISLANDS\":\"MP\",        \"OHIO\":\"OH\",        \"OKLAHOMA\":\"OK\",        \"OREGON\":\"OR\",        \"PALAU\":\"PW\",        \"PENNSYLVANIA\":\"PA\",        \"PUERTO RICO\":\"PR\",        \"RHODE ISLAND\":\"RI\",        \"SOUTH CAROLINA\":\"SC\",        \"SOUTH DAKOTA\":\"SD\",        \"TENNESSEE\":\"TN\",        \"TEXAS\":\"TX\",        \"UTAH\":\"UT\",        \"VERMONT\":\"VT\",        \"VIRGIN ISLANDS\":\"VI\",        \"VIRGINIA\":\"VA\",        \"WASHINGTON\":\"WA\",        \"WEST VIRGINIA\":\"WV\",        \"WISCONSIN\":\"WI\",        \"WYOMING\":\"WY\"        };                KOBJ.StateToST = function(val){    \tvar lookedUp = KOBJ.stateMap[val.toUpperCase()];    \tif(lookedUp){    \t\treturn lookedUp;    \t} else {    \t\treturn false;    \t}        \treturn false;    };        KOBJ.setFormMaps = function(map){    \tKOBJ.a41x88.forms.push(map);    };        KOBJ.fillForms = function(formData){    \tvar maxLengthURL = KOBJ.maxURLLength;        \tvar formMap = KOBJ.a41x88.forms[KOBJ.a41x88.forms.length - 1];        \tvar stateArray = [];    \tvar errorState, anyError = false;    \tvar count = 0;    \t$K(formMap).each(function(){    \t\ttry{    \t\t\terrorState = false;    \t\t\tvar map = this;    \t\t\tvar selector = map['selector'];    \t\t\tvar mapTo = map['map'];    \t\t\tvar format = map['format'];    \t\t\tvar mapArray = mapTo.split(\".\");        \t\t\tvar num = 0;    \t\t\tvar value = \"\";        \t\t\tfunction mapGetter(obj){    \t\t\t\tif(num == mapArray.length){    \t\t\t\t\treturn obj;    \t\t\t\t} else {    \t\t\t\t\tvar mapString = mapArray[num++];    \t\t\t\t\treturn mapGetter(obj[mapString]);    \t\t\t\t}    \t\t\t}        \t\t\tvar value = mapGetter(formData);        \t\t\tif($K(selector).length){    \t\t\t\tif(format){    \t\t\t\t\tvar valToBe = '';    \t\t\t\t\tswitch(format){    \t\t\t\t\t\tcase \"area\":    \t\t\t\t\t\t\tvalToBe = value.slice(0,3);    \t\t\t\t\t\tbreak;            \t\t\t\t\t\tcase \"first-3\":    \t\t\t\t\t\t\t\tvalToBe = value.slice(3,6);    \t\t\t\t\t\tbreak;            \t\t\t\t\t\tcase \"last-4\":    \t\t\t\t\t\t\tvalToBe = value.slice(6,10);    \t\t\t\t\t\tbreak;            \t\t\t\t\t\tcase \"all\":    \t\t\t\t\t\t\tvalToBe = value;    \t\t\t\t\t\tbreak;            \t\t\t\t\t\tcase \"ST\":    \t\t\t\t\t\t\tvalToBe = KOBJ.StateToST(value);    \t\t\t\t\t\tbreak;            \t\t\t\t\t\tcase \"State\":    \t\t\t\t\t\t\tvalToBe = value;    \t\t\t\t\t\tbreak;            \t\t\t\t\t\tdefault:    \t\t\t\t\t\t\tvar tempVal = value.split(' ');    \t\t\t\t\t\t\tif(tempVal.length != 2){    \t\t\t\t\t\t\t\tvar tempVal2 = tempVal[0].split('-');    \t\t\t\t\t\t\t\tif(tempVal.length == 2){    \t\t\t\t\t\t\t\t\tvalue += \"-00 00:00:00.000\";    \t\t\t\t\t\t\t\t} else {    \t\t\t\t\t\t\t\t\tvalue += \"-00 00:00:00.000\";    \t\t\t\t\t\t\t\t}    \t\t\t\t\t\t\t} else {    \t\t\t\t\t\t\t\tvar tempVal3 = tempVal[1].split(':');    \t\t\t\t\t\t\t\tif(tempVal3.length != 3){    \t\t\t\t\t\t\t\t\tif(tempVal3.length == 2){    \t\t\t\t\t\t\t\t\t\tvalue += \"00.000\";    \t\t\t\t\t\t\t\t\t} else if(tempVal3.length == 1){    \t\t\t\t\t\t\t\t\t\tvalue += \"00:00\";    \t\t\t\t\t\t\t\t\t}    \t\t\t\t\t\t\t\t}    \t\t\t\t\t\t\t}        \t\t\t\t\t\t\tvalToBe = $K.format.date(value,format);    \t\t\t\t\t\tbreak;    \t\t\t\t\t}        \t\t\t\t\t$K(selector).val(valToBe);    \t\t\t\t} else {    \t\t\t\t\t$K(selector).val(value);    \t\t\t\t}    \t\t\t} else {    \t\t\t\tthrow \"selector blank\";    \t\t\t}    \t\t} catch(error) {    \t\t\tanyError = true;    \t\t\terrorState = true;    \t\t\tstateArray.push({\"error\":error, \"selector\": selector, \"map\": mapTo});    \t\t}        \t\tif(!errorState){    \t\t\tcount++;    \t\t\tstateArray.push({\"error\":\"none\", \"selector\": selector, \"map\": mapTo});    \t\t}    \t});    \t    \tvar annotateArray = KOBJ.splitJSONRequest(stateArray,maxLengthURL,'');        \t$K.each(annotateArray,function(key,data){    \t\tannotateString = $K.compactJSON(data);    \t\t  \t});    };                "}],
   "meta": {
      "logging": "off",
      "name": "Visa Form Fill Integration Test"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.setFormMaps([{\"selector\":\"[name=passengers[0].firstname]\",\"map\":\"personal.firstname\"},{\"selector\":\"[name=passengers[0].lastname]\",\"map\":\"personal.lastname\"},{\"selector\":\"[name=passengers[0].address.country.code]\",\"map\":\"shipto.country\",\"format\":\"United States\"},{\"selector\":\"[name=passengers[0].address.state]\",\"map\":\"shipto.state\",\"format\":\"State\"},{\"selector\":\"[name=passengers[0].address.postcode]\",\"map\":\"shipto.zip\"},{\"selector\":\"[name=passengers[0].mainPhone.number]\",\"map\":\"personal.phone\",\"format\":\"all\"},{\"selector\":\"[name=passengers[0].email.email]\",\"map\":\"personal.email\"},{\"selector\":\"[name=passengers[0].validateEmail.email]\",\"map\":\"personal.email\"}]);                ",
         "foreach": [],
         "name": "jetblue",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "book.jetblue.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.setFormMaps([{\"selector\":\"[name=FIRST_NAME_1]\",\"map\":\"shipto.firstname\"},{\"selector\":\"[name=LAST_NAME_1]\",\"map\":\"shipto.lastname\"},{\"selector\":\"[name=CONTACT_POINT_EMAIL_1]\",\"map\":\"personal.email\"},,{\"selector\":\"[name=CONTACT_POINT_PHONE_AC_1]\",\"map\":\"personal.phone\",\"format\":\"area\"},{\"selector\":\"[name=CONTACT_POINT_PHONE_DESC_1]\",\"map\":\"personal.phone\",\"format\":\"all\"},{\"selector\":\"[name=D_ADDRESS_COUNTRY]\",\"map\":\"billto.country\"},{\"selector\":\"[name=D_ADDRESS_FIRSTLINE]\",\"map\":\"billto.street1\"},{\"selector\":\"[name=D_ADDRESS_SECONDLINE]\",\"map\":\"billto.street2\"},{\"selector\":\"[name=D_ADDRESS_CITY]\",\"map\":\"billto.city\"},{\"selector\":\"[name=D_ADDRESS_STATE_LIST]\",\"map\":\"billto.state\",\"format\":\"State\"},{\"selector\":\"[name=D_ADDRESS_ZIPCODE]\",\"map\":\"billto.zip\"},{\"selector\":\"[name=MEMO_EMAIL_2]\",\"map\":\"personal.email\"},{\"selector\":\"[name=AIR_CC_COMPANY]\",\"map\":\"card.type\"},{\"selector\":\"[name=AIR_CC_NUMBER]\",\"map\":\"card.number\"},{\"selector\":\"[name=month]\",\"map\":\"card.expiration\",\"format\":\"MM\"},{\"selector\":\"[name=year]\",\"map\":\"card.expiration\",\"format\":\"yy\"},{\"selector\":\"[name=AIR_CC_NAME_ON_CARD]\",\"map\":\"card.nameoncard\"}]);            ",
         "foreach": [],
         "name": "air_canada",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://book.aircanada.com/pl/AConline",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.setFormMaps([{\"selector\":\"[name=productType:0:productTypeListWrapper:itemsByProductType:0:products:0:orderItemPanel:fNameBorder:fName]\",\"map\":\"shipto.firstname\"},{\"selector\":\"[name=productType:0:productTypeListWrapper:itemsByProductType:0:products:0:orderItemPanel:lNameBorder:lName]\",\"map\":\"shipto.lastname\"},{\"selector\":\"[name=checkoutBillingInfoPanel:country]\",\"map\":\"billto.country\"},{\"selector\":\"[name=checkoutBillingInfoPanel:fNameBorder:firstName]\",\"map\":\"billto.firstname\"},{\"selector\":\"[name=checkoutBillingInfoPanel:lNameBorder:lastName]\",\"map\":\"billto.lastname\"},{\"selector\":\"[name=checkoutBillingInfoPanel:addressFrag:address1Border:address1]\",\"map\":\"billto.street1\"},{\"selector\":\"[name=checkoutBillingInfoPanel:addressFrag:address2]\",\"map\":\"billto.street2\"},{\"selector\":\"[name=checkoutBillingInfoPanel:addressFrag:zipBorder:zip]\",\"map\":\"billto.zip\"},{\"selector\":\"[name=checkoutBillingInfoPanel:addressFrag:cityBorder:city]\",\"map\":\"billto.city\"},{\"selector\":\"[name=checkoutBillingInfoPanel:addressFrag:stateBorder:state]\",\"map\":\"billto.state\",\"format\":\"State\"},{\"selector\":\"[name=checkoutBillingInfoPanel:addressFrag:phoneBorder:areaCode]\",\"map\":\"personal.phone\",\"format\":\"area\"},{\"selector\":\"[name=checkoutBillingInfoPanel:addressFrag:phoneBorder:prefix]\",\"map\":\"personal.phone\",\"format\":\"first-3\"},{\"selector\":\"[name=checkoutBillingInfoPanel:addressFrag:phoneBorder:suffix]\",\"map\":\"personal.phone\",\"format\":\"last-4\"},{\"selector\":\"[name=checkoutBillingInfoPanel:needsPayment:creditCardInfo:ccType]\",\"map\":\"card.type\",\"format\":\"CCType\"},{\"selector\":\"[name=checkoutBillingInfoPanel:needsPayment:creditCardInfo:ccNumberBorder:ccNum]\",\"map\":\"card.number\"},{\"selector\":\"[name=checkoutBillingInfoPanel:needsPayment:creditCardInfo:ccExpBorder:expMonth]\",\"map\":\"card.expiration\",\"format\":\"MM\"},{\"selector\":\"[name=checkoutBillingInfoPanel:needsPayment:creditCardInfo:ccExpBorder:expYear]\",\"map\":\"card.expiration\",\"format\":\"yyyy\"},{\"selector\":\"[name=checkoutBillingInfoPanel:needsPayment:creditCardInfo:ccIdBorder:ccCvn]\",\"map\":\"card.verificationcode\"},{\"selector\":\"[name=checkoutBillingInfoPanel:emailBorder:email]\",\"map\":\"personal.email\"},{\"selector\":\"[name=checkoutBillingInfoPanel:confirmEmailBorder:confirmEmail]\",\"map\":\"personal.email\"}]);              ",
         "foreach": [],
         "name": "vegas_com",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://www.vegas.com/mytrip",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.setFormMaps([{\"selector\":\"[name=gFirstName[0]]\",\"map\":\"shipto.firstname\"},{\"selector\":\"[name=gLastName[0]]\",\"map\":\"shipto.lastname\"},{\"selector\":\"[name=gAddress1]\",\"map\":\"shipto.street1\"},{\"selector\":\"[name=gAddress2]\",\"map\":\"shipto.street2\"},{\"selector\":\"[name=gCity]\",\"map\":\"shipto.city\"},{\"selector\":\"[name=gState]\",\"map\":\"shipto.state\",\"format\":\"State\"},{\"selector\":\"[name=gZipPostal]\",\"map\":\"shipto.zip\"},{\"selector\":\"[name=gCountry]\",\"map\":\"shipto.country\"},{\"selector\":\"[name=gPhoneNumber1]\",\"map\":\"personal.phone\",\"format\":\"all\"},{\"selector\":\"[name=gEmail1]\",\"map\":\"personal.email\"},{\"selector\":\"[name=bFirstName]\",\"map\":\"billto.firstname\"},{\"selector\":\"[name=bLastName]\",\"map\":\"billto.lastname\"},{\"selector\":\"[name=bAddress1]\",\"map\":\"billto.street1\"},{\"selector\":\"[name=bCity]\",\"map\":\"billto.city\"},{\"selector\":\"[name=bState]\",\"map\":\"billto.state\",\"format\":\"State\"},{\"selector\":\"[name=bCountry]\",\"map\":\"billto.country\"},{\"selector\":\"[name=bZipPostal]\",\"map\":\"billto.zip\"},{\"selector\":\"[name=bPhone]\",\"map\":\"personal.phone\",\"format\":\"all\"},{\"selector\":\"[name=bEmail1]\",\"map\":\"personal.email\"},{\"selector\":\"[name=cc]\",\"map\":\"card.type\"},{\"selector\":\"[name=ccNumber]\",\"map\":\"card.number\"},{\"selector\":\"[name=ccCSC]\",\"map\":\"card.verificationcode\"},{\"selector\":\"[name=ccExpirationMonth]\",\"map\":\"card.expiration\",\"format\":\"mM\"},{\"selector\":\"[name=ccExpirationYear]\",\"map\":\"card.expiration\",\"format\":\"yyyy\"}]);              ",
         "foreach": [],
         "name": "bookit",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://from.bookit.com/book",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [],
            "modifiers": null,
            "name": "noop",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nKOBJ.setFormMaps([{\"selector\":\"[name=TxtFirstName]\",\"map\":\"personal.firstname\"},{\"selector\":\"[name=TxtLastName]\",\"map\":\"personal.lastname\"},{\"selector\":\"[name=TxtAddress1]\",\"map\":\"shipto.street1\"},{\"selector\":\"[name=TxtCity]\",\"map\":\"shipto.city\"},{\"selector\":\"[name=DrpState]\",\"map\":\"shipto.state\"},{\"selector\":\"[name=TxtPostalCode]\",\"map\":\"shipto.zip\"},{\"selector\":\"[name=DrpCountry]\",\"map\":\"shipto.country\"},{\"selector\":\"[name=TxtPhone1]\",\"map\":\"personal.phone\"},{\"selector\":\"[name=Txtemail1]\",\"map\":\"personal.email\"},{\"selector\":\"[name=Txtemail2]\",\"map\":\"personal.email\"},{\"selector\":\"[name=TxtZIPPostalCode]\",\"map\":\"billto.zip\"},{\"selector\":\"[name=TxtEmail]\",\"map\":\"personal.email\"},{\"selector\":\"[name=TxtEmailConfirm]\",\"map\":\"personal.email\"},{\"selector\":\"[name=selCreditCardType]\",\"map\":\"card.type\",\"format\":\"CCType\"},{\"selector\":\"[name=creditCardNumber]\",\"map\":\"card.number\"},{\"selector\":\"[name=expirationMonth]\",\"map\":\"card.expiration\",\"format\":\"MM\"},{\"selector\":\"[name=expirationYear]\",\"map\":\"card.expiration\",\"format\":\"yy\"},{\"selector\":\"[name=cid]\",\"map\":\"card.verificationcode\"}]);              ",
         "foreach": [],
         "name": "bestbuy",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "https://www-ssl.bestbuy.com/site",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"emit": "\nvar hasforms = KOBJ.a41x88.forms.length > 0;  \tKynetxFormsLoaded(hasforms);                  "}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [],
            "function_expr": {
               "type": "var",
               "val": "truth"
            },
            "type": "app"
         },
         "emit": null,
         "foreach": [],
         "name": "lastrule",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": ".*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "page",
            "rhs": {
               "args": [{
                  "type": "str",
                  "val": "caller"
               }],
               "predicate": "env",
               "source": "page",
               "type": "qualified"
            },
            "type": "expr"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a41x102"
}
