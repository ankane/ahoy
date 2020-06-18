/*
 * Ahoy.js
 * Simple, powerful JavaScript analytics
 * https://github.com/ankane/ahoy.js
 * v0.3.6
 * MIT License
 */

(function (global, factory) {
  typeof exports === 'object' && typeof module !== 'undefined' ? module.exports = factory() :
  typeof define === 'function' && define.amd ? define(factory) :
  (global = global || self, global.ahoy = factory());
}(this, (function () { 'use strict';

  var n=function(n){return void 0===n},e=function(n){return Array.isArray(n)},t=function(n){return n&&"number"==typeof n.size&&"string"==typeof n.type&&"function"==typeof n.slice},s=function(o,i,r,f){return (i=i||{}).indices=!n(i.indices)&&i.indices,i.nullsAsUndefineds=!n(i.nullsAsUndefineds)&&i.nullsAsUndefineds,i.booleansAsIntegers=!n(i.booleansAsIntegers)&&i.booleansAsIntegers,r=r||new FormData,n(o)?r:(null===o?i.nullsAsUndefineds||r.append(f,""):"boolean"!=typeof o?e(o)?o.length&&o.forEach(function(n,e){s(n,i,r,f+"["+(i.indices?e:"")+"]");}):o instanceof Date?r.append(f,o.toISOString()):o!==Object(o)||function(n){return t(n)&&"string"==typeof n.name&&("object"==typeof n.lastModifiedDate||"number"==typeof n.lastModified)}(o)||t(o)?r.append(f,o):Object.keys(o).forEach(function(n){var t=o[n];if(e(t)){ for(;n.length>2&&n.lastIndexOf("[]")===n.length-2;){ n=n.substring(0,n.length-2); } }s(t,i,r,f?f+"["+n+"]":n);}):r.append(f,i.booleansAsIntegers?o?1:0:o),r)};

  // https://www.quirksmode.org/js/cookies.html

  var Cookies = {
    set: function (name, value, ttl, domain) {
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
      document.cookie = name + "=" + escape(value) + expires + cookieDomain + "; path=/";
    },
    get: function (name) {
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
  };

  var config = {
    urlPrefix: "",
    visitsUrl: "/ahoy/visits",
    eventsUrl: "/ahoy/events",
    page: null,
    platform: "Web",
    useBeacon: true,
    startOnReady: true,
    trackVisits: true,
    cookies: true,
    cookieDomain: null,
    headers: {},
    visitParams: {},
    withCredentials: false,
    visitDuration: 4 * 60, // default 4 hours
    visitorDuration: 2 * 365 * 24 * 60 // default 2 years
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

  function isEmpty(obj) {
    return Object.keys(obj).length === 0;
  }

  function canTrackNow() {
    return (config.useBeacon || config.trackNow) && isEmpty(config.headers) && canStringify && typeof(window.navigator.sendBeacon) !== "undefined" && !config.withCredentials;
  }

  // cookies

  function setCookie(name, value, ttl) {
    Cookies.set(name, value, ttl, config.cookieDomain || config.domain);
  }

  function getCookie(name) {
    return Cookies.get(name);
  }

  function destroyCookie(name) {
    Cookies.set(name, "", -1);
  }

  function log(message) {
    if (getCookie("ahoy_debug")) {
      window.console.log(message);
    }
  }

  function setReady() {
    var callback;
    while ((callback = queue.shift())) {
      callback();
    }
    isReady = true;
  }

  ahoy.ready = function (callback) {
    if (isReady) {
      callback();
    } else {
      queue.push(callback);
    }
  };

  function matchesSelector(element, selector) {
    var matches = element.matches ||
      element.matchesSelector ||
      element.mozMatchesSelector ||
      element.msMatchesSelector ||
      element.oMatchesSelector ||
      element.webkitMatchesSelector;

    if (matches) {
      return matches.apply(element, [selector]);
    } else {
      log("Unable to match");
      return false;
    }
  }

  function onEvent(eventName, selector, callback) {
    document.addEventListener(eventName, function (e) {
      if (matchesSelector(e.target, selector)) {
        callback(e);
      }
    });
  }

  // http://beeker.io/jquery-document-ready-equivalent-vanilla-javascript
  function documentReady(callback) {
    if (document.readyState === "interactive" || document.readyState === "complete") {
      setTimeout(callback, 0);
    } else {
      document.addEventListener("DOMContentLoaded", callback);
    }
  }

  // https://stackoverflow.com/a/2117523/1177228
  function generateId() {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
      var r = Math.random()*16|0, v = c == 'x' ? r : (r&0x3|0x8);
      return v.toString(16);
    });
  }

  function saveEventQueue() {
    if (config.cookies && canStringify) {
      setCookie("ahoy_events", JSON.stringify(eventQueue), 1);
    }
  }

  // from rails-ujs

  function csrfToken() {
    var meta = document.querySelector("meta[name=csrf-token]");
    return meta && meta.content;
  }

  function csrfParam() {
    var meta = document.querySelector("meta[name=csrf-param]");
    return meta && meta.content;
  }

  function CSRFProtection(xhr) {
    var token = csrfToken();
    if (token) { xhr.setRequestHeader("X-CSRF-Token", token); }
  }

  function sendRequest(url, data, success) {
    if (canStringify) {
      if ($ && $.ajax) {
        $.ajax({
          type: "POST",
          url: url,
          data: JSON.stringify(data),
          contentType: "application/json; charset=utf-8",
          dataType: "json",
          beforeSend: CSRFProtection,
          success: success,
          headers: config.headers,
          xhrFields: {
            withCredentials: config.withCredentials
          }
        });
      } else {
        var xhr = new XMLHttpRequest();
        xhr.open("POST", url, true);
        xhr.withCredentials = config.withCredentials;
        xhr.setRequestHeader("Content-Type", "application/json");
        for (var header in config.headers) {
          if (config.headers.hasOwnProperty(header)) {
            xhr.setRequestHeader(header, config.headers[header]);
          }
        }
        xhr.onload = function() {
          if (xhr.status === 200) {
            success();
          }
        };
        CSRFProtection(xhr);
        xhr.send(JSON.stringify(data));
      }
    }
  }

  function eventData(event) {
    var data = {
      events: [event]
    };
    if (config.cookies) {
      data.visit_token = event.visit_token;
      data.visitor_token = event.visitor_token;
    }
    delete event.visit_token;
    delete event.visitor_token;
    return data;
  }

  function trackEvent(event) {
    ahoy.ready( function () {
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
    ahoy.ready( function () {
      var data = eventData(event);
      var param = csrfParam();
      var token = csrfToken();
      if (param && token) { data[param] = token; }
      // stringify so we keep the type
      data.events_json = JSON.stringify(data.events);
      delete data.events;
      window.navigator.sendBeacon(eventsUrl(), s(data));
    });
  }

  function page() {
    return config.page || window.location.pathname;
  }

  function presence(str) {
    return (str && str.length > 0) ? str : null;
  }

  function cleanObject(obj) {
    for (var key in obj) {
      if (obj.hasOwnProperty(key)) {
        if (obj[key] === null) {
          delete obj[key];
        }
      }
    }
    return obj;
  }

  function getClosestSection(element) {
    for ( ; element && element !== document; element = element.parentNode) {
      if (element.hasAttribute('data-section')) {
        return element.getAttribute('data-section');
      }
    }

    return null;
  }

  function createVisit() {
    isReady = false;

    visitId = ahoy.getVisitId();
    visitorId = ahoy.getVisitorId();
    track = getCookie("ahoy_track");

    if (config.cookies === false || config.trackVisits === false) {
      log("Visit tracking disabled");
      setReady();
    } else if (visitId && visitorId && !track) {
      // TODO keep visit alive?
      log("Active visit");
      setReady();
    } else {
      if (!visitId) {
        visitId = generateId();
        setCookie("ahoy_visit", visitId, config.visitDuration);
      }

      // make sure cookies are enabled
      if (getCookie("ahoy_visit")) {
        log("Visit started");

        if (!visitorId) {
          visitorId = generateId();
          setCookie("ahoy_visitor", visitorId, config.visitorDuration);
        }

        var data = {
          visit_token: visitId,
          visitor_token: visitorId,
          platform: config.platform,
          landing_page: window.location.href,
          screen_width: window.screen.width,
          screen_height: window.screen.height,
          js: true
        };

        // referrer
        if (document.referrer.length > 0) {
          data.referrer = document.referrer;
        }

        for (var key in config.visitParams) {
          if (config.visitParams.hasOwnProperty(key)) {
            data[key] = config.visitParams[key];
          }
        }

        log(data);

        sendRequest(visitsUrl(), data, function () {
          // wait until successful to destroy
          destroyCookie("ahoy_track");
          setReady();
        });
      } else {
        log("Cookies disabled");
        setReady();
      }
    }
  }

  ahoy.eventProperties = function(e) {
    var target = e.target;
    return cleanObject({
      tag: target.tagName.toLowerCase(),
      id: presence(target.id),
      "class": presence(target.className),
      page: page(),
      section: getClosestSection(target)
    });
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
      name: name,
      properties: properties || {},
      time: (new Date()).getTime() / 1000.0,
      id: generateId(),
      js: true
    };

    ahoy.ready( function () {
      if (config.cookies && !ahoy.getVisitId()) {
        createVisit();
      }

      ahoy.ready( function () {
        log(event);

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
    });

    return true;
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
    onEvent("click", "a, button, input[type=submit]", function (e) {
      var target = e.target;
      var properties = ahoy.eventProperties(e);
      properties.text = properties.tag == "input" ? target.value : (target.textContent || target.innerText || target.innerHTML).replace(/[\s\r\n]+/g, " ").trim();
      properties.href = target.href;
      ahoy.track("$click", properties);
    });
  };

  ahoy.trackSubmits = function () {
    onEvent("submit", "form", function (e) {
      var properties = ahoy.eventProperties(e);
      ahoy.track("$submit", properties);
    });
  };

  ahoy.trackChanges = function () {
    onEvent("change", "input, textarea, select", function (e) {
      var properties = ahoy.eventProperties(e);
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

  documentReady(function() {
    if (config.startOnReady) {
      ahoy.start();
    }
  });

  return ahoy;

})));
