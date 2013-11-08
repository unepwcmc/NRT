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
First, it contains the fields required to query the indicator. These vary depending on the type of the indicator.

* **esri**:
  * **serviceName**: The name of the ESRI service, e.g. for this ESRI URL: `/rest/services/NRT_AD_AirQuality/FeatureServer/2/query` the serviceName is  NRT_AD_AirQuality.
  * **featureServer**: The feature server of ESRI service, e.g. for this ESRI URL: `/rest/services/NRT_AD_AirQuality/FeatureServer/2/query` the featureServer is 2.
