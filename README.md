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
	   "origin":{
	      "latitude":30.362,
	      "longitude":-97.734
	   },
	   "routes":[
	      {
	         "type":"GARBAGE",
	         "route":"PAH60",
	         "service":{
	            "day":"THURSDAY"
	         }
	      },
	      {
	         "type":"RECYCLE",
	         "route":"RHAU14",
	         "service":{
	            "day":"THURSDAY",
	            "week":"A",
	            "nextrecycle":"03/14/2013"
	         }
	      },
	      {
	         "type":"BRUSH",
	         "route":"BR22",
	         "service":{
	            "nextservdate":"05/12/2013"
	         }
	      },
	      {
	         "type":"BULKY",
	         "route":"BU30",
	         "service":{
	            "nextservdate":"08/11/2013"
	         }
	      },
	      {
	         "type":"YARD_TRIMMING",
	         "route":"HY10"
	      }
	   ]
	}

## Helpful notes
* The atx-recycling.html file may be used to test the service response directly from the open-austin.org server.
* The atx-recycling-dev.html file is the same as atx-recycling.html, but points to localhost for testing the service in local development.
* It may be helpful to use the spatialite gui db browser app to browse the raw database tables.
* Check the vendor/README file for instructions for installing the findit-support package.

## To-do
