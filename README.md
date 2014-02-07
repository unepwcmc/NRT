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

### GDocs configuration

For indicator data stored in google docs, your indicator definitions need to
include a `spreadsheet_key` attribute. The spreadsheet in question must be
public *and* 'published for web' from the 'File -> publish for web' in google
docs.

The columns for the table are:

    Theme, Indicator, SubIndicator, <date>, <date>, <date>

The first three are simply strings, name is matched on in the indicator
definition. The date columns should be dates, which will be converted to epochs

### CartoDB configuration

For indicator data stored in CartoDB tables, your indicator definitions
need to include `table_name` and CartoDB `username` attributes. The
CartoDB table must be publicly available.

It is advisable that you set up [CartoDB
Sync](http://blog.cartodb.com/post/65639747344/synced-tables-create-real-time-maps-from-data-anywhere)
which will automatically collect your data (in formats such as XLS, CSV,
etc.) up to every hour.

The columns for your data should be as so:

    Theme, Indicator, SubIndicator, <date>, <date>, <date>

As Postgresql does not support Integer column names (which we use for
grouping values by year), the columns for the table should be stored in
CartoDB as so:

    Theme, Indicator, SubIndicator, field_1, field_2, [...], field_n

Where `n` is the number of years you have data for. However, usually
this column naming will be handled automatically by CartoDB.
