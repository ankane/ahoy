/*jslint browser: true, indent: 2, plusplus: true, vars: true */

(function (window) {
  "use strict";

  var debugMode = false;
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

  // ids

  // https://github.com/klughammer/node-randomstring
  function generateToken() {
    var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghiklmnopqrstuvwxyz';
    var length = 32;
    var string = '';
    var i, randomNumber;

    for (i = 0; i < length; i++) {
      randomNumber = Math.floor(Math.random() * chars.length);
      string += chars.substring(randomNumber, randomNumber + 1);
    }

    return string;
  }

  function debug(message) {
    if (debugMode) {
      window.console.log(message, visitToken, visitorToken);
    }
  }

  // main

  visitToken = getCookie("ahoy_visit");
  visitorToken = getCookie("ahoy_visitor");

  if (visitToken && visitorToken) {
    // TODO keep visit alive?
    debug("Active visit");
  } else {
    if (!visitorToken) {
      visitorToken = generateToken();
      setCookie("ahoy_visitor", visitorToken, visitorTtl, options.domain);
    }

    // always generate a new visit id here
    visitToken = generateToken();
    setCookie("ahoy_visit", visitToken, visitTtl, options.domain);

    // make sure cookies are enabled
    if (getCookie("ahoy_visit")) {
      debug("Visit started");

      var data = {
        visit_token: visitToken,
        visitor_token: visitorToken,
        landing_page: window.location.href
      };

      // referrer
      if (document.referrer.length > 0) {
        data.referrer = document.referrer;
      }

      debug(data);

      $.post("/ahoy/visits", data);
    } else {
      debug("Cookies disabled");
    }
  }

}(window));
