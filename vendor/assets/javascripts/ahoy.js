/*jslint browser: true, indent: 2, plusplus: true, vars: true */

(function (window) {
  "use strict";

  var ahoy = window.ahoy || window.Ahoy || {};
  var $ = window.jQuery || window.Zepto || window.$;
  var visitToken, visitorToken;
  var visitTtl = 4 * 60; // 4 hours
  var visitorTtl = 2 * 365 * 24 * 60; // 2 years
  var isReady = false;
  var queue = [];

  // cookies

  // http://www.quirksmode.org/js/cookies.html
  function setCookie(name, value, ttl) {
    var expires = "";
    var cookieDomain = "";
    if (ttl) {
      var date = new Date();
      date.setTime(date.getTime() + (ttl * 60 * 1000));
      expires = "; expires=" + date.toGMTString();
    }
    if (ahoy.domain) {
      cookieDomain = "; domain=" + ahoy.domain;
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

  function destroyCookie(name) {
    setCookie(name, "", -1);
  }

  function log(message) {
    if (getCookie("ahoy_debug")) {
      window.console.log(message);
    }
  }

  function setReady() {
    var callback;
    while (callback = queue.shift()) {
      callback();
    }
    isReady = true;
  }

  // main

  visitToken = getCookie("ahoy_visit");
  visitorToken = getCookie("ahoy_visitor");

  if (visitToken && visitorToken && visitToken != "test") {
    // TODO keep visit alive?
    log("Active visit");
    setReady();
  } else {
    setCookie("ahoy_visit", "test", 1);

    // make sure cookies are enabled
    if (getCookie("ahoy_visit")) {
      log("Visit started");

      var data = {
        platform: ahoy.platform || "Web",
        landing_page: window.location.href
      };

      // referrer
      if (document.referrer.length > 0) {
        data.referrer = document.referrer;
      }

      if (visitorToken) {
        data.visitor_token = visitorToken;
      }

      log(data);

      $.post("/ahoy/visits", data, function(response) {
        setCookie("ahoy_visit", response.visit_token, visitTtl);
        setCookie("ahoy_visitor", response.visitor_token, visitorTtl);
        setReady();
      }, "json");
    } else {
      log("Cookies disabled");
      setReady();
    }
  }

  ahoy.reset = function () {
    destroyCookie("ahoy_visit");
    destroyCookie("ahoy_visitor");
    return true;
  };

  ahoy.debug = function (enabled) {
    if (enabled === false) {
      destroyCookie("ahoy_debug");
    } else {
      setCookie("ahoy_debug", "t", 365 * 24 * 60); // 1 year
    }
    return true;
  };

  ahoy.setCookie = setCookie;
  ahoy.getCookie = getCookie;
  ahoy.destroyCookie = destroyCookie;
  ahoy.log = log;

  ahoy.ready = function (callback) {
    if (isReady) {
      callback();
    } else {
      queue.push(callback);
    }
  };

  window.ahoy = ahoy;
}(window));
