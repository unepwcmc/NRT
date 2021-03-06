# The NRT API
The National Reporting toolkit includes a JSON api to query the indicator and theme data

## Themes

### GET - /api/themes

A complete list of themes

### GET - /api/themes/:id/fat

Returns the theme, including its 'page' narrative

## Indicators

### GET - /api/indicators

A complete list of indicators

### GET - /api/indicators/:id

Show the metadata for a given indicator (IDs can be retrieved from the /api/indicators route)

### GET - /api/indicators/:id/fat

Returns the indicator metadata and also its nested 'page' component, including indicator narratives.

### GET - /api/indicators/:id/headlines

Lists the headline figures for a given indicator (IDs can be retrieved from the /api/indicators route)

### GET - /api/indicators/:id/data

Returns the indicator data for a given indicator, including the data bounds

