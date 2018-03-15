(function webpackUniversalModuleDefinition(root, factory) {
	if(typeof exports === 'object' && typeof module === 'object')
		module.exports = factory();
	else if(typeof define === 'function' && define.amd)
		define([], factory);
	else if(typeof exports === 'object')
		exports["ahoy"] = factory();
	else
		root["ahoy"] = factory();
})(typeof self !== 'undefined' ? self : this, function() {
return /******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, {
/******/ 				configurable: false,
/******/ 				enumerable: true,
/******/ 				get: getter
/******/ 			});
/******/ 		}
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _objectToFormdata = __webpack_require__(1);

var _objectToFormdata2 = _interopRequireDefault(_objectToFormdata);

var _cookies = __webpack_require__(2);

var _cookies2 = _interopRequireDefault(_cookies);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/*
 * Ahoy.js
 * Simple, powerful JavaScript analytics
 * https://github.com/ankane/ahoy.js
 * v0.3.1
 * MIT License
 */

var config = {
  urlPrefix: "",
  visitsUrl: "/ahoy/visits",
  eventsUrl: "/ahoy/events",
  cookieDomain: null,
  page: null,
  platform: "Web",
  useBeacon: true,
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
var visitId = void 0,
    visitorId = void 0,
    track = void 0;
var visitTtl = 4 * 60; // 4 hours
var visitorTtl = 2 * 365 * 24 * 60; // 2 years
var isReady = false;
var queue = [];
var canStringify = typeof JSON !== "undefined" && typeof JSON.stringify !== "undefined";
var eventQueue = [];

function visitsUrl() {
  return config.urlPrefix + config.visitsUrl;
}

function eventsUrl() {
  return config.urlPrefix + config.eventsUrl;
}

function canTrackNow() {
  return (config.useBeacon || config.trackNow) && canStringify && typeof window.navigator.sendBeacon !== "undefined";
}

// cookies

function setCookie(name, value, ttl) {
  _cookies2.default.set(name, value, ttl, config.cookieDomain || config.domain);
}

function getCookie(name) {
  return _cookies2.default.get(name);
}

function destroyCookie(name) {
  _cookies2.default.set(name, "", -1);
}

function log(message) {
  if (getCookie("ahoy_debug")) {
    window.console.log(message);
  }
}

function setReady() {
  var callback = void 0;
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

function matchesSelector(element, selector) {
  var matches = element.matches || element.matchesSelector || element.mozMatchesSelector || element.msMatchesSelector || element.oMatchesSelector || element.webkitMatchesSelector;

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
  document.readyState === "interactive" || document.readyState === "complete" ? callback() : document.addEventListener("DOMContentLoaded", callback);
}

// http://stackoverflow.com/a/2117523/1177228
function generateId() {
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = Math.random() * 16 | 0,
        v = c == 'x' ? r : r & 0x3 | 0x8;
    return v.toString(16);
  });
}

function saveEventQueue() {
  if (canStringify) {
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
  if (token) xhr.setRequestHeader("X-CSRF-Token", token);
}

function sendRequest(url, data, success) {
  if (canStringify) {
    if ($) {
      $.ajax({
        type: "POST",
        url: url,
        data: JSON.stringify(data),
        contentType: "application/json; charset=utf-8",
        dataType: "json",
        beforeSend: CSRFProtection,
        success: success
      });
    } else {
      var xhr = new XMLHttpRequest();
      xhr.open("POST", url, true);
      xhr.setRequestHeader("Content-Type", "application/json");
      xhr.onload = function () {
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
    events: [event],
    visit_token: event.visit_token,
    visitor_token: event.visitor_token
  };
  delete event.visit_token;
  delete event.visitor_token;
  return data;
}

function trackEvent(event) {
  ready(function () {
    sendRequest(eventsUrl(), eventData(event), function () {
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
  ready(function () {
    var data = eventData(event);
    var param = csrfParam();
    var token = csrfToken();
    if (param && token) data[param] = token;
    // stringify so we keep the type
    data.events_json = JSON.stringify(data.events);
    delete data.events;
    window.navigator.sendBeacon(eventsUrl(), (0, _objectToFormdata2.default)(data));
  });
}

function page() {
  return config.page || window.location.pathname;
}

function presence(str) {
  return str && str.length > 0 ? str : null;
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

function eventProperties(e) {
  var target = e.target;
  return cleanObject({
    tag: target.tagName.toLowerCase(),
    id: presence(target.id),
    "class": presence(target.className),
    page: page(),
    section: getClosestSection(target)
  });
}

function getClosestSection(element) {
  for (; element && element !== document; element = element.parentNode) {
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

  if (visitId && visitorId && !track) {
    // TODO keep visit alive?
    log("Active visit");
    setReady();
  } else {
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
        screen_height: window.screen.height,
        js: true
      };

      // referrer
      if (document.referrer.length > 0) {
        data.referrer = document.referrer;
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
    time: new Date().getTime() / 1000.0,
    id: generateId(),
    js: true
  };

  ready(function () {
    if (!ahoy.getVisitId()) {
      createVisit();
    }

    ready(function () {
      log(event);

      event.visit_token = ahoy.getVisitId();
      event.visitor_token = ahoy.getVisitorId();

      if (canTrackNow()) {
        trackEventNow(event);
      } else {
        eventQueue.push(event);
        saveEventQueue();

        // wait in case navigating to reduce duplicate events
        setTimeout(function () {
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
    for (var propName in additionalProperties) {
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
    var properties = eventProperties(e);
    properties.text = properties.tag == "input" ? target.value : (target.textContent || target.innerText || target.innerHTML).replace(/[\s\r\n]+/g, " ").trim();
    properties.href = target.href;
    ahoy.track("$click", properties);
  });
};

ahoy.trackSubmits = function () {
  onEvent("submit", "form", function (e) {
    var properties = eventProperties(e);
    ahoy.track("$submit", properties);
  });
};

ahoy.trackChanges = function () {
  onEvent("change", "input, textarea, select", function (e) {
    var properties = eventProperties(e);
    ahoy.track("$change", properties);
  });
};

ahoy.trackAll = function () {
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

documentReady(function () {
  if (config.startOnReady) {
    ahoy.start();
  }
});

exports.default = ahoy;

/***/ }),
/* 1 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


function isUndefined (value) {
  return value === undefined
}

function isObject (value) {
  return value === Object(value)
}

function isArray (value) {
  return Array.isArray(value)
}

function isBlob (value) {
  return value != null &&
      typeof value.size === 'number' &&
      typeof value.type === 'string' &&
      typeof value.slice === 'function'
}

function isFile (value) {
  return isBlob(value) &&
      typeof value.lastModified === 'number' &&
      typeof value.name === 'string'
}

function isDate (value) {
  return value instanceof Date
}

function objectToFormData (obj, fd, pre) {
  fd = fd || new FormData()

  if (isUndefined(obj)) {
    return fd
  } else if (isArray(obj)) {
    obj.forEach(function (value) {
      var key = pre + '[]'

      objectToFormData(value, fd, key)
    })
  } else if (isObject(obj) && !isFile(obj) && !isDate(obj)) {
    Object.keys(obj).forEach(function (prop) {
      var value = obj[prop]

      if (isArray(value)) {
        while (prop.length > 2 && prop.lastIndexOf('[]') === prop.length - 2) {
          prop = prop.substring(0, prop.length - 2)
        }
      }

      var key = pre ? (pre + '[' + prop + ']') : prop

      objectToFormData(value, fd, key)
    })
  } else {
    fd.append(pre, obj)
  }

  return fd
}

module.exports = objectToFormData


/***/ }),
/* 2 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
// http://www.quirksmode.org/js/cookies.html

exports.default = {
  set: function set(name, value, ttl, domain) {
    var expires = "";
    var cookieDomain = "";
    if (ttl) {
      var date = new Date();
      date.setTime(date.getTime() + ttl * 60 * 1000);
      expires = "; expires=" + date.toGMTString();
    }
    if (domain) {
      cookieDomain = "; domain=" + domain;
    }
    document.cookie = name + "=" + escape(value) + expires + cookieDomain + "; path=/";
  },
  get: function get(name) {
    var i = void 0,
        c = void 0;
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

/***/ })
/******/ ])["default"];
});