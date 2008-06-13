var Pilot = {
  status: false,
  sites: new Array(0),
  kynetx_js_host: 'http://init.kobj.net',
  main_js_host: 'http://init.kobj.net',
//  required_scripts: ['prototype','effects','dragdrop','kobj-extras'],
  required_scripts: ['kobj-static'],
  kobj_version: '0.8',

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
    c  = '[ ';
    for (var s = 0; s < this.sites.length; s++) {
      c += "{ " + "domain:'" + this.sites[s]['domain'] + "', site_id:" + this.sites[s]['site_id'] + " }";
      if(s < this.sites.length - 1) c += ", ";
    }
    c += ' ]';
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

  facilitate: function(refresh) {
     if(this.sites.length>0 && this.status) {
       doc = window._content.document;
       body = doc.getElementsByTagName('body')[0];
       // The 'facilitated' flag is to fix a bug that is likely caused
       // when an IFRAME on a page triggers the document's onload event twice,
       // causing the script tags to be loaded twice
       if (body.facilitated != true || refresh == true) {
         for (var s = 0; s < this.sites.length; s++) {
           site = this.sites[s];
           regex = new RegExp(site['domain'],"gi");
           if(site['domain'] != '' && doc.domain.match(regex)) {
             // Add required js libraries
             for (var r = 0; r < this.required_scripts.length; r++) {
               script = doc.createElement('script');
               script.type = 'text/javascript';
               script.src = this.kynetx_js_host + '/js/' +
		     site['site_id'] + '/' + this.required_scripts[r] + '.js';
               body.appendChild(doc.createTextNode("\n"));
               body.appendChild(script);
             }
         
             // Add kobj.js
             script = doc.createElement('script');
             script.type = 'text/javascript';
             script.src = this.main_js_host + '/js/' + site['site_id'] + '/kobj.js';
             body.appendChild(doc.createTextNode("\n"));
             body.appendChild(script);
             body.facilitated = true;
           }
         }
       }
       body.appendChild(doc.createTextNode("\n"));
     } 
  },

  add: function() {
    new_site = {}
    new_site['domain'] = prompt("Enter the domain (ie www.target.com) that you wish to Kynetxify:","");
    new_site['site_id'] = prompt("Enter the Kynetx site id:","1");

    this.sites.push(new_site);
    this.updateSites();
  },
  
  changeHosts: function() {
    var regex = /\/$/g;
    
    this.kynetx_js_host = prompt("Enter the host for the kynetx.js file:","http://init.kobj.net").replace(regex, '');
    this.main_js_host = prompt("Enter the host for the kobj.js file:","http://init.kobj.net").replace(regex, '');
    this.kobj_version = prompt("Enter the JS version:","0.8").replace(regex, '');
  },

  list: function() {
    if (this.sites.length<1) alert('You have no sites to pilot right now.');
    else {
      var site_array = new Array(0);
      for (s = 0; s < this.sites.length; s++) {
        site = this.sites[s];
        if (site['domain'] != '') site_array.push(site['domain'] + " (site id = "+site['site_id']+")"); 
        else site_array.push('bogus domain (site id = '+site['site_id']+')');
      }
      alert(site_array.join(' \n')+'\n'+this.kynetx_js_host+'\n');
    }
  },

  clear: function() {
    this.sites = new Array(0);
    this.updateSites();
    alert('Sites cleared out.');
  },
  
  getLocationInfo: function(url, request, cb) {
    var http = new XMLHttpRequest();
    // pjw commented out the next line...
    //http.open("GET","http://127.0.01/js/geoip.js",true);
    http.onreadystatechange = function(){
      if (http.readyState==4) var resp = http.responseText; // get the response if it was a success
      if(resp != null){
        eval("var info = " + resp); // turn the string of JSON into a real JSON object
        // is there a better XUL solution than putting each one in a menuitem?
        // display them all
        document.getElementById('location_info_ip_context_menu').style.display = 'block';
        document.getElementById('location_info_country_name_context_menu').style.display = 'block';
        document.getElementById('location_info_country_code_context_menu').style.display = 'block';
        document.getElementById('location_info_region_context_menu').style.display = 'block';
        document.getElementById('location_info_city_context_menu').style.display = 'block';
        document.getElementById('location_info_postal_code_context_menu').style.display = 'block';
        document.getElementById('location_info_dma_code_context_menu').style.display = 'block';
        document.getElementById('location_info_area_code_context_menu').style.display = 'block';
        document.getElementById('location_info_context_menu').style.display = 'none';
        // give them labels
        document.getElementById('location_info_ip_context_menu').label = "IP: " + info.ip_addr;
        document.getElementById('location_info_country_name_context_menu').label = "Country: " + info.country_name;
        document.getElementById('location_info_country_code_context_menu').label = "Country Code: " + info.country_code;
        document.getElementById('location_info_region_context_menu').label = "Region: " + info.region;
        document.getElementById('location_info_city_context_menu').label = "City: " + info.city;
        document.getElementById('location_info_postal_code_context_menu').label = "Postal Code: " + info.postal_code;
        document.getElementById('location_info_dma_code_context_menu').label = "DMA Code: " + info.dma_code;
        document.getElementById('location_info_area_code_context_menu').label = "Area Code: " + info.area_code;
      } else {
        document.getElementById('location_info_context_menu').label = 'N/A';
        document.getElementById('location_info_context_menu').style.display = 'block';
        document.getElementById('location_info_ip_context_menu').style.display = 'none';
        document.getElementById('location_info_country_name_context_menu').style.display = 'none';
        document.getElementById('location_info_country_code_context_menu').style.display = 'none';
        document.getElementById('location_info_region_context_menu').style.display = 'none';
        document.getElementById('location_info_city_context_menu').style.display = 'none';
        document.getElementById('location_info_postal_code_context_menu').style.display = 'none';
        document.getElementById('location_info_dma_code_context_menu').style.display = 'none';
        document.getElementById('location_info_area_code_context_menu').style.display = 'none';
      }
    };
    http.send(null);
  }  
}

Pilot.init();