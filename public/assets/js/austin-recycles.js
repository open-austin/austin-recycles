
var map;
var geocoder;
var currentMarker = null;


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
    setCurrentLocation(event.latLng);
  });
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
      var loc = new google.maps.LatLng(result.coords.latitude, result.coords.longitude);
      map.setCenter(loc);
      setCurrentLocation(loc);
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
        var r = results[0];
        map.setCenter(r.geometry.location);
        setCurrentLocation(r.geometry.location, r.formatted_address);
      }        
    });  
}


/**
 * Perform a query based on a LatLng location.
 *
 * Obtain the recycling information for the specified location.
 * 
 * Update the street address displayed, either with the information
 * provided, or if none provided, reverse geolocation is performed
 * on the location.
 * 
 * The map marker is moved to the specified location.
 * 
 * The Austin Recycles web service is queried for the specified location.
 */
function setCurrentLocation(loc, address) {    
  view.reset();
  
  if (address) {
    view.address(address);   
  } else {
    geocoder.geocode({'latLng': loc}, function(results, status) {
      if (status != 'OK' || results.length == 0) {
        view.alert("Could not obtain address for the location you specified. (error code " + status + ")");
      } else {
        view.address(results[0].formatted_address);
      }
    });
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

var base_url = 'http://localhost:4567/svc';
//var base_url = 'http://austin-recycles.open-austin.org/svc';

function buildQuery(loc) {
  return base_url + "?latitude=" + loc.lat() + "&longitude=" + loc.lng();  
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
  
  self.reset = function() {
    self.address("");
    self.pickups.removeAll();
    self.alerts.removeAll();
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
        a.icon = 'icon-busy.gif';        
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
