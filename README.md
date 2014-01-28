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
