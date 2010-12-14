// UTF-8 characters
ruleset a144x49 {
    meta {
        name "i18n_dupe_for_rulesetm"
        description <<
Unicode variable support
>>
        logging on
    }
    dispatch {
        domain "kynetx.com"
        domain "baconsalt.com"
        domain "jdfoods.net"
        domain "w3.org"
    }
    global {
        rusg = "Моё судно на воздушной подушке полно угрей";        
        hang = "隻氣墊船裝滿晒鱔";        
        perg = "هاورکرافت من پر مارماهى است";        
        greg = "Το Χόβερκράφτ μου είναι γεμάτο χέλια";        
        malg = "എന്റെ പറക്കും-പേടകം നിറയെ വ്ളാങ്ക ുകളാണു";        
        dataset i18n_ds <- "http://frag.kobj.net/clients/cs_test/i18n.xml" cachable for 5 seconds
;    }
    rule i18n_rule is active {
        select using ".*" setting()

        pre {
            rusp = "Моё судно на воздушной подушке полно угрей";
            hanp = "隻氣墊船裝滿晒鱔";
            perp = "هاورکرافت من پر مارماهى است";
            grep = "Το Χόβερκράφτ μου είναι γεμάτο χέλια";
            foo = {"foo" : 5};
        }
        every {
            notify("This is Persian: ", perp)
            with
                    sticky = true and
                    opacity = 1;
            notify("This is Russian: ", rusp)
            with
                    sticky = true and
                    opacity = 1;
            notify("This is Chinese: ", hanp)
            with
                    sticky = true and
                    opacity = 1;
            notify("This is Greek: ", grep)
            with
                    sticky = true and
                    opacity = 1;
            replace_inner(".headline:eq(0)>h3>span>a", malp);
        }
    }

}