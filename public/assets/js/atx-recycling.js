var markersArray = [];
var marker;
var map;
var geocoder;
var currentReverseGeocodeResponse = "";

function initialize() {
  var lat = 30.2669;
  var lng = -97.7428;
    var latlng = new google.maps.LatLng(lat,lng);
    var myOptions = {
      zoom: 14,
      center: latlng,
      mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);

    geocoder = new google.maps.Geocoder();

    // Try HTML5 geolocation
    if(navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(function(position) {
        var startLatLng = new google.maps.LatLng(position.coords.latitude,
                                          position.coords.longitude);
        map.setCenter(startLatLng);
        map.setZoom(14);
        addMarkerAtPosition(startLatLng);
      }, function() {
        handleNoGeolocation(lat, lng, true, 2);
      });
    } else {
      // Browser doesn't support Geolocation
      handleNoGeolocation(lat, lng, false, 2);
    }

    google.maps.event.addListener(map, 'click', function(event) {
        //retrieve the longitude and lattitude of the click point
        var LatLng = event.latLng;
        addMarkerAtPosition(LatLng);
    }); // end of addListener
}

function handleNoGeolocation(lat, lng, errorFlag, zoom_level) {
    var LatLng = new google.maps.LatLng(lat, lng);
    map.setCenter(LatLng);
    map.setZoom(zoom_level);
    addMarkerAtPosition(LatLng);
}

// Deletes all markers in the array by removing references to them
function deleteOverlays() { 
    for (var i=0; i<markersArray.length; i++) {
      markersArray[i].setMap(null);
    }
    markersArray.length = 0;
} // end of deleteOverlays

function getCurrentLatLngText(lat, lng) {
  return '(' + lat +', '+ lng +')';
}

function positionChanged(lat, lng) {
  var latlng = getCurrentLatLngText(lat, lng);
  document.getElementById('formattedAddress').innerHTML = '';
  document.getElementById('recycling').innerHTML = '';
}

function reverseGeocode(lat, lng) {
  positionChanged(lat, lng);
  var latlng = new google.maps.LatLng(lat, lng);
  geocoder.geocode({'latLng': latlng},reverseGeocodeResult);
}

function reverseGeocodeResult(results, status) {
  currentReverseGeocodeResponse = results;
  if(status == 'OK') {
    if(results.length == 0) {
      document.getElementById('formattedAddress').innerHTML = 'None';
    } else {
      document.getElementById('formattedAddress').innerHTML = '<p>' + results[0].formatted_address + '</p>';
    }
  } else {
    document.getElementById('formattedAddress').innerHTML = 'Error';
  }
  attachIWindow();
}

function geocode() {
  var address = document.getElementById("address").value;
  geocoder.geocode({
    'address': address,
    'partialmatch': true}, geocodeResult);
}

function geocodeResult(results, status) {
  if (status == 'OK' && results.length > 0) {
    map.fitBounds(results[0].geometry.viewport);
    var lat = map.getCenter().lat();
    var lng = map.getCenter().lng();
    centerLatLng = map.getCenter();
    addMarkerAtPosition(centerLatLng);
  } else {
    alert("Geocode was not successful for the following reason: " + status);
  }
}

function attachIWindow(){
  position = marker.getPosition();
  lat = position.lat();
  lng = position.lng();
    getRecycling(lat, lng);
    var text = '<p>Lat/Lng: ' + getCurrentLatLngText(lat, lng) + '</p>';
    if(currentReverseGeocodeResponse) {
      var addr = '';
      if(currentReverseGeocodeResponse.length == 0) {
        addr = 'None';
      } else {
        addr = currentReverseGeocodeResponse[0].formatted_address;
      }
      text = text + '<p>' + 'Address: <br>' + addr + '</p>';
    }
    
    var infowindow = new google.maps.InfoWindow({
        content: text
    });
    google.maps.event.addListener(marker, 'click', function(){
      infowindow.open(map, marker);
    });
}

function addMarkerAtPosition(LatLng) {
  marker = new google.maps.Marker({
      map: map, 
      position: LatLng
  });     
  deleteOverlays();
  markersArray.push(marker);
  var newlat = LatLng.lat().toFixed(8);
  var newlng = LatLng.lng().toFixed(8);
  lat = newlat;
  lng = newlng;
  reverseGeocode(lat, lng);
}

function getRecycling(lat, lng) {
  document.getElementById('recycling').innerHTML = '<p>Looking up info...</p>';
    var data;
    var recycleText = "";
    $.ajax({
      type: "GET",
      url: "http://atx-recycles-svc.open-austin.org/svc?latitude=" + lat + "&longitude=" + lng,
      contentType: "application/json; charset=utf-8",
      dataType: "jsonp",
      success: function (data) {
          recycleText = "";
          $.each(data.routes, function(key, val){
              if(val.type === "GARBAGE") {
                recycleText = recycleText + "<p><strong>Garbage day:</strong> " + val.service.day + "</p>";
              } else if(val.type === "RECYCLE") {
                recycleText = recycleText + "<p><strong>Recycle pickup:</strong> " + val.service.nextrecycle + "</p>";
              } else if(val.type === "BULKY") {
                recycleText = recycleText + "<p><strong>Bulky pickup:</strong> " + val.service.nextservdate + "</p>";
              } else if(val.type === "BRUSH") {
                recycleText = recycleText + "<p><strong>Brush pickup:</strong> " + val.service.nextservdate + "</p>";
              }
          });
          if(recycleText === "") {
            recycleText = "<p>Nothing found.</p>";
          }
          $('#recycling').html(recycleText);
      }
    });
}
  
