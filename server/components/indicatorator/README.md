Indicatorator
=================

Turns environmental parameter data into indicators, by adding text

## Indicatoration configuration

Parameter data is indicatorated following the indicatoration configuration
defined in the indicator schema, under the key 'indicatorationConfig'.

The 'indicatorationConfig' key configures 4 different aspects of the
indicatoration: sources, ranges, sorting, and subindicatoration.

### Sources
Indicators must specify an 'indicatorationConfig.source' attribute. This attribute
tells the indicatorator where to query the data from, and how to format it.

Each 'source' has a corresponding 'getter' module (responsible for
fetching the data) and a 'formatter' module (responsible for formatting
the queried responses).

### Possible 'source' values

#### esri
For indicator data stored in ESRI services and served over their REST JSON API.
When the source property is set to 'esri', the following properties have to be provided:

* `esriConfig`:
  * `serverUrl`: The root of the URl of the server, e.g. http://myserver.net/rest/services
  * `serviceName`: The of the service, e.g. NRT_AD_AirQuality
  * `featureServer`: The feature server ID, e.g. 1

These 3 components can be extracted from an esri rest URL, like so:

    http://myserver.net/rest/services/NRT_AD_AirQuality/FeatureServer/2
    <---------- serverUrl ----------> <- serviceName ->               ^featureServer

#### gdocs

For indicator data stored in Google Drive (aka Google Docs), the property
'indicatorationConfig.spreadsheetKey' must be provided. The spreadsheet in question
must be public *and* 'published for web' (to do so, follow 'File -> Publish for web' in
Google Drive).

The given spreadsheet must contain a worksheet named 'Data', which may contain data
formatted as following:

Year  | Value
----- | -----
1999  | 150
2001  | 200
2014  | 250.2

Years must be provided as integers, while values can be either integers or decimals.

#### cartodb

For indicator data stored in CartoDB tables, the indicatorationConfig
key needs to have the properties `table_name` and CartoDB `username` set. The
CartoDB table must be publicly available.

You can also use [CartoDB
Sync](http://blog.cartodb.com/post/65639747344/synced-tables-create-real-time-maps-from-data-anywhere)
to read spreadsheets into cartodb which will automatically collected (in formats such as XLS, CSV,
etc.) up to every hour.

The format for data is a little constrained due to the fact postgres can't
handle integers column names. You must use column names field_1 through field_n,
and instead put the column headers in as the first row in the table, like so:

field_1 | field_2   | field_3      | field_4 | field_5 | field_n
------- | --------- | ------------ | ------- | ------- | -------
Theme   | Indicator | SubIndicator | 1998    | 1999    | n
Air     | NO2       | -            | 0.4     | 0.9     | n
Air     | O2        | -            | 0.8     | 0.8     | n

The first 3 values should always be Theme, Indicator and SubIndicator, followed
by your date fields in order.

There is an
[example](https://docs.google.com/spreadsheet/ccc?key=0Aum2hJfH1Ze0dGtybGNCeUdTNFk1YWozUlJ1Vm5SQlE&usp=drive_web#gid=0)
data table available on [Google
Docs](https://docs.google.com/spreadsheet/ccc?key=0Aum2hJfH1Ze0dGtybGNCeUdTNFk1YWozUlJ1Vm5SQlE&usp=drive_web#gid=0).

### Ranges

One of the main tasks of the indicatorator is to apply ranges to the
indicatorated data, following the 'indicatorationConfig.range' property,
which is an array.

Every element of the 'range' array is an object composed of two properties:

* `threshold`: the minimum value (following default Javascript comparison) to assign
    a given datum to this range
* `text`: the text to show when the given data is inside this range

If no range application is needed, a 'indicatorationConfig.applyRanges' property set to false
can be provided. This will skip the application of ranges during the import of data.

### Subindicatoration

Basic sub indicator support is implemented by allowing grouping on a text field.
This is achieved by setting the property 'indicatorationConfig.reduceField' to the
group field. For example, if you had a collection of data for the same year but for
different monitoring stations, specify the group field here, e.g. 'station' to have
the data grouped on the station, by periodStart.

### Sorting

As last step of the indicatoration process, data can be sorted by setting the
'indicatorationConfig.sorting' property to an object containing the following two
fields:

* `field`: the field of the indicator data to sort on
* `order`: the order to follow when sorting the data.
    This can be either 'asc' or 'desc', case insensitive.

