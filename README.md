# About
Provides a web service that provides trash and recycling pickup information for the City of Austin.

More info here: http://atxcivichack3.wikispaces.com/Recycling+Pickup+App

## Usage
Run bin/atx-recycles-svc either from a command line for development, or
via Phusion Passenger for production.

## Requirements

At this time, the "findit-support" package must be manually installed
into the vendor directory. See: vendor/README

The SPATIALITE path may need to be specifically set when running the service:

        SPATIALITE=/usr/local/opt/libspatialite/lib/libspatialite.dylib bin/atx-recycles-svc

For more information, see: vendor/findit-support/README.rdoc

## Example:
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

## Helpful notes
* It may be helpful to use the spatialite gui db browser app to browse the raw database tables.
* Check the vendor/README file for instructions for installing the findit-support package.

## To-do
