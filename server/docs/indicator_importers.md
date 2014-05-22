# Importing indicators
After the initial indicator definitions have been populated from the
seeds folder on the first startup of the application, additional indicators
can be imported through specific importers.

As of now, the available importers are:

## Google Drive (aka Google Docs)
An indicator can be imported from a Google Spreadsheet via the admin interface,
by providing the spreadsheet key. This can be found in the URL that points to
the spreadsheet itself. For instance:

    https://docs.google.com/spreadsheets/d/12-n-xlzFlT3T1dScfaI7a7ZnhEILbtSCjXSNKbfLJEI/pubhtml
                                           <------------- spreadsheet key ------------>

### Spreadsheet structure
The given spreadsheet must at least contain three worksheets,
in no particular order:

#### 'Definition' worksheet
This worksheet defines the main properties of the wanted indicator.
Specifically, three values must be provided on the second row of
the worksheet. The first row may comprise indicative headers.
As an example:

What's the name of this indicator? | What theme does this indicator relate to? | What unit does the indicator value use?
---------------------------------- | ----------------------------------------- | ---------------------------------------
Indicator Name                     | Theme name                                | mg/m3

#### 'Ranges' worksheet
This worksheet defines the ranges to be applied to the indicator.
These have to be provided as a list of (Threshold,Text) tuples on
the first two columns of the worksheet. The first row is skipped,
and can be used for informative headers. As an example:

Threshold | Text
--------- | ----
0.5       | Good
2.5       | Bad
5         | Dangerous
100       | Catastrophic

#### 'Data' worksheet
This worksheet is not used during the import process, but has to
be present for the indicatoration to succesfully import and
indicatorate the environmental data. Further information on this
process can be found in the
[indicatoration documentation](../components/indicatoration/README.md)
