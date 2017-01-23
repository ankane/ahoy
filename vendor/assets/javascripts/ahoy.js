/*
 * Ahoy.js
 * Simple, powerful JavaScript analytics
 * https://github.com/ankane/ahoy.js
 * v0.2.1
 * MIT License
 */

/*jslint browser: true, indent: 2, plusplus: true, vars: true */

(function (window) {
  "use strict";

  var config = {
    urlPrefix: "",
    visitsUrl: "/ahoy/visits",
    eventsUrl: "/ahoy/events",
    cookieDomain: null,
    page: null,
    platform: "Web",
    useBeacon: false,
    startOnReady: true
  };

  var ahoy = window.ahoy || window.Ahoy || {};

  ahoy.configure = function (options) {
    for (var key in options) {
      if (options.hasOwnProperty(key)) {
        config[key] = options[key];
      }
    }
  };

  // legacy
  ahoy.configure(ahoy);

  var $ = window.jQuery || window.Zepto || window.$;
  var visitId, visitorId, track;
  var visitTtl = 4 * 60; // 4 hours
  var visitorTtl = 2 * 365 * 24 * 60; // 2 years
  var isReady = false;
  var queue = [];
  var canStringify = typeof(JSON) !== "undefined" && typeof(JSON.stringify) !== "undefined";
  var eventQueue = [];

  function visitsUrl() {
    return config.urlPrefix + config.visitsUrl;
  }

  function eventsUrl() {
    return config.urlPrefix + config.eventsUrl;
  }

  function canTrackNow() {
    return (config.useBeacon || config.trackNow) && canStringify && typeof(window.navigator.sendBeacon) !== "undefined";
  }

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
    var domain = config.cookieDomain || config.domain;
    if (domain) {
      cookieDomain = "; domain=" + domain;
    }
    document.cookie = name + "=" + escape(value) + expires + cookieDomain + "; path=/";
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
        return unescape(c.substring(nameEQ.length, c.length));
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

  // http://stackoverflow.com/a/2117523/1177228
  function generateId() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
      return v.toString(16);
    });
  }

  function saveEventQueue() {
    // TODO add stringify method for IE 7 and under
    if (canStringify) {
      setCookie("ahoy_events", JSON.stringify(eventQueue), 1);
    }
  }

  // from jquery-ujs

  function csrfToken() {
    return $("meta[name=csrf-token]").attr("content");
  }

  function csrfParam() {
    return $("meta[name=csrf-param]").attr("content");
  }

  function CSRFProtection(xhr) {
    var token = csrfToken();
    if (token) xhr.setRequestHeader("X-CSRF-Token", token);
  }

  function sendRequest(url, data, success) {
    if (canStringify) {
      $.ajax({
        type: "POST",
        url: url,
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        beforeSend: CSRFProtection,
        success: success
      });
    }
  }

  function eventData(event) {
    var data = {
      events: [event],
      visit_token: event.visit_token,
      visitor_token: event.visitor_token
    };
    delete event.visit_token;
    delete event.visitor_token;
    return data;
  }

  function trackEvent(event) {
    ready( function () {
      sendRequest(eventsUrl(), eventData(event), function() {
        // remove from queue
        for (var i = 0; i < eventQueue.length; i++) {
          if (eventQueue[i].id == event.id) {
            eventQueue.splice(i, 1);
            break;
          }
        }
        saveEventQueue();
      });
    });
  }

  function trackEventNow(event) {
    ready( function () {
      var data = eventData(event);
      var param = csrfParam();
      var token = csrfToken();
      if (param && token) data[param] = token;
      var payload = new Blob([JSON.stringify(data)], {type : "application/json; charset=utf-8"});
      navigator.sendBeacon(eventsUrl(), payload);
    });
  }

  function page() {
    return config.page || window.location.pathname;
  }

  function eventProperties(e) {
    var $target = $(e.currentTarget);
    return {
      tag: $target.get(0).tagName.toLowerCase(),
      id: $target.attr("id"),
      "class": $target.attr("class"),
      page: page(),
      section: $target.closest("*[data-section]").data("section")
    };
  }

  function createVisit() {
    isReady = false;

    visitId = ahoy.getVisitId();
    visitorId = ahoy.getVisitorId();
    track = getCookie("ahoy_track");

    if (visitId && visitorId && !track) {
      // TODO keep visit alive?
      log("Active visit");
      setReady();
    } else {
      if (track) {
        destroyCookie("ahoy_track");
      }

      if (!visitId) {
        visitId = generateId();
        setCookie("ahoy_visit", visitId, visitTtl);
      }

      // make sure cookies are enabled
      if (getCookie("ahoy_visit")) {
        log("Visit started");

        if (!visitorId) {
          visitorId = generateId();
          setCookie("ahoy_visitor", visitorId, visitorTtl);
        }

        var data = {
          visit_token: visitId,
          visitor_token: visitorId,
          platform: config.platform,
          landing_page: window.location.href,
          screen_width: window.screen.width,
          screen_height: window.screen.height
        };

        // referrer
        if (document.referrer.length > 0) {
          data.referrer = document.referrer;
        }

        log(data);

        sendRequest(visitsUrl(), data, setReady);
      } else {
        log("Cookies disabled");
        setReady();
      }
    }
  }

  ahoy.getVisitId = ahoy.getVisitToken = function () {
    return getCookie("ahoy_visit");
  };

  ahoy.getVisitorId = ahoy.getVisitorToken = function () {
    return getCookie("ahoy_visitor");
  };

  ahoy.reset = function () {
    destroyCookie("ahoy_visit");
    destroyCookie("ahoy_visitor");
    destroyCookie("ahoy_events");
    destroyCookie("ahoy_track");
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
      properties: properties || {},
      time: (new Date()).getTime() / 1000.0
    };

    // wait for createVisit to log
    $( function () {
      log(event);
    });

    ready( function () {
      if (!ahoy.getVisitId()) {
        createVisit();
      }

      event.visit_token = ahoy.getVisitId();
      event.visitor_token = ahoy.getVisitorId();

      if (canTrackNow()) {
        trackEventNow(event);
      } else {
        eventQueue.push(event);
        saveEventQueue();

        // wait in case navigating to reduce duplicate events
        setTimeout( function () {
          trackEvent(event);
        }, 1000);
      }
    });
  };

  ahoy.trackView = function (additionalProperties) {
    var properties = {
      url: window.location.href,
      title: document.title,
      page: page()
    };

    if (additionalProperties) {
      for(var propName in additionalProperties) {
        if (additionalProperties.hasOwnProperty(propName)) {
          properties[propName] = additionalProperties[propName];
        }
      }
    }
    ahoy.track("$view", properties);
  };

  ahoy.trackClicks = function () {
    $(document).on("click", "a, button, input[type=submit]", function (e) {
      var $target = $(e.currentTarget);
      var properties = eventProperties(e);
      properties.text = properties.tag == "input" ? $target.val() : $.trim($target.text().replace(/[\s\r\n]+/g, " "));
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

  ahoy.start = function () {
    createVisit();

    ahoy.start = function () {};
  };

  $( function () {
    if (config.startOnReady) {
      ahoy.start();
    }
  });

  window.ahoy = ahoy;
}(window));
