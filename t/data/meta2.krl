// dispatch with some rules
ruleset 10 {

    meta {
      description <<
      Ruleset for testing something or other.
      >>
    }

    dispatch {
      domain "www.google.com" -> "966337974";
      domain "google.com" -> "966337974";
      domain "www.circuitcity.com" -> "966337982";
    }

    global {
      emit <<
var pagename = 'foobar';
      >>;

    }

    rule testa is active {
        select using "/test/" setting()
        pre { 
        } 
        replace("test","test");
    }

    rule testb is active {
        select using "/test/" setting()
        pre { 
        } 
        replace("test","test");
    }


}
