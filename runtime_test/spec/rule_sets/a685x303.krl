ruleset a385x303 {
  meta {
    name "page_content test"
    description <<

    >>
    author ""
    // Uncomment this line to require Marketplace purchase to use this app.
    // authz require user
    logging off
  }

  dispatch {
    // Some example dispatch domains
    // domain "example.com"
    // domain "other.example.com"
  }

  global {

  }

  rule first_rule is active {
    select when pageview ".*" setting ()
    // pre {   }
    // notify("Hello World", "This is a sample rule.");
    page_content("imdb",{"title":{"selector":"h1.header","type":"text"}});
  }

      rule first_rule2 is active {
    select when web page_content label "imdb" setting ()
    pre {
      label = page:env("imdb");
      search_links = page:env("title");

       }
    notify("Hello World", "We have #{label} #{search_links} ");

  }
}