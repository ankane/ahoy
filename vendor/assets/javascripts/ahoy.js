/*jslint browser: true, indent: 2, plusplus: true, vars: true */

(function (window) {
  "use strict";

  var debugMode = true;
  var options = window.Ahoy || {};
  var $ = window.jQuery || window.Zepto || window.$;
  var visitToken, visitorToken;
  var visitTtl, visitorTtl;

  if (debugMode) {
    visitTtl = 0.2;
    visitorTtl = 5; // 5 minutes
  } else {
    visitTtl = 4 * 60; // 4 hours
    visitorTtl = 2 * 365 * 24 * 60; // 2 years
  }

  // cookies

  // http://www.quirksmode.org/js/cookies.html
  function setCookie(name, value, ttl, domain) {
    var expires = "";
    var cookieDomain = "";
    if (ttl) {
      var date = new Date();
      date.setTime(date.getTime() + (ttl * 60 * 1000));
      expires = "; expires=" + date.toGMTString();
    }
    if (domain) {
      cookieDomain = "; domain=" + domain;
    }
    document.cookie = name + "=" + value + expires + cookieDomain + "; path=/";
  }

  function getCookie(name) {
    var i, c;
    var nameEQ = name + "=";
    var ca = document.cookie.split(';');
    for (i = 0; i < ca.length; i++) {
      c = ca[i];
      while (c.charAt(0) === ' ') {
        c = c.substring(1, c.length);
      }
      if (c.indexOf(nameEQ) === 0) {
        return c.substring(nameEQ.length, c.length);
      }
    }
    return null;
  }

  function debug(message) {
    if (debugMode) {
      window.console.log(message, visitToken, visitorToken);
    }
  }

  // main

  visitToken = getCookie("ahoy_visit");
  visitorToken = getCookie("ahoy_visitor");

  if (visitToken && visitorToken && visitToken != "test") {
    // TODO keep visit alive?
    debug("Active visit");
  } else {
    setCookie("ahoy_visit", "test", 1, options.domain);

    // make sure cookies are enabled
    if (getCookie("ahoy_visit")) {
      debug("Visit started");

      var data = {
        platform: options.platform || "Web",
        landing_page: window.location.href
      };

      // referrer
      if (document.referrer.length > 0) {
        data.referrer = document.referrer;
      }

      if (visitorToken) {
        data.visitor_token = visitorToken;
      }

      debug(data);

      $.post("/ahoy/visits", data, function(response) {
        setCookie("ahoy_visit", response.visit_token, visitTtl, options.domain);
        setCookie("ahoy_visitor", response.visitor_token, visitorTtl, options.domain);
      }, "json");
    } else {
      debug("Cookies disabled");
    }
  }

}(window));
