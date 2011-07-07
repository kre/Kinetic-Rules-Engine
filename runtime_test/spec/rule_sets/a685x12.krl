ruleset a685x12 {
    meta {
        name "AutoJAM Tests"
        logging on
    }
    dispatch {
        domain "yahoo.com"
        domain "bing.com"
        domain "google.com"
        domain "cnn.com"
        domain "chevelle.confettiantiques.com"
    }
    global {
        css  <<#KOBJ_replace {background-color: black;}        >>
;    }
    rule alert is inactive {
        select using "[^chevelle]\w+" setting()

        alert("KOBJ_alert");
    }
    rule after is active {
        select using ".*" setting()

        after("body", "<span id='KOBJ_after'>KOBJ_after</span>");
    }
    rule append is active {
        select using ".*" setting ()

        append("body", "<div id='KOBJ_app_bef_aft_test'><span id='KOBJ_append'>KOBJ_append</span></div>");
    }
    rule before is active {
        select using ".*" setting()

        before("#KOBJ_append", "<span id='KOBJ_before'>KOBJ_before</span>");
    }
    rule float is active {
        select using ".*" setting()

        float("absolute", "top:10px", "right:10px", "http://k-misc.s3.amazonaws.com/random/test/annotate.html");
    }
    rule float_html is active {
        select using ".*" setting()

        float_html("absolute", "bottom:10px", "left:10px", "<span id='KOBJ_float_html'>KOBJ_float_html</span>");
    }
    rule move_after is active {
        select using ".*" setting()

        move_after("#KOBJ_before", "#KOBJ_after");
    }
    rule move_to_top is active {
        select using ".*" setting()

        move_to_top("#KOBJ_float_html");
    }
    rule notify is active {
        select using ".*" setting()

        notify("KOBJ_test", "<div id='KOBJ_notify'><h3>KOBJ_notify</h3></div>")
        with
                sticky = true;
    }
    rule prepend is active {
        select using ".*" setting()

        prepend("#KOBJ_float_html", "<span id='KOBJ_prepend'>KOBJ_prepend</span>");
    }
    rule replace is active {
        select using ".*" setting()

        every {
            append("body", "<div id='KOBJ_test_replace'>KOBJ_test_replace</div>");
            replace("#KOBJ_test_replace", "http://k-misc.s3.amazonaws.com/resources/a41x27/popup.html");
        }
    }
    rule replace_html is active {
        select using ".*" setting()

        replace_html("#KOBJ_replace_html", "<div id='KOBJ_replace'>This has been replaced</div>");
    }
    rule replace_image_src is active {
        select using ".*" setting()

        replace_image_src("#KOBJ_image", "http://k-misc.s3.amazonaws.com/resources/a41x27/image-2.jpg");
    }
    rule popup is inactive {
        select using ".*" setting()

        popup(250, 250, 600, 600, "http://www.kynetx.com");
    }
    rule close_notification is active {
        select using ".*" setting()

        every {
            notify("KOBJ_close_test", "<div id='KOBJ_close_test'>KOBJ_close</div>")
            with
                    sticky = true;
            close_notification("#KOBJ_close_test");
        }
    }
//    rule let_it_snow is active {
//        select using ".*" setting()
//
//       let_it_snow();
//    }

}