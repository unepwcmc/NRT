Page = require("../../models/page").model
Section = require("../../models/section").model
_ = require('underscore')
mongoose = require('mongoose')

exports.index = (req, res) ->
  Page
    .find()
    .exec( (err, pages) ->
      if err?
        return res.send(500, "Could not retrieve pages")

      res.send(JSON.stringify(pages))
    )

exports.create = (req, res) ->
  user = req.user
  params = req.body

  page = new Page(params)

  page.canBeEditedBy(req.user).then( ->
    page.save (err, page) ->
      if err?
        console.error err
        return res.send(500, "Could not save page")

      Page
        .findFatModel(page._id, (err, page) ->
          if err?
            console.error err
            res.send(500, "Update to retrieve created page")

          res.send(201, JSON.stringify(page))
        )
  ).fail( (err) ->
    console.error err
    res.send(401, err)
  )

exports.show = (req, res) ->
  Page.findOne(req.params.page, (err, page) ->
    if err?
      console.error err
      return res.send(500, "Could not retrieve page")

    res.send(JSON.stringify(page))
  )

exports.update = (req, res) ->
  pageId = req.params.page

  params = _.omit(req.body, ['_id'])
  updateAttributes = $set: params

  Page.update(
    {_id: pageId},
    updateAttributes,
    (err, rowsChanged) ->
      if err?
        console.error err
        return res.send(500, "Could not update the page")

      if rowsChanged is 0
        error = "Couldn't find page #{pageId} to update"
        console.error error
        return res.send(404, error)

      Page
        .findOne(_id: pageId, (err, page) ->
          if err?
            console.error "Unable to fetch fat page:"
            console.error err
            return res.send(500, "Update to retrieve updated page")

          res.send(200, JSON.stringify(page))
        )
  )

exports.destroy = (req, res) ->
  Page.remove(
    {_id: req.params.page},
    (err, page) ->
      if err?
        res.send(500, "Couldn't delete the page")

      res.send(204)
  )
