window.Backbone ||= {}
window.Backbone.Faker ||= {}

class Backbone.Faker.Reports
  @create: =>
    new Backbone.Models.Report(
      title: "#{@getRandomReportContent('title_prefix')} #{@getRandomReportContent('title_suffix')}"
      brief: @getRandomReportContent('brief')
      sections: @createSections()
    )

  @getRandomReportContent: (component) =>
    component = @report_content[component]
    component[Math.floor(Math.random()*component.length)]

  @createSections: (count) =>
    sections = []
    count ||= Math.floor(Math.random()*14) + 1
    _.times count, =>
      section = new Backbone.Models.Section
        id: Math.floor(Math.random()*100000)
        title: @getRandomSectionContent('title')
        narrative:
          content: _.times(14, -> "This is all the narrative you're going to get. Seriously. ").join(" ")
          editing: false
        visualisations: @createVisualisations()
      sections.push section
    sections

  @createVisualisations: =>
    count = Math.floor(Math.random()*1) + 1
    visualisations = []
    _.times count, =>
      visualisations.push new Backbone.Models.Visualisation(
        data: @createFakeData()
      )
    visualisations

  @createFakeData: =>
    features = []
    year = 2010
    _.times Math.floor(Math.random()*5) + 3, ->
      features.push(
        attributes:
          Percentage: Math.floor(Math.random()*99) + 1
          Year: year
      )
      year = year + 1

    fields: [
        name: "Percentage"
        type: "esriFieldTypeDouble"
        unit: "percentage"
      ,
        name: "Year"
        type: "esriFieldTypeString"
        unit: "year"
      ]
      features: features

  @getRandomSectionContent: (component) =>
    component = @section_content[component]
    component[Math.floor(Math.random()*component.length)]

  @report_content: 
    title_prefix: ["Heavily Carpeted", "Water Quality", "Air Quality", "Toast Flavour", "Leopard study", "Really Quick", "Substandard", "Interesting"]
    title_suffix: ["Quarterly Report", "Annual Report", "Special Report", "Secret Report", "Communications Package"]
    brief: [
      "Please write something useful.",
      "Please write something else.",
      "This is for public consumption, be careful what you write.",
      "This is for internal use - let rip with your real feelings. What do you really think?",
      "This will be read by noone. Ever. And then thrown away. On fire.",
      "I want 1000 words on this by the end of Neveruary."
    ]

  @section_content:
    title: [
      "Terrestrial and marine habitats conservation",
      "Habitat rehabilitation and restoration",
      "Abundance of Selected Key Species ",
      "Area of Selected Key Ecosystems",
      "Evolution of Estimated Population of Threatened Species TMS (Dugongs)",
      "Evolution of Estimated Population of Threatened Species – TMS (Marine Turtles)",
      "Evolution of Threatened Species",
      "Halt the overall loss of biodiversity in Abu Dhabi",
      "Restrict loss of bird species in Abu Dhabi",
      "Remove the threat to faunal and floral biodiversity from invasive species",
      "Ensure that no species of wild flora or fauna are endangered by international trade",
      "Number of Alien (Invasive) Species/Abundance",
      "Percent Increase in the Area of Citizen Farms"
    ]

    visualisations: [ new Backbone.Models.Visualisation() ]
