# About
Provides a web service that provides trash and recycling pickup information for the City of Austin.

## Requirements
Run bin/atx-recycles-svc either from a command line for development, or
via Phusion Passenger for production.

The LIBSPATIALITE path may need to be specifically set when running the service:

	LIBSPATIALITE=/usr/local/opt/libspatialite/lib/libspatialite.dylib bin/atx-recycles-svc

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
* The atx-recycling.html file may be used to test the service response.
* It may be helpful to use the spatialite gui db browser app to browse the raw database tables;

## To-do
