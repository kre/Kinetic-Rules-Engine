{
   "dispatch": [
      {"domain": "google.com"},
      {"domain": "bing.com"},
      {"domain": "yahoo.com"},
      {"domain": "josbank.com"},
      {"domain": "lampsplus.com"}
   ],
   "global": [
      {
         "lhs": "visaDiscounts",
         "rhs": {
            "type": "hashraw",
            "val": [
               {
                  "lhs": "www.lampsplus.com",
                  "rhs": {
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "name",
                           "rhs": {
                              "type": "str",
                              "val": "Lamps Plus"
                           }
                        },
                        {
                           "lhs": "phone",
                           "rhs": {
                              "type": "str",
                              "val": "8007821967"
                           }
                        },
                        {
                           "lhs": "badgeRequired",
                           "rhs": {
                              "type": "bool",
                              "val": "true"
                           }
                        },
                        {
                           "lhs": "couponCode",
                           "rhs": {
                              "type": "bool",
                              "val": "false"
                           }
                        },
                        {
                           "lhs": "discountDescription",
                           "rhs": {
                              "type": "str",
                              "val": "Save $20 on order of $100 or more"
                           }
                        },
                        {
                           "lhs": "code",
                           "rhs": {
                              "type": "str",
                              "val": "55VSAF9"
                           }
                        }
                     ]
                  }
               },
               {
                  "lhs": "www.josbank.com",
                  "rhs": {
                     "type": "hashraw",
                     "val": [
                        {
                           "lhs": "name",
                           "rhs": {
                              "type": "str",
                              "val": "Jos A. Bank Clothiers"
                           }
                        },
                        {
                           "lhs": "phone",
                           "rhs": {
                              "type": "str",
                              "val": "8002852265"
                           }
                        },
                        {
                           "lhs": "badgeRequired",
                           "rhs": {
                              "type": "bool",
                              "val": "false"
                           }
                        },
                        {
                           "lhs": "couponCode",
                           "rhs": {
                              "type": "bool",
                              "val": "false"
                           }
                        }
                     ]
                  }
               }
            ]
         },
         "type": "expr"
      },
      {
         "lhs": "profile",
         "rhs": {
            "type": "hashraw",
            "val": [
               {
                  "lhs": "firstname",
                  "rhs": {
                     "type": "str",
                     "val": "John"
                  }
               },
               {
                  "lhs": "lastname",
                  "rhs": {
                     "type": "str",
                     "val": "Doe"
                  }
               },
               {
                  "lhs": "cardholdername",
                  "rhs": {
                     "type": "str",
                     "val": "John Doe"
                  }
               },
               {
                  "lhs": "cardtype",
                  "rhs": {
                     "type": "str",
                     "val": "V0"
                  }
               },
               {
                  "lhs": "cc",
                  "rhs": {
                     "type": "str",
                     "val": "0000123412341234"
                  }
               },
               {
                  "lhs": "vcode",
                  "rhs": {
                     "type": "str",
                     "val": "123"
                  }
               },
               {
                  "lhs": "address",
                  "rhs": {
                     "type": "str",
                     "val": "8701 182nd st. e."
                  }
               },
               {
                  "lhs": "city",
                  "rhs": {
                     "type": "str",
                     "val": "Puyallup"
                  }
               },
               {
                  "lhs": "state",
                  "rhs": {
                     "type": "str",
                     "val": "WA"
                  }
               },
               {
                  "lhs": "nordstate",
                  "rhs": {
                     "type": "str",
                     "val": "39|0"
                  }
               },
               {
                  "lhs": "country",
                  "rhs": {
                     "type": "str",
                     "val": "us"
                  }
               },
               {
                  "lhs": "nordcountry",
                  "rhs": {
                     "type": "str",
                     "val": "249"
                  }
               },
               {
                  "lhs": "zip",
                  "rhs": {
                     "type": "str",
                     "val": "98375"
                  }
               },
               {
                  "lhs": "email",
                  "rhs": {
                     "type": "str",
                     "val": "john@johndoe.com"
                  }
               },
               {
                  "lhs": "phone",
                  "rhs": {
                     "type": "str",
                     "val": "9876543210"
                  }
               },
               {
                  "lhs": "areacode",
                  "rhs": {
                     "type": "str",
                     "val": "555"
                  }
               },
               {
                  "lhs": "phonenocode",
                  "rhs": {
                     "type": "str",
                     "val": "2225555"
                  }
               },
               {
                  "lhs": "ccmonth",
                  "rhs": {
                     "type": "str",
                     "val": "10"
                  }
               },
               {
                  "lhs": "ccyear",
                  "rhs": {
                     "type": "str",
                     "val": "2011"
                  }
               },
               {
                  "lhs": "billsame",
                  "rhs": {
                     "type": "str",
                     "val": "0"
                  }
               }
            ]
         },
         "type": "expr"
      }
   ],
   "meta": {
      "author": "Mike Grace",
      "keys": {"errorstack": "6beeaa0b4fc4eaa379cb273a6b37ebe9"},
      "logging": "on",
      "name": "Visa Demo"
   },
   "rules": [
      {
         "actions": [{"action": {
            "args": [{
               "type": "var",
               "val": "visa_search"
            }],
            "modifiers": null,
            "name": "annotate_search_results",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nfunction visa_search(obj){      try {        var host = $K(obj).data(\"domain\");        KOBJ.log(host);        var o = visaDiscounts[host];              if(!o){          o = visaDiscounts[\"www.\" + host];        }        if(o) {          KOBJ.log(o);          return '<a href=\"http://'+ host +'\"><img src=\"http://dl.dropbox.com/u/1446072/logo_visa.gif\" style=\"border: none;\"><\/a>';        } else {          return false;        }      } catch(e) {        console.log(e);      }     }          ",
         "foreach": [],
         "name": "search_annotate",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "google.com|bing.com|yahoo.com",
            "type": "prim_event",
            "vars": []
         }},
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Visa RightCliq Discount!"
               },
               {
                  "type": "var",
                  "val": "msgNoBadge"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [
               {
                  "type": "var",
                  "val": "mypath"
               },
               {
                  "type": "str",
                  "val": "/webapp/wcs/stores/servlet/CheckoutShoppingCartView"
               }
            ],
            "op": "neq",
            "type": "ineq"
         },
         "emit": null,
         "foreach": [],
         "name": "josbank_notify",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "http://www.josbank.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "domain",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "domain"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "mypath",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "path"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "msgNoBadge",
               "rhs": " \n<div id=\"AcxiomDiscount\" style=\"padding: 7px; background-color: white; color: black; font-size: 15px; text-align: center;\">          <div style=\"float: center;\">            <img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\" alt=\"Visa Logo\" />           <\/div>          <div>Save 20% on the regular price of any single item. Plus receive FREE Shipping on all online orders of $175 or more when you pay with your Visa® card.<\/div>          <br/><div>Discount code will be entered for you at checkout.<\/div>        <\/div>    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Congratulations!"
               },
               {
                  "type": "var",
                  "val": "msgBadge"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\n$K(\"#txtPromoCode\").val(\"55VSAF9\");      $K(\"#ibPromoCode\").focus();              ",
         "foreach": [],
         "name": "lamps_plus_auto_fill_promo_code",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)http://www.lampsplus.com/htmls/cart/ShoppingCart.aspx",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "domain",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "domain"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "msgBadge",
               "rhs": " \n<style>        #VisaDiscount .t { padding:6px 21px; }        #VisaDiscount img { padding: 5px 0 0 5px; }        #VisaDiscount { background-color: white; color: black;}        #VisaDiscount div.nred { color: red; font-weight: bold }      <\/style>      <div id=\"VisaDiscount\">        <div><img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\" alt=\"Visa Logo\" /><\/div>        <div class=\"t\">The discount code has been entered for you.<\/div>        <div class=\"t nred\">Please click the \"Update\" button to submit the discount.<\/h3>      <\/div>  \t    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Discount Available!"
               },
               {
                  "type": "var",
                  "val": "msgBadge"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "args": [
               {
                  "type": "var",
                  "val": "mypath"
               },
               {
                  "type": "str",
                  "val": "/htmls/cart/shoppingcart.aspx"
               }
            ],
            "op": "neq",
            "type": "ineq"
         },
         "emit": "\ntry {console.log(mypath); }    catch(e) {}          ",
         "foreach": [],
         "name": "lamps_plus",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "www.lampsplus.com",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "domain",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "domain"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "mypath",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "path"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "msgBadge",
               "rhs": " \n<style>        #VisaDiscount .t { padding:6px 21px; }        #VisaDiscount img { padding: 5px 0 0 5px; }        #VisaDiscount { background-color: white; color: black;}      <\/style>      <div id=\"VisaDiscount\">        <div>          <img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\" alt=\"Visa Logo\" />         <\/div>        <div class=\"t\">#{visaDiscounts[domain].discountDescription}<\/div>        <div class=\"t\">The discount code will be entered for you at checkout.<\/div>      <\/div>  \t    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": ""
               },
               {
                  "type": "var",
                  "val": "msgBadge"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\n$K(\"input#tbBillToFName\").val(profile.firstname);    $K(\"input#tbBillToLName\").val(profile.lastname);    $K(\"input#tbBillToAddressLine1\").val(profile.address);      $K(\"select#ddlBICountry\").val(profile.country);    $K(\"input#tbBillToCity\").val(profile.city);    $K(\"select#ddlBillToStateProvince\").val(profile.state);    $K(\"input#tbBillToZipCode\").val(profile.zip);    $K(\"input#tbBillToPhone\").val(profile.phone);    $K(\"input#tbBillToEmail\").val(profile.email);    $K(\"input#cbSameAsBillTo\").attr(\"checked\",\"true\");    CopyBillInfoToShipInfo();    $K(\"#imgbContinueCheckOut\").focus()          ",
         "foreach": [],
         "name": "lampsplus_billing_autofill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)https://secure.lampsplus.com/secure/cart/CheckOutShippingBilling.aspx\\.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msgBadge",
            "rhs": " \n<style>        #VisaDiscount .t { padding:6px 21px; }        #VisaDiscount img { padding: 5px 0 0 5px; }        #VisaDiscount { background-color: white; color: black;}      <\/style>      <div id=\"VisaDiscount\">        <div><img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\" alt=\"Visa Logo\" /><\/div>        <div class=\"t\">Please verify information and proceed to checkout<\/div>      <\/div>  \t    \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Payment"
               },
               {
                  "type": "var",
                  "val": "msgBadge"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\n$K(\"input#tbCardNumber\").val(profile.cc);    $K(\"input#tbCVV\").val(profile.vcode);    $K(\"input#tbCCFullName\").val(profile.cardholdername);    $K(\"select#ddlCCExpMonth\").val(profile.ccmonth);    $K(\"select#ddlCCExpYear\").val(profile.ccyear);    $K(\"input#ibSubmitOrder\").focus();          ",
         "foreach": [],
         "name": "lampsplus_payment_autofill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)https://secure.lampsplus.com/secure/cart/CheckOutVerifyBilling.aspx",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [
            {
               "lhs": "domain",
               "rhs": {
                  "args": [{
                     "type": "str",
                     "val": "domain"
                  }],
                  "predicate": "url",
                  "source": "page",
                  "type": "qualified"
               },
               "type": "expr"
            },
            {
               "lhs": "msgBadge",
               "rhs": " \n<style>        #VisaDiscount .t { padding:6px 21px; }        #VisaDiscount img { padding: 5px 0 0 5px; }        #VisaDiscount { background-color: white; color: black;}        #VisaDiscount div.nred { color: red; font-weight: bold }      <\/style>      <div id=\"VisaDiscount\">        <div><img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\" alt=\"Visa Logo\" /><\/div>        <div class=\"t\">The discount code has been entered for you.<\/div>        <div class=\"t nred\">Please verify payment information and submit your order.<\/h3>      <\/div>  \t    \n ",
               "type": "here_doc"
            }
         ],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": "Congratulations!"
               },
               {
                  "type": "var",
                  "val": "msgNoBadge"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\nif( $K(\"#qty2 ~ span\").text() == \"\" ) {    $K(\"#promoCode1\").val(\"VSAWTR\");    document.PromotionCodeForm.submit();  }          ",
         "foreach": [],
         "name": "josbank_code_fill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)http://www.josbank.com/webapp/wcs/stores/servlet/CheckoutShoppingCartView\\.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msgNoBadge",
            "rhs": " \n<div id=\"visadiscount\" style=\"padding: 7px; background-color: white; color: black; font-size: 15px; text-align: center;\">          <div style=\"float: center;\">            <img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\" alt=\"Visa Logo\" />           <\/div>          <div>You will now save 20% when you pay with your Visa® card!<\/div>        <\/div>    \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": ""
               },
               {
                  "type": "var",
                  "val": "msgNoBadge"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\n$K(\"input#billing_firstName\").val(profile.firstname);    $K(\"input#billing_lastName\").val(profile.lastname);      $K(\"input#billing_address1\").val(profile.address);    $K(\"input#billing_city\").val(profile.city);    $K(\"input#billing_state\").val(profile.state);    $K(\"input#billing_zipCode\").val(profile.zip);    $K(\"input#billing_phone1\").val(profile.phone);    $K(\"input#billing_email1\").val(profile.email);    $K(\"input#billing_confirmEmail\").val(profile.email);    $K(\"input#billing_enroll\").attr(\"checked\",\"\");    $K(\"input#addressField2\").val(0);    $K(\"#shipModeId_1\").focus();            ",
         "foreach": [],
         "name": "josbank_address_fill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)https://www.josbank.com/webapp/wcs/stores/servlet/CheckoutShippingView\\.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msgNoBadge",
            "rhs": " \n<div id=\"visadiscount\" style=\"padding: 7px; background-color: white; color: black; font-size: 15px; text-align: center;\">          <div style=\"float: center;\">            <img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\" alt=\"Visa Logo\" />           <\/div>          <div>Please confirm your information and continue to checkout<\/div>        <\/div>    \n ",
            "type": "here_doc"
         }],
         "state": "active"
      },
      {
         "actions": [{"action": {
            "args": [
               {
                  "type": "str",
                  "val": ""
               },
               {
                  "type": "var",
                  "val": "msgNoBadge"
               }
            ],
            "modifiers": [{
               "name": "sticky",
               "value": {
                  "type": "bool",
                  "val": "true"
               }
            }],
            "name": "notify",
            "source": null
         }}],
         "blocktype": "every",
         "callbacks": null,
         "cond": {
            "type": "bool",
            "val": "true"
         },
         "emit": "\n$K(\"input#pay_cc_radio\").attr(\"checked\",\"true\");      showPaymentDiv('pay_cc');    $K(\"input#cc_brand\").val(\"VISA\");    $K(\"input#cc_account\").val(profile.cc);    $K(\"input#expire_month\").val(profile.ccmonth);    $K(\"input#expire_year\").val(profile.ccyear);    $K(\"input#cc_cvc\").val(profile.vcode);    $K(\"#email1\").focus();          ",
         "foreach": [],
         "name": "josbank_payment_fill",
         "pagetype": {"event_expr": {
            "legacy": 1,
            "op": "pageview",
            "pattern": "(?i)https://www.josbank.com/webapp/wcs/stores/servlet/CheckoutPaymentView\\.*",
            "type": "prim_event",
            "vars": []
         }},
         "pre": [{
            "lhs": "msgNoBadge",
            "rhs": " \n<div id=\"visadiscount\" style=\"padding: 7px; background-color: white; color: black; font-size: 15px; text-align: center;\">          <div style=\"float: center;\">            <img src=\"https://rightcliq.visa.com/ECSWebApp/images/logo-rightcliq-marketing.png\" alt=\"Visa Logo\" />           <\/div>          <div>Please select card type and confirm payment information.<\/div>        <\/div>    \n ",
            "type": "here_doc"
         }],
         "state": "active"
      }
   ],
   "ruleset_name": "a60x55"
}
