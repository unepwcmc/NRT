!function(){var e=Handlebars.template,a=Handlebars.templates=Handlebars.templates||{};a["section.hbs"]=e(function(e,a,t,n,r){function s(e,a,n){var r,s,i="";return i+="\n  ",s={hash:{narrative:e},data:a},i+=l((r=t.addSubViewTo||e.addSubViewTo,r?r.call(e,n.thisView,"NarrativeView",s):h.call(e,"addSubViewTo",n.thisView,"NarrativeView",s)))+"\n"}this.compilerInfo=[4,">= 1.0.0"],t=this.merge(t,e.helpers),r=r||{};var i,o="",h=t.helperMissing,l=this.escapeExpression,p=this;return o+="<h1>Section</h1>\n",i=t.each.call(a,a.narratives,{hash:{},inverse:p.noop,fn:p.programWithDepth(1,s,r,a),data:r}),(i||0===i)&&(o+=i),o+='\n<button class="add-narrative">Add Narrative</button>\n'}),a["narrative.hbs"]=e(function(e,a,t,n,r){this.compilerInfo=[4,">= 1.0.0"],t=this.merge(t,e.helpers),r=r||{};var s,i="",o="function",h=this.escapeExpression;return i+="<p class='body-text'>",(s=t.body)?s=s.call(a,{hash:{},data:r}):(s=a.body,s=typeof s===o?s.apply(a):s),i+=h(s)+"</p>\n"}),a["narrative-edit.hbs"]=e(function(e,a,t,n,r){this.compilerInfo=[4,">= 1.0.0"],t=this.merge(t,e.helpers),r=r||{};var s,i="",o="function",h=this.escapeExpression;return i+="<textarea class='body-text-field'>\n  ",(s=t.body)?s=s.call(a,{hash:{},data:r}):(s=a.body,s=typeof s===o?s.apply(a):s),i+=h(s)+"\n</textarea>\n<button class='save-narrative'>Save changes</button>\n"})}();

;
// Generated by CoffeeScript 1.6.2
(function() {
  var _base, _base1, _base2, _base3, _base4, _ref, _ref1, _ref2, _ref3,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (_base = window.Backbone).Models || (_base.Models = {});

  window.Backbone.Models.Narrative = (function(_super) {
    __extends(Narrative, _super);

    function Narrative() {
      _ref = Narrative.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    Narrative.prototype.defaults = {
      body: "Narrative goes here.",
      editing: true
    };

    return Narrative;

  })(Backbone.Model);

  window.Backbone || (window.Backbone = {});

  (_base1 = window.Backbone).Collections || (_base1.Collections = {});

  Backbone.Collections.NarrativeCollection = (function(_super) {
    __extends(NarrativeCollection, _super);

    function NarrativeCollection() {
      _ref1 = NarrativeCollection.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    NarrativeCollection.prototype.model = Backbone.Models.Narrative;

    return NarrativeCollection;

  })(Backbone.Collection);

  window.Backbone || (window.Backbone = {});

  (_base2 = window.Backbone).Views || (_base2.Views = {});

  Backbone.Views.SectionView = (function(_super) {
    __extends(SectionView, _super);

    function SectionView() {
      this.addNarrative = __bind(this.addNarrative, this);
      this.render = __bind(this.render, this);      _ref2 = SectionView.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    SectionView.prototype.template = Handlebars.templates['section.hbs'];

    SectionView.prototype.events = {
      "click .add-narrative": "addNarrative"
    };

    SectionView.prototype.initialize = function(options) {
      this.narratives = options.narratives;
      this.narratives.bind('add', this.render);
      return this.render();
    };

    SectionView.prototype.render = function() {
      this.closeSubViews();
      this.$el.html(this.template({
        thisView: this,
        narratives: this.narratives.models
      }));
      this.renderSubViews();
      return this;
    };

    SectionView.prototype.addNarrative = function() {
      var newNarrative;

      newNarrative = new Backbone.Models.Narrative();
      return this.narratives.push(newNarrative);
    };

    SectionView.prototype.onClose = function() {
      return this.closeSubViews();
    };

    return SectionView;

  })(Backbone.Diorama.NestingView);

  window.Backbone || (window.Backbone = {});

  (_base3 = window.Backbone).Views || (_base3.Views = {});

  Backbone.Views.NarrativeView = (function(_super) {
    __extends(NarrativeView, _super);

    function NarrativeView() {
      this.startEdit = __bind(this.startEdit, this);
      this.saveNarrative = __bind(this.saveNarrative, this);
      this.render = __bind(this.render, this);      _ref3 = NarrativeView.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    NarrativeView.prototype.template = Handlebars.templates['narrative.hbs'];

    NarrativeView.prototype.editTemplate = Handlebars.templates['narrative-edit.hbs'];

    NarrativeView.prototype.events = {
      "click .save-narrative": "saveNarrative",
      "click .body-text": "startEdit"
    };

    NarrativeView.prototype.initialize = function(options) {
      this.narrative = options.narrative;
      this.narrative.bind('change', this.render);
      return this.render();
    };

    NarrativeView.prototype.render = function() {
      if (this.narrative.get('editing')) {
        this.$el.html(this.editTemplate(this.narrative.toJSON()));
      } else {
        this.$el.html(this.template(this.narrative.toJSON()));
      }
      return this;
    };

    NarrativeView.prototype.saveNarrative = function(event) {
      this.narrative.set('body', this.$el.find('.body-text-field').val());
      return this.narrative.set('editing', false);
    };

    NarrativeView.prototype.startEdit = function() {
      this.narrative.set('editing', true);
      return this.render();
    };

    NarrativeView.prototype.onClose = function() {};

    return NarrativeView;

  })(Backbone.View);

  window.Backbone || (window.Backbone = {});

  (_base4 = window.Backbone).Controllers || (_base4.Controllers = {});

  Backbone.Controllers.ReportsController = (function(_super) {
    __extends(ReportsController, _super);

    function ReportsController() {
      var narratives, sectionView;

      this.mainRegion = new Backbone.Diorama.ManagedRegion();
      $('body').append(this.mainRegion.$el);
      narratives = new Backbone.Collections.NarrativeCollection();
      sectionView = new Backbone.Views.SectionView({
        narratives: narratives
      });
      this.mainRegion.showView(sectionView);
    }

    return ReportsController;

  })(Backbone.Diorama.Controller);

}).call(this);
