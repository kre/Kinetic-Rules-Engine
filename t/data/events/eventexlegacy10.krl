ruleset a22x2 {
  meta {
    name "ClearPlay"
    author "Dave McNamee"
    logging on    
  }
  dispatch {
    domain "netflix.com"
    domain "imdb.com"
  }
  global {
    datasource clearplay:HTML <- "http://clearplay.com/filtercart.aspx?" cachable for 1 days;
 
 
    css  <<
      #clearPlayWrapper { 
        width: 100%;
        margin-top: 10px;
      }
 
      #clearPlay {
        margin: 0 auto;
        width: 524px;
      }
 
      #clearPlayLogo {
        float: left;
      }
 
      #clearPlayFilter {
        float: left;
      }
 
      #clearPlayQueue {
        float: left;
      }
 
      #clearPlayIMDb {
        float: left;
      }
    >>;
  }
 
  rule netflix is active {
    select when web pageview "http://www.netflix.com/Movie/(.*?)/" setting(title)
 
      pre {
 
        messageAvailable = << 
          <div id="clearPlayWrapper" style="margin-bottom: 8px;"> 
            <div id="clearPlay"> 
              <div id="clearPlayLogo"> 
                <a href="http:\/\/www.clearplay.com"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppLogo.gif" alt="clearPlayLogo" /> 
                </a> 
              </div> 
              <div id="clearPlayFilter"> 
                <a target="_blank" href="#{clearPlayLink}"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownload.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownloadOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownload.gif'" /> 
                </a> 
              </div> 
              <div id="clearPlayQueue"> 
                <a target='_blank' href='https:\/\/www.netflix.com/Login'> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueue.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueueOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueue.gif'" /> 
                </a> 
              </div> 
              <div id="clearPlayIMDb"> 
                <a target="_blank" href="#{imdbLink}"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDb.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDbOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDb.gif'" /> 
                </a> 
              </div> 
              <br clear="left" /> 
            </div> 
          </div>      
        >>;
 
        messageNotAvailable = << 
          <div id="clearPlayWrapper" style="margin-bottom: 8px;"> 
            <div id="clearPlay"> 
              <div id="clearPlayLogo"> 
                <a href="http://www.clearplay.com"><img src="http://k-misc.s3.amazonaws.com/resources/a22x2/cpAppLogo.gif" alt="Clear Play Logo" /></a> 
              </div> 
              <div id="clearPlayFilter"> 
                <a target="_blank" href="https://www.clearplay.com/signin.aspx?returnurl=MovieRequest.aspx"><img src="http://k-misc.s3.amazonaws.com/resources/a22x2/cpAppNoFilter.gif" alt="Clear Play Filter" /></a> 
              </div><br clear="left" /> 
            </div> 
          </div> 
 
        >>;
 
        titleNew = ((title.replace(re/^the/i, "")).replace(re/-/g, " ")).replace(re/^\s+/, "");
        clearPlay = datasource:clearplay({"SearchValue" : titleNew});
        rows = clearPlay.query("table#search_results tr");
        imdbLink = "http://www.imdb.com/find?s=all&q=#{titleNew}";
        clearPlayLink = "http://clearplay.com/filtercart.aspx?SearchValue=#{titleNew}";
        message = rows.length() => messageAvailable | messageNotAvailable;
 
      }
 
      {
        prepend("#page-content",message);
      }
  }
 
  rule netflix_logged_in is active {
    select when web pageview "http://movies.netflix.com/.*?Movie/(.*)/" setting(title)
 
      pre {
 
        messageAvailable = << 
          <div id="clearPlayWrapper" style="margin-bottom: 10px; margin-top: -10px;"> 
            <div id="clearPlay"> 
              <div id="clearPlayLogo"> 
                <a href="http:\/\/www.clearplay.com"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppLogo.gif" alt="clearPlayLogo" /> 
                </a> 
              </div> 
              <div id="clearPlayFilter"> 
                <a target="_blank" href="#{clearPlayLink}"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownload.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownloadOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownload.gif'" /> 
                </a> 
              </div> 
              <div id="clearPlayQueue"> 
                <a target='_blank' href='https:\/\/www.netflix.com/Login'> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueue.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueueOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueue.gif'" /> 
                </a> 
              </div> 
              <div id="clearPlayIMDb"> 
                <a target="_blank" href="#{imdbLink}"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDb.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDbOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDb.gif'" /> 
                </a> 
              </div> 
              <br clear="left" /> 
            </div> 
          </div>      
        >>;
 
        messageNotAvailable = << 
          <div id="clearPlayWrapper" style="margin-bottom: 10px; margin-top: -10px;"> 
            <div id="clearPlay"> 
              <div id="clearPlayLogo"> 
                <a href="http://www.clearplay.com"><img src="http://k-misc.s3.amazonaws.com/resources/a22x2/cpAppLogo.gif" alt="Clear Play Logo" /></a> 
              </div> 
              <div id="clearPlayFilter"> 
                <a target="_blank" href="https://www.clearplay.com/signin.aspx?returnurl=MovieRequest.aspx"><img src="http://k-misc.s3.amazonaws.com/resources/a22x2/cpAppNoFilter.gif" alt="Clear Play Filter" /></a> 
              </div> 
              <br clear="left" /> 
            </div> 
          </div> 
 
        >>;
 
        titleNew = ((title.replace(re/^the/i, "")).replace(re/-/g, " ")).replace(re/^\s+/, "");
        clearPlay = datasource:clearplay({"SearchValue" : titleNew});
        rows = clearPlay.query("table#search_results tr");
        imdbLink = "http://www.imdb.com/find?s=all&q=#{titleNew}";
        clearPlayLink = "http://clearplay.com/filtercart.aspx?SearchValue=#{titleNew}";
        message = rows.length() => messageAvailable | messageNotAvailable;
 
      }
 
      {
        prepend("#mdp-overview",message);
      }
  }
 
 
  rule imdb_movie_page is active {
    select when pageview "http://www.imdb.com/title/\w+" setting()
      {
        page_content("imdb",{"title":{"selector":"h1.header","type":"text"}});
      }
  }
 
  rule respond_to_title is active {
    select when web page_content label "imdb" setting()
      pre {
        messageAvailable = << 
          <div id="clearPlayWrapper" style="margin-top: 0px; margin-bottom: 80px;"> 
            <div id="clearPlay"> 
              <div id="clearPlayLogo"> 
                <a href="http:\/\/www.clearplay.com"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppLogo.gif" alt="clearPlayLogo" /> 
                </a> 
              </div> 
              <div id="clearPlayFilter"> 
                <a target="_blank" href="#{clearPlayLink}"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownload.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownloadOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppDownload.gif'" /> 
                </a> 
              </div> 
              <div id="clearPlayQueue"> 
                <a target='_blank' href='https:\/\/www.netflix.com/Login'> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueue.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueueOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppQueue.gif'" /> 
                </a> 
              </div> 
              <div id="clearPlayIMDb"> 
                <a target="_blank" href="#{imdbLink}"> 
                  <img src="http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDb.gif" alt="clearPlayLogo" onmouseover="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDbOn.gif'" onmouseout="this.src='http:\/\/k-misc.s3.amazonaws.com/resources/a22x2/cpAppIMDb.gif'" /> 
                </a> 
              </div> 
              <br /> 
            </div> 
          </div>      
        >>;
 
        messageNotAvailable = << 
          <div id="clearPlayWrapper" style="margin-top: 0px; margin-bottom: 80px;"> 
            <div id="clearPlay"> 
              <div id="clearPlayLogo"> 
                <a href="http://www.clearplay.com"><img src="http://k-misc.s3.amazonaws.com/resources/a22x2/cpAppLogo.gif" alt="Clear Play Logo" /></a> 
              </div> 
              <div id="clearPlayFilter"> 
                <a target="_blank" href="https://www.clearplay.com/signin.aspx?returnurl=MovieRequest.aspx"><img src="http://k-misc.s3.amazonaws.com/resources/a22x2/cpAppNoFilter.gif" alt="Clear Play Filter" /></a> 
              </div> 
              <br /> 
            </div> 
          </div> 
 
        >>;
 
        title = page:env("title");
        titleNew = (title.replace(re/^the /i, "")).replace(re/ \(.*/g, "");
        clearPlay = datasource:clearplay({"SearchValue" : titleNew});
        rows = clearPlay.query("table#search_results tr");
        imdbLink = "http://www.imdb.com/find?s=all&q=#{titleNew}";
        clearPlayLink = "http://clearplay.com/filtercart.aspx?SearchValue=#{titleNew}";
        message = rows.length() => messageAvailable | messageNotAvailable;
      }
      {
        prepend("#main>.article:eq(0)",message);
      }
  }
}