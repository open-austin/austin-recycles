
var map;
var geocoder;
var currentMarker = null;
var initialLocation = null;


/**
 * Initialize the Austinn Recycles application.
 * @param options
 */
function initialize(options) {
  
  if (! options) {
    options = {};
  }
  
  ko.applyBindings(view);  

  geocoder = new google.maps.Geocoder();
  
  var mapId = options['id'] || 'map_canvas'
  var lat = options['latitude'] || 30.2669;
  var lng = options['longitude'] || -97.7428;
  var mapOptions = {
      center : new google.maps.LatLng(lat, lng),
      zoom : options['zoom'] || 14,
      mapTypeId : options['type'] || google.maps.MapTypeId.ROADMAP
  }
  
  map = new google.maps.Map(document.getElementById(mapId), mapOptions);
  google.maps.event.addListener(map, 'click', function(event) {
    setCurrentLocation(event.latLng, {'recenter': false});
  });
}


/**
 * Action called when user requests a reset to initial location.
 */
function actionReset() {
  if (initialLocation) {
    setCurrentLocation(initialLocation.latLng, {'address' : initialLocation.address});    
  }
  return false; // suppress form submission
}


/**
 * Action called when user enters a street address.
 *
 * Example:
 *   <form onsubmit="return actionSetAddress(this.address.value)">
 *   <input type="text" name="address" />
 */
function actionSetAddress(address) {
  setCurrentAddress(address);
  return false; // suppress form submission
}


/**
 * Action called when user requests device geolocation to be performed.
 * 
 * Example:
 *   <input type="button" value="Find Me" onclick="return actionLocateMe()" />
 */
function actionLocateMe() {
  if (! navigator.geolocation) {
    view.alert("Sorry ... your device does not support geolocation.");
  } else {
    navigator.geolocation.getCurrentPosition(function(result) {
      setCurrentLocation(new google.maps.LatLng(result.coords.latitude, result.coords.longitude));
    });
  }
  return false; // suppress form action
}


/**
 * Perform a query based on a street address.
 *  
 * This method performs geolocation on the address to
 * obtain location (latitude/longitude) information.
 * 
 * If geolocation is successful, then the map is
 * re-centered to the new position and setCurrentLocation()
 * is called to do the rest of the work.
 */
function setCurrentAddress(address) {
  geocoder.geocode(
    {'address': address, 'partialmatch': true},
    function(results, status) {
      if (status != 'OK' || results.length == 0) {
        view.alert("Could not locate the address you specified. (error code " + status + ")");
      } else {
        setCurrentLocation(r.geometry.location, {'address' : results[0].formatted_address});
      }        
    }
  );  
}


/**
 * Perform a query based on a LatLng location.
 *
 * Query the Austin Recycles web service for the given location.
 * 
 * Places a marker at (or moves the existing marker to) the location.
 * 
 * Saves the street address of the location to view.address().
 * 
 * Options:
 * 
 * 'address' - Street address of location. If not specified
 * then reverse geolocation is performed on the location.
 * 
 * 'recenter' - If true, then map is recentered to specified
 * location. If false, then map is not moved. Default is true.
 * 
 */
function setCurrentLocation(loc, options) {    
  view.reset();
  
  if (! options) {
    options = {};
  }
  
  if (options.address) {
    view.address(options.address);   
  } else {
    geocoder.geocode({'latLng': loc}, function(results, status) {
      if (status != 'OK' || results.length == 0) {
        view.alert("Could not obtain address for the location you specified. (error code " + status + ")");
      } else {
        view.address(results[0].formatted_address);
      }
    });
  }
  
  if (! initialLocation) {
    initialLocation = {'latLng' : loc, 'address' : view.address()};
  }
  
  if (options.recenter === undefined || options.recenter) {
    map.setCenter(loc);
  }
  
  if (! currentMarker) {
    currentMarker = new google.maps.Marker({map: map, position: loc});
  } else {
    currentMarker.setPosition(loc);
  }
  
  var busy = view.alert("Retrieving your pickup schedule, stand by ...", {'type': 'busy'});
  $.ajax({
    type: "GET",
    url: buildQuery(loc),
    contentType: "application/json; charset=utf-8",
    dataType: "jsonp",
    success: function (data) {
      view.alerts.remove(busy);
      view.saveResponse(data.origin, data.routes);
    }
  });
    
}


/**
 * Calculate the base URL of a document.
 * @param url
 * @returns {string}
 * 
 * For example, the base URL of "http://example.com/foo/bar/page.html"
 * is "http://example.com/foo/bar".
 */
function getBaseURL(url) {
  var i;
  if ((i = url.lastIndexOf('#')) > 0) {
    url = url.substr(0, i);
  }
  if ((i = url.lastIndexOf('?')) > 0) {
    url = url.substr(0, i);
  }
  if ((i = url.lastIndexOf('/')) > 0) {
    url = url.substr(0, i);
  }
  return url;
}


/**
 * Create an object from the query parameters of the given URL.
 * @param url
 * @returns {object}
 * 
 * Example:
 *   var params = getQueryParams("http://example.com/page?color=red");
 *   alert(params.color);
 */
function getQueryParams(url) {
  var i;
  if ((i = url.indexOf('?')) < 0) {
    return {};
  }
  var params = {};
  url.substr(i+1).split('&').forEach(function(s) {
    var b = s.split('=');
    params[decodeURIComponent(b[0])] = decodeURIComponent(b[1]);
  });
  return params;
}

var QUERY_PARAMS = getQueryParams(document.URL);
var URL_RECYCLES_SVC = (QUERY_PARAMS.svc ? QUERY_PARAMS.svc : getBaseURL(document.URL) + "/svc");


/**
 * Build a web service query URL for a given LatLng location.
 * @param loc
 * @returns {String}
 */
function buildQuery(loc) {
  var q = {
    'latitude' : loc.lat(),
    'longitude' : loc.lng(),
  };
  if (QUERY_PARAMS.delay) {
    q['delay'] = QUERY_PARAMS.delay;
  }
  return URL_RECYCLES_SVC + "?" + $.param(q);
}


/**
 * Class that represents a given pickup service.
 */
var PickupService = function(title, next_service) {
  this.title = title;
  
  if (next_service.period == "WEEK") {
    this.next_pickup = "week of " + next_service.date;
  } else {
    this.next_pickup = next_service.day + ", " + next_service.date;
  }
  
  this.status = "status-" + next_service.status.toLowerCase();
}


var SERVICES = [
  {'id': 'garbage',       'title': 'Garbage'},
  // XXX - yard_trimming out to be same as garbage pickup
  // {'id': 'yard_trimming', 'title': 'Yard trimmings'},
  {'id': 'recycle',       'title': 'Recycling'},
  {'id': 'brush',         'title': 'Brush'},
  {'id': 'bulky',         'title': 'Bulky'},
];


/**
 * Class that provides data bindings for knockout.js.
 */
var ViewModel = function() {
  var self = this;
  
  self.address = ko.observable("");
  self.pickups = ko.observableArray();
  self.alerts = ko.observableArray();
  self.showStartButton = ko.observable(navigator.geolocation !== undefined);
  
  self.reset = function() {
    self.address("");
    self.pickups.removeAll();
    self.alerts.removeAll();
    self.showStartButton(false);
  }
  
  self.alert = function(message, options) {
    if (! options) {
      options = {};
    }
    
    var a = {
        'type' : options['type'],
        'message' : message,
        'isDismissable' : options['dismissable'],
        'icon' : options['icon'],
      };  
    
    switch (a.type) {
    case undefined:
      a.type = 'error';
      break;
    case 'busy':
      a.type = 'info';
      if (a.isDismissable === undefined) {
        a.isDismissable = false;
      }
      if (a.icon === undefined) {
        a.icon = {'src': 'icon-busy.gif', 'height': 32, 'width': 32};        
      }
      break;
    case 'error':
    case 'warn':
    case 'info':
    case 'success':
      break;
    default:
      throw "unknown alert type: " + a.type;
    }
    
    if (a.isDismissable === undefined) {
      a.isDismissable = true;
    }

    self.alerts.push(a);
    return a;
  }
  
  self.saveResponse = function(location, routes) {
    self.pickups.removeAll();
    SERVICES.forEach(function(svc) {
      var route = routes[svc.id];
      if (route && route.next_service) {
        var o = new PickupService(svc.title, route.next_service);
        self.pickups.push(o);
      }    
    });
    if (self.pickups().length == 0) {
      self.alert("Sorry ... no service at this location.");
    }
  }
  
}

var view = new ViewModel();
