(function() {
  var assert;

  assert = chai.assert;

  suite('Report View');

  test("Can see a report's overview", function() {
    var overviewText, report, view;
    report = new Backbone.Models.Report;
    overviewText = "Hey, I'm an overview";
    report.set('overview', overviewText);
    view = new Backbone.Views.ReportView({
      report: report
    });
    $('#test-container').html(view.el);
    debugger;
    return assert.match(new RegExp(".*" + overviewText + ".*"), $('#test-container').text());
  });

}).call(this);
