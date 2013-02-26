#!/bin/sh

DATABASE="../collection_routes.db"

DATASETS="
	brush_collection_routes
	bulky_collection_routes
	garbage_collection_routes
	recycle_collection_routes
	yard_trimming_collection_routes
"

if [ -f "$DATABASE" ] ; then
        echo "$0: will not overwrite existing database \"$DATABASE\"" >&2
        exit 1
fi

for ds in $DATASETS ; do
	echo ".loadshp $ds $ds CP1252"
done | spatialite $DATABASE

