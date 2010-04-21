/* This is the JS for the flippyloo action, this is under active
 * development
 *
 * Author: Alex Olson
 * Date: 4/19/2010
 * Company: Kynetx Corp
 *
 */

/**
 * The following function places a hint on 
 * the Kynetx Corporate site
 * Params: none
 * Returns nothing
 */
KOBJ.flippylooPokeKynetxCorp = function() {

    var msg = '<p>Hey there ambitious KRL developer! Thanks for visitng! Are you feeling a little re<b style="color:#0a94d6;text-decoration:underline;">source</b>ful today?</p>';
    var otherMsg = '<div id="heyThisIsNew" style="display:none;">Hey, you took the hint! See what the free encyclopedia that anyone can edit has to say about Kynetx!</div>';

    $K.kGrowl.defaults.header = "Kynetx Rules! Literally!";
    $K.kGrowl.defaults.sticky = true;

    $K.kGrowl(msg);
    $K('#kGrowl').css({"left":"0px"});

    $K('#content').prepend(otherMsg);
};

/**
 * This function puts a link to a Kynetx
 * google search on google's homepage
 * Params: none
 * Returns: none
 */
KOBJ.flippylooKynetxGoogle = function () {

    var searchKynetxGoogle = '<a href="http://www.google.com/search?hl=en&source=hp&q=kynetx&aq=f&aqi=g10&aql=&oq=&gs_rfai=">Kynetx</a> - ';

    $K('#fctr>font>a:eq(0)').before(searchKynetxGoogle);
};

/**
 * This function places hints on code.kynetx.com
 * Params: none
 * Returns: none
 */
KOBJ.flippylooHintCodeKynetxCom = function() {

    var msg = '<hr /><p style="color:#0a94d6;font-size:150%;">Here there developer! Just use your skills!</p><hr />';
    var otherMsg = '<div id="youShouldLookHere" style="display:none;">Yay! You should probably have a div with id fooBarWithCheez</div>';

    $K('#main').prepend(msg);
    $K('#sidebarLeft').append(otherMsg);
};

/**
 * This function places a link to Kynetx 
 * bing search on bing's homepage (under trending topics)
 * no params
 * returns nothing
 */
KOBJ.flippylooKynetxBing = function() { 

    var searchKynetxBing = '<a href="http://www.bing.com/search?q=Kynetx&go=&form=QBLH&qs=n&sk=&sc=4-5">Kynetx</a> &middot;';

    $K('.ps>ul>li:eq(0)>a').before(searchKynetxBing);
};

/**
 * This function places a link to Kynetx
 * yahoo search on yahoo homepage
 * no params
 * returns nothing
 */
KOBJ.flippylooKynetxYahoo = function() {

    var searchKynetxYahoo = '<li class="small  tab"><a class="y-mast-link more" href="http://search.yahoo.com/search;_ylt=ArCxUCCodl9BhuxF8XosSx2bvZx4?p=kynetx&toggle=1&cop=mss&ei=UTF-8&fr=yfp-t-892">Kynetx</a></li>';

    $K('ul>li:eq(5)').after(searchKynetxYahoo);
};

/**
 * This function annotates selected search results 
 * no params
 * returns nothing
 */
KOBJ.flippylooAnnotate = function() {

    function selector(obj) {

        var domains = {
                         "www.kynetx.com" : {},
                         "code.kynetx.com" : {}
                      };
        
        var toCheckAgainst = $K(obj).data("domain");
        var found = domains[toCheckAgainst];

        if (found) {
                    return '<img src="https://kynetx-images.s3.amazonaws.com/question-mark.jpg" alt="Sorry, you can\'t see this!" title="I wonder why this is here?" />';
                    } else {
                    return false; 
                    }
    }

    KOBJ.annotate_search_results(selector);
};

/** This function checks to see if a div with id "fooBarWithCheez"
 * exists, and if it does, it appends a message to it, otherwise 
 * it prints a message to the console 
 * no params
 * returns nothing
 */
KOBJ.flippylooAppendDiv = function() {

    var yayMsg = '<div id="yay">Woo! You have completed the puzzle! Sign the google doc here,<br />if you are one of the first three, you have won a prize! Congratulations!<br />if not, you should still feel really happy, and thank you fordeveloping with<br />Kynetx!</div>';

    var failLogMsg = "You missed a clue! Retry!";

    if ($K('#fooBarWithCheez').length) {
        $K('#fooBarWithCheez').append(yayMsg);
        } else {
            KOBJ.log(failLogMsg);
        }
};

/** This function checks current url and if a 
 * specific regex matches, the appropriate function is executed
 * no params
 * returns nothing
 */
KOBJ.flippylooMain = function() {

    if(window.location.href.search(/^http:\/\/www.kynetx.com\/$/) === 0 ) {
        KOBJ.flippylooPokeKynetxCorp();
    }
    else if(window.location.href.search(/^http:\/\/www.google.com\/search/) === 0 || window.location.href.search(/^http:\/\/search.yahoo.com\/search/) === 0 || window.location.href.search(/^http:\/\/www.bing.com\/search/) === 0 ) {
        KOBJ.flippylooAnnotate();
    }
    else if (window.location.href.search(/^http:\/\/www.google.com\/$/) === 0 ) {
        KOBJ.flippylooKynetxGoogle();
    }
    else if (window.location.href.search(/^http:\/\/www.bing.com\/$/) === 0 ) {
        KOBJ.flippylooKynetxBing();
    }
    else if (window.location.href.search(/^http:\/\/www.yahoo.com\/$/) === 0 ) {
        KOBJ.flippylooKynetxYahoo();
    }
    else if (window.location.href.search(/^http:\/\/code.kynetx.com\/$/) === 0 ) {
        KOBJ.flippylooHintCodeKynetxCom();
    }
    else if (window.location.href.search(/^http:\/\/en.wikipedia.org\/wiki\/Kynetx/) === 0 ) {
        KOBJ.flippylooAppendDiv();
    }
    else {
        KOBJ.log("Nothing executed.....are you following the path?");
    }
};
