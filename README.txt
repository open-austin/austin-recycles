Run bin/atx-recycles-svc either from a command line for development, or
via Phusion Passenger for production.

Example:

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
	    "type":"RECYCLE",
	    "route":"RHAU14",
	    "service":{
	       "day":"THURSDAY",
	       "week":"A"
	    }
	 },
	 {
	    "type":"BRUSH",
	    "route":"BR22"
	 },
	 {
	    "type":"BULKY",
	    "route":"BU30"
	 },
	 {
	    "type":"GARBAGE",
	    "route":"PAH60",
	    "service":{
	       "day":"THURSDAY"
	    }
	 },
	 {
	    "type":"YARD_TRIMMING",
	    "route":"HY10"
	 }
      ]
   }

