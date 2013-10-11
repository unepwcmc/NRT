assert = require('chai').assert
helpers = require '../helpers'
Q = require('q')
Narrative = require('../../models/narrative.coffee').model
Visualisation = require('../../models/visualisation.coffee').model
Indicator = require('../../models/indicator.coffee').model
Section = require('../../models/section.coffee').model

suite('Section')
test('.create', (done) ->
  Section = require('../../models/section').model

  section = new Section(title: 'Head Garments and Sea Vessels')
  section.save (err, section) ->
    if err?
      throw 'Section saving failed'

    Section.count (err, count) ->
      if err?
        throw err
        throw 'Failed to find Section'

      assert.equal 1, count
      done()
)

test('.getValidationErrors should return 0 errors if attributes have an indicator id', ->
  Section = require('../../models/section').model
  errors = Section.getValidationErrors(
    indicator: 5
  )
  assert.lengthOf errors, 0
)

test('.cloneNarrativesFrom when given a section id of a section with a narrative
  should duplicate that narrative,
  relate it to the new section,
  and assign it a new id', (done) ->
  originalSection = originalNarrative = newSection = null

  Q.nfcall(
    helpers.createSection
  ).then((section) ->
    originalSection = section

    Q.nfcall(
      helpers.createNarrative, {
        section: section.id
        content: "Some test content"
      }
    )
  ).then((narrative) ->
    originalNarrative = narrative

    Q.nfcall(
      helpers.createSection
    )
  ).then((section) ->
    newSection = section

    newSection.cloneNarrativesFrom(originalSection.id)
  ).then( ->
    Q.nsend(
      Narrative.find(section: newSection.id), 'exec'
    )
  ).then( (clonedNarratives) ->

    assert.lengthOf clonedNarratives, 1, "Expected to have one narrative cloned to new section"
    clonedNarrative = clonedNarratives[0]

    assert.strictEqual clonedNarrative.content, originalNarrative.content,
      "Expected cloned narrative to have the same content as original narrative"

    assert.notStrictEqual clonedNarrative.id, originalNarrative.id,
      "Expected cloned narrative to have a different ID to the original narrative"

    done()
  ).fail((err) ->
    console.error err
    throw err
  )
)

test('.cloneVisualisationsFrom when given a section id of a section with a visualisation
  should duplicate that visualisation,
  relate it to the new section,
  and assign it a new id', (done) ->
  originalSection = originalVisualisation = newSection = null

  Q.nfcall(
    helpers.createSection
  ).then((section) ->
    originalSection = section

    Q.nfcall(
      helpers.createVisualisation, {
        section: section.id
        content: "Some test content"
      }
    )
  ).then((visualisation) ->
    originalVisualisation = visualisation

    Q.nfcall(
      helpers.createSection
    )
  ).then((section) ->
    newSection = section

    newSection.cloneVisualisationsFrom(originalSection.id)
  ).then( ->
    Q.nsend(
      Visualisation.find(section: newSection.id), 'exec'
    )
  ).then( (clonedVisualisations) ->

    assert.lengthOf clonedVisualisations, 1, "Expected to have one visualisation cloned to new section"
    clonedVisualisation = clonedVisualisations[0]

    assert.strictEqual clonedVisualisation.content, originalVisualisation.content,
      "Expected cloned visualisation to have the same content as original visualisation"

    assert.notStrictEqual clonedVisualisation.id, originalVisualisation.id,
      "Expected cloned visualisation to have a different ID to the original visualisation"

    done()
  ).fail((err) ->
    console.error err
    throw err
  )
)
