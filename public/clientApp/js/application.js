!function(){var e=Handlebars.template,t=Handlebars.templates=Handlebars.templates||{};t["test.hbs"]=e(function(e,t,s,a,n){return this.compilerInfo=[4,">= 1.0.0"],s=this.merge(s,e.helpers),n=n||{},"<h1>Test View</h1>\n"})}();

;
// Generated by CoffeeScript 1.6.2
(function() {
  var _base, _ref,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  window.Backbone || (window.Backbone = {});

  (_base = window.Backbone).Views || (_base.Views = {});

  Backbone.Views.TestView = (function(_super) {
    __extends(TestView, _super);

    function TestView() {
      _ref = TestView.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    TestView.prototype.template = Handlebars.templates['test.hbs'];

    TestView.prototype.initialize = function(options) {
      return this.render();
    };

    TestView.prototype.render = function() {
      this.$el.html(this.template());
      return this;
    };

    TestView.prototype.onClose = function() {};

    return TestView;

  })(Backbone.View);

}).call(this);
