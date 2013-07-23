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

  test("Can see a report's overview", function() {
    var overviewText, report, view;
    overviewText = "Hey, I'm an overview";
    report = new Backbone.Models.Report({
      overview: overviewText
    });
    view = createAndShowReportViewForReport(report);
    assert.match($('#test-container').text(), new RegExp(".*" + overviewText + ".*"));
    return view.close();
  });

}).call(this);
