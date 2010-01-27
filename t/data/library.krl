// test for doing library in KRL
ruleset library {

    global {
	datasource library_search <- "http://test.azigo.com:9083/solr/select/?wt=json";
    }

    rule book_notfication is active {
        select using "www.amazon.com/gp/product/(\d+)/" setting(isbn)

        pre {
      	  book_data = datasource:library_search(("q="+isbn));
  	  url = book_data.pick("$..docs[0].url");
 	  title = book_data.pick("$..docs[0].title");

	  msg = <<
This book's available at your local library. Click here to see:'
<a href="#{url}">#{title}</a>
>>;
	}

	if (book_data.pick("$..numFound") > 0) then 
		notify("top-right", "#222", "#FFF", "Minuteman Library", true,
       		         msg);
    }
}
