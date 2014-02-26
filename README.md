Indicatorator
=================

Turns environmental parameter data into indicators, by adding text! 

## Running it

`npm install`

`coffee app.coffee`

## Indicator definitions

Indicator definitions are stored in `./definitions/indicators.json`. These
files are responsible for listing the indicator and the ranges for the
indicator's threshold. Examples are stored in `./definitions/examples/`

### 'standard' type indicators
Originally, we have different types for different indicators, for
example 'esri', 'cartodb' etc. Now, we're pushing attributes towards a
consistent type named 'standard', and instead handling differences using
the 'source' attribute described below.

### Indicator 'sources'
Indicators must specify a 'source' attribute. This attribute tells the
indicatorator where to query the data from, and how to format it.

Each 'source' has a corresponding 'getter' module (responsible for
fetching the data) and a 'formatter' module (responsible for formatting
the queried responses).

## Possible Source values

### 'gdocs'

For indicator data stored in 'google' docs, your indicator definitions need to
include a `spreadsheet_key` attribute. The spreadsheet in question must be
public *and* 'published for web' from the 'File -> publish for web' in google
docs.

The columns for the table are:

    Theme, Indicator, SubIndicator, <date>, <date>, <date>

The first three are simply strings, name is matched on in the indicator
definition. The date columns should be dates, which will be converted to epochs

### cartodb

For indicator data stored in CartoDB tables, your indicator definitions
need to include `table_name` and CartoDB `username` attributes. The
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
