# Austin Recycles

## About

"Austin Recycles" consists of a web application plus a web service that
provides trash and recycling pickup information for the City of Austin.

More info here: http://atxhack.wikispaces.com/Austin+Recycles

Demo site: http://austin-recycles.open-austin.org/

Issues and support queue: https://github.com/open-austin/austin-recycles/issues

## Usage

First start the web service.  For development, run "bin/austin-recycles" from
a command line. For production, run via Phusion Passenger.

Then, browse the "index.html" page.

## Requirements

At this time, the "findit-support" package must be manually installed
into the vendor directory. See: vendor/README

The SPATIALITE path may need to be specifically set when running the service:

    SPATIALITE=/usr/local/opt/libspatialite/lib/libspatialite.dylib bin/austin-recycles

For more information, see: vendor/findit-support/README.rdoc

## Web Service API:

The web service provides a simple interface to retrieve service information
for a given location. The location is specified as degrees latitude and
longitude.

Here is an example:

REQUEST:

    GET http://localhost:4567/svc?latitude=30.362&longitude=-97.734 

RESPONSE:

    {
       "origin" : {
          "longitude" : -97.734,
          "latitude" : 30.362
       }
       "routes" : {
          "bulky" : {
             "route" : "BU30",
             "type" : "BULKY",
             "next_service" : {
                "period" : "WEEK",
                "timestamp" : 1376197200000,
                "status" : "PENDING",
                "date" : "08/11/2013",
                "day" : "Sun",
                "slip" : null
             }
          },
          "brush" : {
             "route" : "BR22",
             "type" : "BRUSH",
             "next_service" : {
                "period" : "WEEK",
                "timestamp" : 1368334800000,
                "status" : "PAST",
                "date" : "05/12/2013",
                "day" : "Sun",
                "slip" : null
             }
          },
          "recycle" : {
             "route" : "RHAU14",
             "type" : "RECYCLE",
             "next_service" : {
                "period" : "DAY",
                "timestamp" : 1371704400000,
                "status" : "PENDING",
                "date" : "06/20/2013",
                "day" : "Thu",
                "slip" : null
             }
          },
          "yard_trimming" : {
             "route" : "HY10",
             "type" : "YARD_TRIMMING",
             "next_service" : {
                "period" : "DAY",
                "timestamp" : 1371099600000,
                "status" : "PENDING",
                "date" : "06/13/2013",
                "day" : "Thu",
                "slip" : null
             }
          },
          "garbage" : {
             "route" : "PAH60",
             "type" : "GARBAGE",
             "next_service" : {
                "period" : "DAY",
                "timestamp" : 1371099600000,
                "status" : "PENDING",
                "date" : "06/13/2013",
                "day" : "Thu",
                "slip" : null
             }
          }
       },
    }
    
For each route, the "next_service" fields indicate:

* timestamp - The service date, milliseconds since epoch.
* period - Either DAY (the timestamp indicates the day on which service should occur)
  or WEEK (the timestamp indicates the start of the week in which service should occur)
* date - Printable date, from the service date.
* day - Printable day of week, from the service date.
* status - ACTIVE (the service is happening now or about to happen), PENDING (the service
  is in the future), or PAST (the service has already occurred).
* slip - Number of days the service has slipped due to a holiday, or "null" if no slip.

## Helpful notes

### Installing findit-support and spatialite

Check the "vendor/README" file for instructions for installing the findit-support package.

### Query parameters for debug

You can add query parameters to the application to assist in debugging. Example:

    http://localhost/index.html?svc=http://austin-recycles.open-austin.org/svc&delay=5
    
The supported parameters are:

* svc -- URL of the web service. By default, the web service URL is calculated
  from the document URL, i.e. the web service is assumed to be running on the
  same server as the application. You may want to use this, for instance, if you
  are debugging the application locally, but want to use an instance of the web
  service elsewhere.
  
* delay -- A delay (in seconds) added for web service responses. The delay value
  is passed to the web service, which will delay by that amount before responding.
  I've used this, for instance, when I wanted to verify that the "busy throbber" is
  displaying correctly.

* status -- Override calculated status of a service. The format is "id:status[,id:status...]".
  Example usage: http://stuff?status=recycle:active,bulky:past
  Valid id values are: garbage, yard_trimming, recycle, brush, bulky.
  Valid status values are: active, pending, past.

### Database browser

If you are working with the web service, you may want a tool to browse the database.
The SpatiaLite GUI app is a good tool. You also can use a SQLite tool, even though the
geometry columns will just appear as blobs. One option is:

    https://addons.mozilla.org/en-US/firefox/addon/sqlite-manager/
