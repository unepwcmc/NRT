# Defining indicators
The indicators the application is seeded with are defined inside
lib/seed_indicators.json. This document describes the fields indicators are
expected to have, and how they affect the behavior of the application 

## Fields

* **short_name** - The short title of the indicator.
* **title** - Full title of the indicator
* **sections** - A array of sections to seed the page with. Each section should consist of a title and content attribute.
* **theme** - The title of the theme that the indicators refers to. This is turned into a proper ID association when seeded.
* **type** - Indicators query data from the indicatorator. The indicatorator has a number of different data sources, which this field chooses between. This field is also used to determine if indicators are 'core' (from Abu Dhabi) or 'external' (From other services, e.g. the world bank).
  * **esri** (core) - Data is to be queried from an ESRI web service. Currently, all Abu Dhabi data is served by an ESRI service, so indicators with this type are considered to be 'core'
  * **worldBank** (external) - Data queried from the World Bank APIs
  * **cartodb** (external) - Data queried from Cartodb. Currently this is only blue carbon data.
* **indicatorDefinition** - See the Indicator Definition section

### indicatorDefinition
The indicator definition field serves 2 functions.

#### Query information
These attributes are used to build the query that gets sent to the indicatorator. They vary based on the type of the indicator. Below is the list of fields you need for each type:

* **esri**:
  * **serviceName**: The name of the ESRI service, e.g. for this ESRI URL: `/rest/services/NRT_AD_AirQuality/FeatureServer/2/query` the serviceName is  NRT_AD_AirQuality.
  * **featureServer**: The feature server of ESRI service, e.g. for this ESRI URL: `/rest/services/NRT_AD_AirQuality/FeatureServer/2/query` the featureServer is 2.
* **worldBank**:
  * **apiUrl**: This takes the base URL of the indicatorator service, plus the name of the country, e.g. to proxy the query through the indicatorator
    * "http://localhost:3002/wb/ARE"
  * **apiIndicatorName**: The world bank name of the indicator, e.g. "NY.ADJ.DCO2.GN.ZS"
* **cartodb**:
  * **cartodb_user**: The cartodb user the table is exists
  * **cartodb_tablename**: the table to query
  * **query**: They SQL query to perform on the table

#### Field specifications
These fields tell the application how to interpret the indicator data.

* **unit**: The full name of the unit of the yAxis
* **short_unit**: The short name of above
* **period**: The frequency at which the indicator is calculated, e.g. 'annual'
* **xAxis**: The name of the field which acts as the xAxis. This is typically a temporal field
* **yAxis**: The name of the field which acts as the yAxis. This is typically an amount, e.g. number of exceedances.
* **fields**: A array containing a definition for each field in the data. Below is the expected attributes for each row
  * **name**: The name of the a field
  * **type**: The type of the a field. Possible types:
    * **integer**: An integer
    * **date**: A date
    * **text**: A string
  * **source**: The data which comes from the indicatorator is transformed from into the fields shown above. This attribute describes the name an type of the field in the source:
    * **name**: The name of the field in the source
    * **type**: The type of the data in the source. If this is different from the destination type, it will be converted. The possible types are:
      * **epoch**: An integer representing the date
      * **integer**: An integer
      * **text**: A string
      * **decimalPercentage**: A percentage represented as a decimal, where 1 would be 100%
* **subIndicatorsField**: The name of the field containing sub indicators. If specified, this field should be present on each row of indicator data.
      
