[![Build Status](https://travis-ci.org/unepwcmc/NRT.png)](https://travis-ci.org/unepwcmc/NRT)

# National Reporting Toolkit

NRT is an online system to help Governments collect, analyse and publish
environmental information quickly and easily. It’s being built by the
UNEP World Conservation Monitoring Centre, in partnership with the
United Nations Environment Programme (UNEP) and the Abu Dhabi Global
Environmental Data Initiative (AGEDI). You can find out more at
[nrt.io](http://nrt.io)

## Technical Architecture
NRT is a web application, written in CoffeeScript. The server component
runs on Node.js and connects to a MongoDB NoSQL back-end. The client-side
component (which runs in the user's browser) is also written in CoffeeScript,
and precompiled to JavaScript before being sent to the user. The more extensive
client-side components use [Backbone.js](), with [Diorama]() extensions for view nesting.

## README Topics
* [Installing and configuring NRT](server/docs/Installation.md)
* [Configuring Indicators](server/docs/IndicatorDefinitions.md)
* [Importing indicators](server/docs/IndicatorImporters.md)
* [Indicatoration](server/components/indicatorator/README.md)
* [Automated Deployment](server/docs/Deployment.md)
* [Development workflow, conventions and tips](server/docs/Tests.md)
* [Application architecture and structure](server/docs/AppStructure.md)
* [Database Entity Schema](server/docs/Schema.md)
* [Testing](server/docs/Tests.md)
* [Analytics](server/docs/analytics.md)

## Production

WCMC team should already have access to [this document](https://docs.google.com/a/peoplesized.com/document/d/1dYMO3PJhRlTDQ2BEUUOcLwqX0IfJ5UP_UYyfQllnXeQ/)

# License

NRT is released under the [BSD 3-Clause](http://opensource.org/licenses/BSD-3-Clause) License

