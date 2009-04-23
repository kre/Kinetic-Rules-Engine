var Pilot = {
    status: false,
    tm_status: false,
    sites: new Array(0),
    kynetx_js_host: 'http://init.kobj.net',
//  required_scripts: ['prototype','effects','dragdrop','kobj-extras'],
    required_scripts: ['kobj-static'],
    kobj_version: '0.9',
    myip: '',

  // ex cookie:
  // [ { domain:'', site_id: }, ... ]

  init: function() {
    c = this.getSitesPref();
    if (typeof(c) == 'undefined' || c == '') this.sites = new Array(0);
    else this.sites = eval(c);
  },

  getSitesPref: function() {
    var prefs = Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefBranch);

    var fsites;
    if (prefs.getPrefType("browser.fsites") == prefs.PREF_STRING){
      fsites = prefs.getCharPref("browser.fsites");
    } else fsites = '';

    return fsites;
  },

  setSitesPref: function(value) {
    var prefs = Components.classes["@mozilla.org/preferences-service;1"].getService(Components.interfaces.nsIPrefBranch);

    prefs.setCharPref("browser.fsites",value);
  },

  updateSites: function() {
    // creates a JSON version of the sites array
    c  = '[ ';
    for (var s = 0; s < this.sites.length; s++) {
      c +=
	"{ " + "domain:'" + this.sites[s]['domain'] +
	"', site_id: '" + this.sites[s]['site_id'] +
	"', datasets: '" + this.sites[s]['datasets'] +
	"' }";
      if(s < this.sites.length - 1) c += ", ";
    }
    c += ' ]';
//    alert("The sites JSON is " + c + "\n");
    this.setSitesPref(c);
  },

  toggle: function() {
    this.status = !this.status;
    this.refreshStatus();
  },

  refreshStatus: function() {
    var statusImage = document.getElementById('pilot-status-image');
    var menuItem = document.getElementById('pilot-status-image');
    var menuItem = document.getElementById('tog_menu');
    var contextmenuItem = document.getElementById('tog_contextmenu');

    if (this.status) {
      statusImage.tooltipText = "Kynetx Pilot is enabled.";
      statusImage.src = "chrome://pilot/content/status_on.gif";
      menuItem.label = "Disable Pilot";
      contextmenuItem.label = "Disable Pilot";
    } else {
      statusImage.tooltipText = "Kynetx Pilot is disabled.";
      statusImage.src = "chrome://pilot/content/status_off.gif";
      menuItem.label = "Enable Pilot";
      contextmenuItem.label = "Enable Pilot";
    }
  },

    toggle_test_mode: function() {
	this.tm_status = !this.tm_status;
	this.refreshTestModeStatus();
    },

   refreshTestModeStatus: function() {
     var menuItem = document.getElementById('tog_tm_menu');
     var contextmenuItem = document.getElementById('tog_tm_contextmenu');

     if (this.tm_status) {
       menuItem.label = "Disable Test Mode";
       contextmenuItem.label = "Disable Test Mode";
     } else {
       menuItem.label = "Enable Test Mode";
       contextmenuItem.label = "Enable Test Mode";
     }
   },


  facilitate: function(refresh) {
     if(this.sites.length>0 && this.status) {
       doc = window._content.document;
       body = doc.getElementsByTagName('body')[0];
       // The 'facilitated' flag is to fix a bug that is likely caused
       // when an IFRAME on a page triggers the document's onload event twice,
       // causing the script tags to be loaded twice
       var script;
       if (body.facilitated != true || refresh == true) {



	 var sites = [];

         for (var s = 0; s < this.sites.length; s++) {
           var site = this.sites[s];
           var regex = new RegExp(site['domain'],"gi");
           if(site['domain'] != '' && doc.domain.match(regex)) {
	     sites.push(site['site_id']);
               body.facilitated = true;
           }
         }

	 // nothing to do here....
	 if(!body.facilitated) {
	   return;
	 }



	 // FIXME: this isn't quite right...
	 var eval_host;
	 if (this.kynetx_js_host == "http://127.0.0.1") {
	   eval_host = "127.0.0.1";
	 } else {
	   eval_host = "cs.kobj.net";
	 }

	 var init_obj = '{"eval_host" : \"' + eval_host + '",';
	 if (eval_host == "127.0.0.1") {
	   init_obj += '"callback_host":"127.0.0.1",';
	 } else {
	   init_obj += '"callback_host":"log.kobj.net",';
	 };
	 if (eval_host == "127.0.0.1") {
	   init_obj += '"init_host":"127.0.0.1"';
	 } else {
	   init_obj += '"init_host":"init.kobj.net"';
	 };
	 init_obj += '}';


	 // add parameters
         var p = ['"rids":["'+ sites.join('","') + '"]'];
         p.push('"init" : ' + init_obj);
         if(this.tm_status) {
           p.push('"mode":"test"');
         }
	 if(this.myip != '') {
	   p.push('"ip":"' + this.myip + '"');
	 }
         for (var s = 0; s < this.sites.length; s++) {
           var site = this.sites[s];
           if(site['datasets'] != '') {
              p.push('"'+ site['site_id'] + ':datasets":"' + site['datasets'] + '"');
	    }
         }
	 var p_str ;
         p_str = '{' + p.join(',') + '}';


         script = doc.createElement('script');
         script.type = 'text/javascript';
//         script.src = this.kynetx_js_host + '/js/' + sites.join(';') + '/kobj.js';
//	 script.innerHTML = 'function startKJQuery() {if(typeof(KOBJ.init) !== "undefined"){\$K.isReady = true;} else {setTimeout("startKJQuery()", 20);}};startKJQuery();\n';
//	 script.innerHTML += 'var KOBJ_config ='+init_obj+';\n';
	 script.innerHTML += 'var KOBJ_config =' + p_str + ';\n';

	 // // force jQuery to believe the DOM is ready
         // script = doc.createElement('script');
         // script.type = 'text/javascript';
         // script.innerHTML = 'jQuery.isReady = true;'
         // body.appendChild(doc.createTextNode("\n"));
         // body.appendChild(script);


         body.appendChild(doc.createTextNode("\n"));
         body.appendChild(script);

	 // Add required js libraries once
         for (var r = 0; r < this.required_scripts.length; r++) {
           script = doc.createElement('script');
           script.type = 'text/javascript';
           script.src = this.kynetx_js_host + '/js/shared/' + this.required_scripts[r] + '.js';
//	   script.onerror = 'throw("KOBJ shared library error: " + this.src)';
           body.appendChild(doc.createTextNode("\n"));
           body.appendChild(script);
           }


       }
       body.appendChild(doc.createTextNode("\n"));
     }
  },

  add: function() {
    new_site = {}
    new_site['domain'] = prompt("Enter the domain (ie www.target.com) that you wish to Kynetxify:","");
    new_site['site_id'] = prompt("Enter the Kynetx site id:","1");
    new_site['datasets'] = prompt("Enter any data sets (comma separated):","");

    this.sites.push(new_site);
    this.updateSites();
  },

  changeHosts: function() {
    var regex = /\/$/g;

    this.kynetx_js_host = prompt("Enter the initilization host:","http://init.kobj.net").replace(regex, '');
      this.kobj_version = prompt("Enter the JS version:",this.kobj_version).replace(regex, '');
  },

  changeIP: function(newip) {

      if(newip != '') {
	  this.myip = newip
      } else {

	  this.myip = prompt("Enter the IP address you'd like to be from:","");
      }

  },

  list: function() {
    if (this.sites.length<1) alert('You have no sites to pilot right now.');
    else {
	var site_array = new Array(0);
	for (s = 0; s < this.sites.length; s++) {
            site = this.sites[s];
            if (site['domain'] != '')  {

		var site_str =
		    site['domain'] +
		    " (site id = " +
		    site['site_id'];

		if(site['datasets'] != '') {
		    site_str +=
		    ", datasets = " +
			site['datasets'] +
			")";
		} else {
		    site_str += ")";
		}

		site_array.push(site_str);
	    }

            else
	    site_array.push('bogus domain (site id = '+site['site_id']+')');
	}
	var msg = site_array.join(' \n')+'\nJS Host: '+this.kynetx_js_host+'\n';
	if(this.myip) {
	    msg = msg + 'IP address: ' + this.myip;
	}
	alert(msg);
    }
  },

  clear: function() {
    this.sites = new Array(0);
    this.updateSites();
    alert('Sites cleared out.');
  },

//   getLocationInfo: function(url, request, cb) {
//     var http = new XMLHttpRequest();
//     // pjw commented out the next line...
//     //http.open("GET","http://127.0.01/js/geoip.js",true);
//     http.onreadystatechange = function(){
//       if (http.readyState==4) var resp = http.responseText; // get the response if it was a success
//       if(resp != null){
//         eval("var info = " + resp); // turn the string of JSON into a real JSON object
//         // is there a better XUL solution than putting each one in a menuitem?
//         // display them all
//         document.getElementById('location_info_ip_context_menu').style.display = 'block';
//         document.getElementById('location_info_country_name_context_menu').style.display = 'block';
//         document.getElementById('location_info_country_code_context_menu').style.display = 'block';
//         document.getElementById('location_info_region_context_menu').style.display = 'block';
//         document.getElementById('location_info_city_context_menu').style.display = 'block';
//         document.getElementById('location_info_postal_code_context_menu').style.display = 'block';
//         document.getElementById('location_info_dma_code_context_menu').style.display = 'block';
//         document.getElementById('location_info_area_code_context_menu').style.display = 'block';
//         document.getElementById('location_info_context_menu').style.display = 'none';
//         // give them labels
//         document.getElementById('location_info_ip_context_menu').label = "IP: " + info.ip_addr;
//         document.getElementById('location_info_country_name_context_menu').label = "Country: " + info.country_name;
//         document.getElementById('location_info_country_code_context_menu').label = "Country Code: " + info.country_code;
//         document.getElementById('location_info_region_context_menu').label = "Region: " + info.region;
//         document.getElementById('location_info_city_context_menu').label = "City: " + info.city;
//         document.getElementById('location_info_postal_code_context_menu').label = "Postal Code: " + info.postal_code;
//         document.getElementById('location_info_dma_code_context_menu').label = "DMA Code: " + info.dma_code;
//         document.getElementById('location_info_area_code_context_menu').label = "Area Code: " + info.area_code;
//       } else {
//         document.getElementById('location_info_context_menu').label = 'N/A';
//         document.getElementById('location_info_context_menu').style.display = 'block';
//         document.getElementById('location_info_ip_context_menu').style.display = 'none';
//         document.getElementById('location_info_country_name_context_menu').style.display = 'none';
//         document.getElementById('location_info_country_code_context_menu').style.display = 'none';
//         document.getElementById('location_info_region_context_menu').style.display = 'none';
//         document.getElementById('location_info_city_context_menu').style.display = 'none';
//         document.getElementById('location_info_postal_code_context_menu').style.display = 'none';
//         document.getElementById('location_info_dma_code_context_menu').style.display = 'none';
//         document.getElementById('location_info_area_code_context_menu').style.display = 'none';
//       }
//     };
//     http.send(null);
//   }

}

Pilot.init();