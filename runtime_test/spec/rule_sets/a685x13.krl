ruleset a685x13 {
    meta {
        name "Search Annotate Test"
        description <<
Annotates Google Search
>>
        logging off
    }
    dispatch {
        domain "google.com"
        domain "bing.com"
        domain "yahoo.com"
    }
    rule annotate is active {
        select using "food.84660" setting()

        emit <<
KOBJ.tempCount = 0;    function test_selector(obj){     string = '<div id="KOBJ_append'+KOBJ.tempCount+'">Domain'+KOBJ.tempCount+':'+$K(obj).data("domain")+'</div>';           KOBJ.tempCount++;       return string;  }            >>
        annotate_search_results(test_selector);
    }
    rule remote_annotate is active {
        select using "burgers.84660" setting()

        annotate_search_results()
        with
                remote = "http://chevelle.caandb.com/annotate_remote.php?jsoncallback=?";
    }
    rule local is active {
        select using "food.*84660" setting()

        emit <<
KOBJ.tempCountLocal = 0;    function test_selector(obj){        string = '<div id="KOBJ_append_local'+KOBJ.tempCountLocal+'">Phone'+KOBJ.tempCountLocal+':'+$K(obj).data("phone")+'</div>';             KOBJ.tempCountLocal++;          return string;  }            >>
        annotate_local_search_results(test_selector);
    }
    rule remote_local is active {
        select using "burgers.*84660" setting()

        annotate_local_search_results()
        with
                remote = "http://chevelle.caandb.com/annotate_remote.php?jsoncallback=?";
    }
    rule percolate is active {
        select using "furniture" setting()

        emit <<
test_data = {           "www.eco-furniture.com" : {}    };              function test_selector(obj){            var host = $K(obj).data("domain");                              var o = test_data[host];                if(o){                          return true;            } else {                        return false;           }       }                             >>
        percolate(test_selector);
    }

}