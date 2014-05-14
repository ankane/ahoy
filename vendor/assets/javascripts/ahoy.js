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
  var canStringify = typeof(JSON) !== "undefined" && typeof(JSON.stringify) !== "undefined";
  var eventQueue = [];

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

  function ready(callback) {
    if (isReady) {
      callback();
    } else {
      queue.push(callback);
    }
  }

  // https://github.com/klughammer/node-randomstring
  function generateId() {
    var chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghiklmnopqrstuvwxyz';
    var length = 32;
    var string = '';

    for (var i = 0; i < length; i++) {
      var randomNumber = Math.floor(Math.random() * chars.length);
      string += chars.substring(randomNumber, randomNumber + 1);
    }

    return string;
  }

  function saveEventQueue() {
    // TODO add stringify method for IE 7 and under
    if (canStringify) {
      setCookie("ahoy_events", JSON.stringify(eventQueue), 1);
    }
  }

  function trackEvent(event) {
    ready( function () {
      // ensure JSON is defined
      if (canStringify) {
        $.ajax({
          type: "POST",
          url: "/ahoy/events",
          data: JSON.stringify(event),
          contentType: "application/json; charset=utf-8",
          dataType: "json",
          success: function() {
            // remove from queue
            for (var i = 0; i < eventQueue.length; i++) {
              if (eventQueue[i].id == event.id) {
                eventQueue.splice(i, 1);
                break;
              }
            }
            saveEventQueue();
          }
        });
      }
    });
  }

  function eventProperties(e) {
    var $target = $(e.currentTarget);
    return {
      tag: $target.get(0).tagName.toLowerCase(),
      id: $target.attr("id"),
      class: $target.attr("class")
    };
  }

  // main

  visitToken = getCookie("ahoy_visit");
  visitorToken = getCookie("ahoy_visitor");

  if (visitToken && visitorToken) {
    // TODO keep visit alive?
    log("Active visit");
    setReady();
  } else {
    visitToken = generateId();
    setCookie("ahoy_visit", visitToken, visitTtl);

    // make sure cookies are enabled
    if (getCookie("ahoy_visit")) {
      log("Visit started");

      if (!visitorToken) {
        visitorToken = generateId();
        setCookie("ahoy_visitor", visitorToken, visitorTtl);
      }

      var data = {
        visit_token: visitToken,
        visitor_token: visitorToken,
        platform: ahoy.platform || "Web",
        landing_page: window.location.href,
        screen_width: window.screen.width,
        screen_height: window.screen.height
      };

      // referrer
      if (document.referrer.length > 0) {
        data.referrer = document.referrer;
      }

      log(data);

      $.post("/ahoy/visits", data, setReady, "json");
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

  ahoy.track = function (name, properties) {
    // generate unique id
    var event = {
      id: generateId(),
      name: name,
      properties: properties,
      time: (new Date()).getTime() / 1000.0
    };
    log(event);

    eventQueue.push(event);
    saveEventQueue();

    // wait in case navigating to reduce duplicate events
    setTimeout( function () {
      trackEvent(event);
    }, 1000);
  };

  ahoy.trackView = function () {
    var properties = {
      url: window.location.href,
      title: document.title
    };
    ahoy.track("$view", properties);
  };

  ahoy.trackClicks = function () {
    $(document).on("click", "a, button, input[type=submit]", function (e) {
      var $target = $(e.currentTarget);
      var properties = eventProperties(e);
      properties.text = properties.tag == "input" ? $target.val() : $.trim($target.text());
      properties.href = $target.attr("href");
      ahoy.track("$click", properties);
    });
  };

  ahoy.trackSubmits = function () {
    $(document).on("submit", "form", function (e) {
      var properties = eventProperties(e);
      ahoy.track("$submit", properties);
    });
  };

  ahoy.trackChanges = function () {
    $(document).on("change", "input, textarea, select", function (e) {
      var properties = eventProperties(e);
      ahoy.track("$change", properties);
    });
  };

  ahoy.trackAll = function() {
    ahoy.trackView();
    ahoy.trackClicks();
    ahoy.trackSubmits();
    ahoy.trackChanges();
  };

  // push events from queue
  try {
    eventQueue = JSON.parse(getCookie("ahoy_events") || "[]");
  } catch (e) {
    // do nothing
  }

  for (var i = 0; i < eventQueue.length; i++) {
    trackEvent(eventQueue[i]);
  }

  window.ahoy = ahoy;
}(window));
