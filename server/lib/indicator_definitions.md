Indicator definition fields: 

enviroportalId: EAD enviroportal layer id
title: hand-created 'slug'
action: hand-created from [sum, count, average, etc]
unit: if 'sum' or 'average', then give indicator measurement unit
outfields: enviroportal fields to return


Standard request parameters:
  enviroportalUrl = "http://enviroportal.ead./arcgisiis/rest/services"
  f                = pjson
  returnGeometry   = false
  outFields        = 'name,#{outfields}'
  where            = objectid+>+0  # Returns all records, unless we art doing more complex queries
 

Request URL construction:
  enviroportalUrl + sourceUrl +
    /query?
    f=pjson&
    returnGeometry=false&
    outFields='#{outFields}'


Post-receive data manipulation:
  sum: sum all given areas
  count: count all instances of first given outFields
  
Cache response, until replaced by more up-to-date version covering me period

Sample request

http://enviroportal.ead.ae/arcgisiis/rest/services/MapThemes/TerrestalHabitat/MapServer/14/query?
  f=pjson&outFields=shape.area,name&returnGeometry=false&ere=objectid+>+0

Sample response

{
 "displayFieldName": "Name",
 "fieldAliases": {
  "Shape.area": "Shape.area",
  "Name": "Name of Protected Area"
 },
 "fields": [
  {
   "name": "Shape.area",
   "type": "esriFieldTypeDouble",
   "alias": "Shape.area"
  },
  {
   "name": "Name",
   "type": "esriFieldTypeString",
   "alias": "Name of Protected Area",
   "length": 255
  }
 ],
 "features": [
  {
   "attributes": {
    "Shape.area": 0.0078117814322679578,
    "Name": "Jabel Hafit National Park"
   }
  },
  {
   "attributes": {
    "Shape.area": 0.0004111909721562731,
    "Name": "Wathba Wetland Reserve"
   }
  },
  {
   "attributes": {
    "Shape.area": 0.69648989049094367,
    "Name": "Arabian Oryx Protected Area"
   }
  },
  {
   "attributes": {
    "Shape.area": 0.068706831837464608,
    "Name": "Houbara Protected Area"
   }
  }
 ]
}