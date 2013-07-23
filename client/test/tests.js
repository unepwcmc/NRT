(function() {
  var assert;

  assert = chai.assert;

  suite('Backbone.Models.Report');

}).call(this);

(function() {
  var assert, createAndShowReportViewForReport;

  assert = chai.assert;

  createAndShowReportViewForReport = function(report) {
    var view;
    view = new Backbone.Views.ReportView({
      report: report
    });
    $('#test-container').html(view.el);
    return view;
  };

  suite('Report View');

  test("Can see a report's title", function() {
    var report, title, view;
    title = "My Lovely Report";
    report = new Backbone.Models.Report({
      title: title
    });
    view = createAndShowReportViewForReport(report);
    assert.match($('#test-container').text(), new RegExp(".*" + title + ".*"));
    return view.close();
  });

  test("Can see a report's brief", function() {
    var briefText, report, view;
    briefText = "Hey, I'm the brief";
    report = new Backbone.Models.Report({
      brief: briefText
    });
    view = createAndShowReportViewForReport(report);
    assert.match($('#test-container').text(), new RegExp(".*" + briefText + ".*"));
    return view.close();
  });

  test("Report sections views are rendered", function() {
    var report, section, subView, subViewExists, view, _i, _len, _ref;
    section = new Backbone.Models.Section();
    report = new Backbone.Models.Report({
      sections: [section]
    });
    view = createAndShowReportViewForReport(report);
    subViewExists = false;
    _ref = view.subViews;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      subView = _ref[_i];
      if (subView.constructor.name === "SectionView") {
        subViewExists = true;
      }
    }
    assert(subViewExists);
    return view.close();
  });

}).call(this);
