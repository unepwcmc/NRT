EventEmitter = require('events').EventEmitter
Sequelize = require("sequelize-mysql").sequelize
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
           `Narratives`.`title` AS `Narratives.title`,
           `Narratives`.`content` AS `Narratives.content`,
           `Narratives`.`id` AS `Narratives.id`,
           `Narratives`.`section_id` AS `Narratives.section_id`
         FROM `Reports`
         LEFT OUTER JOIN `Sections`
           ON `Reports`.`id` = `Sections`.`report_id`
         LEFT OUTER JOIN `Narratives`
           ON `Sections`.`id` = `Narratives`.`section_id`
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

  # should only be one report
  report = cloneJSON reports[0]

  delete report.Sections
  delete report.Narratives

  # for each section, attach the narratives
  report.sections = sections.map (section) ->
    section.narratives = _.where narratives, {section_id: section.id}
    section

  return report

Report.sync()

module.exports = Report
