!function(){var e=Handlebars.template,t=Handlebars.templates=Handlebars.templates||{};t["section.hbs"]=e(function(e,t,a,n,r){function s(e,t,n){var r,s,i="";return i+="\n  ",s={hash:{narrative:e},data:t},i+=p((r=a.addSubViewTo||e.addSubViewTo,r?r.call(e,n.thisView,"NarrativeView",s):o.call(e,"addSubViewTo",n.thisView,"NarrativeView",s)))+"\n"}this.compilerInfo=[4,">= 1.0.0"],a=this.merge(a,e.helpers),r=r||{};var i,h="",o=a.helperMissing,p=this.escapeExpression,c=this;return h+="<h1>Section</h1>\n",i=a.each.call(t,t.narratives,{hash:{},inverse:c.noop,fn:c.programWithDepth(1,s,r,t),data:r}),(i||0===i)&&(h+=i),h+='\n<a class="btn add-narrative">\n	Add Narrative\n</a>\n'}),t["report.hbs"]=e(function(e,t,a,n,r){this.compilerInfo=[4,">= 1.0.0"],a=this.merge(a,e.helpers),r=r||{};var s,i="",h="function",o=this.escapeExpression;return i+="<h1>Report</h1>\n<p>"+o((s=t.report,s=null==s||s===!1?s:s.overview,typeof s===h?s.apply(t):s))+"</p>\n"}),t["narrative.hbs"]=e(function(e,t,a,n,r){this.compilerInfo=[4,">= 1.0.0"],a=this.merge(a,e.helpers),r=r||{};var s,i="",h="function",o=this.escapeExpression;return i+="<p class='content-text'>",(s=a.content)?s=s.call(t,{hash:{},data:r}):(s=t.content,s=typeof s===h?s.apply(t):s),i+=o(s)+"</p>\n"}),t["narrative-edit.hbs"]=e(function(e,t,a,n,r){this.compilerInfo=[4,">= 1.0.0"],a=this.merge(a,e.helpers),r=r||{};var s,i="",h="function",o=this.escapeExpression;return i+="<textarea class='content-text-field'>",(s=a.content)?s=s.call(t,{hash:{},data:r}):(s=t.content,s=typeof s===h?s.apply(t):s),i+=o(s)+"</textarea>\n<a class='btn btn-primary save-narrative'>Save changes</a>\n"}),t["bar_chart.hbs"]=e(function(e,t,a,n,r){this.compilerInfo=[4,">= 1.0.0"],a=this.merge(a,e.helpers),r=r||{};var s="";return s})}();

;
// Generated by CoffeeScript 1.6.3
(function() {
  var _base, _base1, _base2, _base3, _base4, _base5, _base6, _base7, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  (_base = window.Backbone).Models || (_base.Models = {});

  window.Backbone.Models.Report = (function(_super) {
    __extends(Report, _super);

    function Report() {
      _ref = Report.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    return Report;

  })(Backbone.Model);

  (_base1 = window.Backbone).Models || (_base1.Models = {});

  window.Backbone.Models.Narrative = (function(_super) {
    __extends(Narrative, _super);

    function Narrative() {
      _ref1 = Narrative.__super__.constructor.apply(this, arguments);
      return _ref1;
    }

    Narrative.prototype.defaults = {
      content: "Narrative goes here.",
      title: "title",
      editing: true
    };

    Narrative.prototype.url = "/api/narrative";

    return Narrative;

  })(Backbone.Model);

  window.Backbone || (window.Backbone = {});

  (_base2 = window.Backbone).Collections || (_base2.Collections = {});

  Backbone.Collections.NarrativeCollection = (function(_super) {
    __extends(NarrativeCollection, _super);

    function NarrativeCollection() {
      _ref2 = NarrativeCollection.__super__.constructor.apply(this, arguments);
      return _ref2;
    }

    NarrativeCollection.prototype.model = Backbone.Models.Narrative;

    NarrativeCollection.prototype.url = "/api/narrative";

    return NarrativeCollection;

  })(Backbone.Collection);

  window.Backbone || (window.Backbone = {});

  (_base3 = window.Backbone).Views || (_base3.Views = {});

  Backbone.Views.SectionView = (function(_super) {
    __extends(SectionView, _super);

    function SectionView() {
      this.addNarrative = __bind(this.addNarrative, this);
      this.render = __bind(this.render, this);
      _ref3 = SectionView.__super__.constructor.apply(this, arguments);
      return _ref3;
    }

    SectionView.prototype.template = Handlebars.templates['section.hbs'];

    SectionView.prototype.events = {
      "click .add-narrative": "addNarrative"
    };

    SectionView.prototype.initialize = function(options) {
      this.narratives = options.narratives;
      this.narratives.bind('add', this.render);
      return this.narratives.bind('sync', this.render);
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

  (_base4 = window.Backbone).Views || (_base4.Views = {});

  Backbone.Views.ReportView = (function(_super) {
    __extends(ReportView, _super);

    function ReportView() {
      this.render = __bind(this.render, this);
      _ref4 = ReportView.__super__.constructor.apply(this, arguments);
      return _ref4;
    }

    ReportView.prototype.template = Handlebars.templates['report.hbs'];

    ReportView.prototype.initialize = function(options) {
      this.report = options.report;
      return this.render();
    };

    ReportView.prototype.render = function() {
      this.closeSubViews();
      this.$el.html(this.template({
        thisView: this,
        report: this.report.toJSON()
      }));
      this.renderSubViews();
      return this;
    };

    ReportView.prototype.onClose = function() {
      return this.closeSubViews();
    };

    return ReportView;

  })(Backbone.Diorama.NestingView);

  window.Backbone || (window.Backbone = {});

  (_base5 = window.Backbone).Views || (_base5.Views = {});

  Backbone.Views.NarrativeView = (function(_super) {
    __extends(NarrativeView, _super);

    function NarrativeView() {
      this.startEdit = __bind(this.startEdit, this);
      this.saveNarrative = __bind(this.saveNarrative, this);
      this.render = __bind(this.render, this);
      _ref5 = NarrativeView.__super__.constructor.apply(this, arguments);
      return _ref5;
    }

    NarrativeView.prototype.template = Handlebars.templates['narrative.hbs'];

    NarrativeView.prototype.editTemplate = Handlebars.templates['narrative-edit.hbs'];

    NarrativeView.prototype.events = {
      "click .save-narrative": "saveNarrative",
      "click .content-text": "startEdit"
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
      this.narrative.set('title', "title");
      this.narrative.set('content', this.$el.find('.content-text-field').val().replace(/^\s+|\s+$/g, ''));
      this.narrative.set('editing', false);
      return this.narrative.save();
    };

    NarrativeView.prototype.startEdit = function() {
      this.narrative.set('editing', true);
      return this.render();
    };

    NarrativeView.prototype.onClose = function() {};

    return NarrativeView;

  })(Backbone.View);

  window.nrtViz || (window.nrtViz = {});

  nrtViz.chartDataParser = function(data) {
    return _.map(data.features, function(el) {
      return el.attributes;
    });
  };

  window.SAMPLE_DATA = {
    fields: [
      {
        name: "Percentage",
        type: "esriFieldTypeDouble",
        unit: "percentage"
      }, {
        name: "Year",
        type: "esriFieldTypeString",
        unit: "year"
      }
    ],
    features: [
      {
        attributes: {
          Percentage: 28,
          Year: 2010
        }
      }, {
        attributes: {
          Percentage: 26,
          Year: 2011
        }
      }, {
        attributes: {
          Percentage: 32,
          Year: 2012
        }
      }, {
        attributes: {
          Percentage: 132,
          Year: 2013
        }
      }
    ]
  };

  window.nrtViz || (window.nrtViz = {});

  nrtViz.barChart = function(conf) {
    var chart, height, width, xAxis, yAxis;
    if (conf == null) {
      conf = {};
    }
    conf = _.extend(conf, {
      margin: {
        top: 20,
        right: 20,
        bottom: 40,
        left: 30
      },
      width: 760,
      height: 500,
      format: d3.format(".0"),
      xScale: d3.scale.ordinal(),
      yScale: d3.scale.linear()
    });
    width = conf.width - conf.margin.left;
    height = conf.height - conf.margin.top;
    xAxis = d3.svg.axis().scale(conf.xScale).orient("bottom");
    yAxis = d3.svg.axis().scale(conf.yScale).orient("left").tickFormat(conf.format);
    chart = function(selection) {
      var bar, data, g, gEnter, margin, svg, xScale, yScale;
      xScale = conf.xScale;
      yScale = conf.yScale;
      margin = conf.margin;
      xScale.rangeRoundBands([0, width], .1, .02);
      yScale.range([height, 0]);
      data = selection.datum();
      xScale.domain(data.map(function(d) {
        return d.Year;
      }));
      yScale.domain([
        0, d3.max(data, function(d) {
          return d.Percentage;
        })
      ]);
      svg = selection.selectAll("svg").data([data]);
      gEnter = svg.enter().append("svg").append("g");
      gEnter.append("g").attr("class", "x axis");
      gEnter.append("g").attr("class", "y axis");
      svg.attr("width", width + margin.left + margin.right).attr("height", height + margin.top + margin.bottom);
      g = svg.select("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
      g.select(".x.axis").attr("transform", "translate(0," + height + ")").call(xAxis);
      g.select(".y.axis").call(yAxis);
      bar = svg.selectAll('.bar').data(data);
      bar.enter().append("rect").attr("class", function(d) {
        return "bar b_" + d.Year;
      }).attr("x", function(d) {
        return xScale(d.Year) + margin.left;
      }).attr("width", 0).attr("y", function(d) {
        return height;
      }).attr("height", function(d) {
        return 0;
      }).style("fill", "LightSteelBlue ");
      bar.exit().remove();
      return bar.transition().duration(500).attr("x", function(d) {
        return xScale(d.Year) + margin.left;
      }).attr("width", xScale.rangeBand()).attr("y", function(d) {
        return yScale(d.Percentage) + margin.top;
      }).attr("height", function(d) {
        return height - yScale(d.Percentage);
      });
    };
    chart.width = function(c) {
      if (!arguments.length) {
        return width;
      }
      width = c - conf.margin.left - conf.margin.right;
      return chart;
    };
    chart.height = function(c) {
      if (!arguments.length) {
        return height;
      }
      height = c - conf.margin.top - conf.margin.bottom;
      return chart;
    };
    return {
      chart: chart
    };
  };

  window.Backbone || (window.Backbone = {});

  (_base6 = window.Backbone).Views || (_base6.Views = {});

  window.nrtViz || (window.nrtViz = {});

  Backbone.Views.BarChartView = (function(_super) {
    __extends(BarChartView, _super);

    function BarChartView() {
      _ref6 = BarChartView.__super__.constructor.apply(this, arguments);
      return _ref6;
    }

    BarChartView.prototype.initialize = function(options) {
      this.barChart = nrtViz.barChart();
      this.selection = d3.select(this.el);
      return this.width = options.width;
    };

    BarChartView.prototype.render = function() {
      var data;
      data = nrtViz.chartDataParser(window.SAMPLE_DATA);
      this.selection.data([data]);
      this.barChart.chart.width(this.width);
      this.selection.call(this.barChart.chart);
      return this;
    };

    BarChartView.prototype.onClose = function() {};

    return BarChartView;

  })(Backbone.View);

  window.Backbone || (window.Backbone = {});

  (_base7 = window.Backbone).Controllers || (_base7.Controllers = {});

  Backbone.Controllers.ReportsController = (function(_super) {
    __extends(ReportsController, _super);

    function ReportsController() {
      var barchartView, narratives, sectionView, width;
      this.mainRegion = new Backbone.Diorama.ManagedRegion();
      $('#user-section').prepend(this.mainRegion.$el);
      narratives = new Backbone.Collections.NarrativeCollection();
      narratives.fetch();
      sectionView = new Backbone.Views.SectionView({
        narratives: narratives
      });
      this.mainRegion.showView(sectionView);
      this.vizRegion = new Backbone.Diorama.ManagedRegion();
      this.vizRegion.$el.attr("class", "viz");
      $('body').append(this.vizRegion.$el);
      width = this.vizRegion.$el.width();
      barchartView = new Backbone.Views.BarChartView({
        width: width
      });
      this.vizRegion.showView(barchartView);
    }

    return ReportsController;

  })(Backbone.Diorama.Controller);

  Handlebars.registerHelper("debug ", function(optionalValue) {
    console.log("Current Context");
    console.log("====================");
    console.log(this);
    if (optionalValue) {
      console.log("Value");
      console.log("====================");
      return console.log(optionalValue);
    }
  });

}).call(this);
