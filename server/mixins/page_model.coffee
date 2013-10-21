async = require('async')
Q = require('q')
Page = require('../models/page').model

findSectionWithTitle = (page, title) ->
  for section in page.sections
    return section if section.title is title
  return null

module.exports = {
  publishDraftPage: ->
    deferred = Q.defer()

    publishedPage = null

    Q.nsend(
      Page.findOne({parent_id: @_id, is_draft: true}), 'exec'
    ).then( (page) =>

      if page?
        page.is_draft = false

        Q.nsend(
          page, 'save'
        )
      else
        @getPage()

    ).spread( (page) =>
      publishedPage = page

      @deleteAllPagesExcept(publishedPage.id)
    ).then( ->
      deferred.resolve(publishedPage)
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  discardDraft: ->
    deferred = Q.defer()

    thePage = null

    @getPage().then( (page) =>
      thePage = page
      @deleteAllPagesExcept(page.id)
    ).then( (deletedPage) ->
      deferred.resolve(thePage)
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  deleteAllPagesExcept: (pageId) ->
    deferred = Q.defer()

    Q.nsend(
      Page.remove(parent_id: @_id, _id: {'$ne': pageId }), 'exec'
    ).then( (deletedPage) ->
      deferred.resolve(deletedPage)
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  getDraftPage: ->
    deferred = Q.defer()

    Q.nsend(
      Page.findOne({parent_id: @_id, is_draft: true}), 'exec'
    ).then( (page) =>
      if page?
        Q.nsend(
          Page, 'findFatModel', page._id
        ).then( (fatPage) ->
          deferred.resolve(fatPage)
        )
      else
        @getPage().then( (nonDraftPage) ->
          nonDraftPage.createDraftClone()
        ).then( (clonedPage) ->
          Q.nsend(
            Page, 'findFatModel', clonedPage._id
          )
        ).then( (fatPage) ->
          deferred.resolve(fatPage)
        )
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  getPage: ->
    deferred = Q.defer()

    Q.nsend(
      Page.findOne(parent_id: @_id, is_draft: false), 'exec'
    ).then( (page) =>
      if page?
        deferred.resolve(page)
      else
        Page.create(
          parent_id: @_id
          parent_type: @constructor.modelName
        , (err, page) ->
          if err?
            return deferred.reject(err)

          deferred.resolve(
            page
          )
        )
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  getFatPage: ->
    deferred = Q.defer()

    @getPage().then( (page) ->
      Q.nsend(
        Page, 'findFatModel', page._id
      )
    ).then( (fatPage) ->
      deferred.resolve(fatPage)
    ).fail( (err) ->
      deferred.reject(err)
    )

    return deferred.promise

  toObjectWithNestedPage: (options = {draft: false}) ->
    deferred = Q.defer()

    getMethod = @getFatPage
    getMethod = @getDraftPage if options.draft

    getMethod.call(@).then( (page) =>
      object = @toObject()
      object.page = page

      deferred.resolve(object)
    ).fail( (err) ->
      console.error err
      deferred.reject(err)
    )

    return deferred.promise

  populatePage: ->
    deferred = Q.defer()

    if @page?
      deferred.resolve()
    else
      @getPage().then((page)=>
        @page = page
        deferred.resolve()
      ).fail((err) ->
        deferred.reject(err)
      )

    return deferred.promise

  populateDescriptionFromPage: ->
    deferred = Q.defer()

    section = findSectionWithTitle(@page, 'Description')

    section.getNarrative().then((narrative) =>
      @description = narrative.content
      deferred.resolve(@description)
    ).fail(deferred.reject)

    return deferred.promise

}
