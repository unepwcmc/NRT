# NRT MongoDB Model Schema

## Indicator
* name: String
* shortName: String
* indicatorDefinition: JSON # Information related to field types and reporting frequency
* indicatorationConfig: JSON # Configuration for querying the datasource
* dpsir: JSON # Which parts of the DPSIR framework it relates to
* theme: Relation # The theme the indicator fits under
* source: JSON # The source or reference for the indicator
* primary: Boolean # Determines if the indicator shows on the dashboard
* description: String

## Indicator data
The data for an indicator.
* indicator: Relation
* data: JSON # Raw JSON data

## Theme
* title: String

## Page
A report page. Can be associated with Themes, Indicators, or nothing.
* title: String 
* parent_id: Relation # Polymorphic parent ID
* parent_type: String # Class of the parent
* sections: [sections] # Array of section models
* is_draft: Boolean # Draft versions are only visible to editors
* headline: JSON # An optional indicator headline value for indicator pages

## Section
A section of a report. Direct child of pages
* title: String
* type: String
* indicator: Relation # Optional reference to an indicator

## Narratives
A piece of narrative text in a report. Child of a section
* section: Relation # Relationship to the parent section
* content: String

## Visualisation
A visualisation. Related to a section
* data: JSON # The data the visualisation displays
* section: Relation
* indicator: Relation # Optional
* type: String # E.g. "Bar chart", "Table"
* map_bounds: []

## User
* name: String
* email: String
* password: String
* salt: String # Salt for the password
* distinguishedName: String # name on LDAP
