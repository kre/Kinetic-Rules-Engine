var Pilot = {
    status: false,
    tm_status: false,
    sites: new Array(0),
    kynetx_js_proto: 'http',
    kynetx_js_host: 'init.kobj.net',
//  required_scripts: ['prototype','effects','dragdrop','kobj-extras'],
    required_scripts: ['kobj-static'],
    kobj_version: '1.0',
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

	 var init_host = this.kynetx_js_host;

	 init_host = init_host.replace(/http(s)?:\/\//,"");

	 var eval_host;
	 var cb_host;

	 if (init_host == "init.kobj.net") {
	   eval_host = "cs.kobj.net";
	   cb_host = "log.kobj.net";
	 } else {
	   eval_host = init_host;
	   cb_host = init_host;
	 }


	 var init_obj = '{';
	 init_obj += '"init_host" : \"' + init_host + '",';
	 init_obj += '"eval_host" : \"' + eval_host + '",';
	 init_obj += '"callback_host":"' + cb_host + '"';
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
	 script.innerHTML += 'var KOBJ_config =' + p_str + ';\n';

         body.appendChild(doc.createTextNode("\n"));
         body.appendChild(script);

	 var proto = (("https:" == window._content.location.protocol) ? "https://" : "http://");

	 this.kynetx_js_host = proto + init_host;

	 // Add required js libraries once
         for (var r = 0; r < this.required_scripts.length; r++) {
           script = doc.createElement('script');
           script.type = 'text/javascript';
           script.src = this.kynetx_js_host + '/js/shared/' + this.required_scripts[r] + '.js';
           body.appendChild(doc.createTextNode("\n"));
           body.appendChild(script);
	 }
       }
	 body.appendChild(doc.createTextNode("\n"));
     }
  },

  add: function() {
    new_site = {};
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

};

try {
  Pilot.init();
}catch(e){
  try{
    if(e.stack){
      Components.utils.reportError(e.stack);
    }
    // Show the error console.
    toJavaScriptConsole();
  }finally{
    throw e;
  }
}
