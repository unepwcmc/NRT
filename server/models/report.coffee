EventEmitter = require('events').EventEmitter
Sequelize = require("sequelize-mysql").sequelize
moment = require('moment')

Section = require("./section.coffee")
_ = require('underscore')


Report = sequelize.define('Report', {
  title:
    type: Sequelize.STRING
    allowNull: false
  brief:
    type: Sequelize.TEXT
    allowNull: true
  introduction:
    type: Sequelize.TEXT
    allowNull: true
  conclusion:
    type: Sequelize.TEXT
    allowNull: true
  id:
    type: Sequelize.INTEGER
    primaryKey: true
  # TODO: this apparently does not work, any ideas?
  #updatedAt:
  #  type: Sequelize.DATE,
  #  get: ->
  #    moment(@getDataValue('updated_at')).format("MMM Do YY")
}, {
  classMethods:
    findFatReport: (id) ->
      result = new EventEmitter()
      result.error = (fn) ->
        result.on('error', fn)
      result.success = (fn) ->
        result.on('success', fn)

      id = Number(id)
      if isNaN(id)
        return result.emit('error', new Error("invalid id"))

      query = sequelize.query(
        "SELECT Reports.*,
           `Sections`.`title` AS `Sections.title`,
           `Sections`.`report_id` AS `Sections.report_id`,
           `Sections`.`id` AS `Sections.id`,
           `Sections`.`createdAt` AS `Sections.createdAt`,
           `Sections`.`updatedAt` AS `Sections.updatedAt`,
           `Narratives`.`content` AS `Narratives.content`,
           `Narratives`.`id` AS `Narratives.id`,
           `Narratives`.`section_id` AS `Narratives.section_id`,
           `Visualisations`.`data` AS `Visualisations.data`,
           `Visualisations`.`id` AS `Visualisations.id`,
           `Visualisations`.`section_id` AS `Visualisations.section_id`
         FROM `Reports`
         LEFT OUTER JOIN `Sections`
           ON `Reports`.`id` = `Sections`.`report_id`
         LEFT OUTER JOIN `Narratives`
           ON `Sections`.`id` = `Narratives`.`section_id`
         LEFT OUTER JOIN `Visualisations`
           ON `Sections`.`id` = `Visualisations`.`section_id`
         WHERE `Reports`.`id` = #{id};"
      )

      query.error (err) ->
        result.emit('error', err)

      query.success (reports) ->
        if !reports.length
          result.emit('error', new Error('Report not found'))
        else
          result.emit('success', Report.parseFatSQL(reports))

      return result
}, getterMethods: {
    updatedAt: -> 
})

Report.hasMany(Section, foreignKey: 'report_id')

# remove duplicate entries identified by 'id'
uniqID = (arr) -> _.uniq arr, (obj) -> obj.id

# remove entries with 'null' as id
compactID = (arr) -> arr.filter (obj) -> obj.id != null

# create a deep copy of a JSON-compatible object
cloneJSON = (obj) -> JSON.parse JSON.stringify obj

Report.parseFatSQL = (rows) ->
  reports = uniqID compactID rows
  sections = uniqID compactID _.pluck(rows, 'Sections')
  narratives = uniqID compactID _.pluck(rows, 'Narratives')
  visualisations = uniqID compactID _.pluck(rows, 'Visualisations')

  # should only be one report
  report = cloneJSON reports[0]

  delete report.Sections
  delete report.Narratives
  delete report.Visualisations

  # for each section, attach the narratives
  report.sections = sections.map (section) ->
    sectionNarratives = _.where(narratives, section_id: section.id)
    # Should only be max one for now
    section.narrative = (if sectionNarratives.length > 0 then sectionNarratives[0] else null )

    sectionVisualisations = _.where(visualisations, section_id: section.id)
    # Should only be max one for now
    section.visualisation = (if sectionVisualisations.length > 0 then sectionVisualisations[0] else null )

    section

  return report



Report.sync()

module.exports = Report
