hrTimeToMs = (time) ->
  time[0]*1000 + time[1]/1000000

calculateTimeDiffInMs = (start, end) ->
  hrTimeToMs(end) - hrTimeToMs(start)
  
module.exports = class BasicTimer
  constructor: (@name) ->
    @markers = []

  addMarker: (label) ->
    @markers.push(
      time: process.hrtime()
      label: label
    )

  finish: ->
    endTime = process.hrtime()
    throw new Error("No markers logged for #{@name}") if @markers.empty?

    console.log "## #{@name} finished, timings:"
    for marker, index in @markers
      nextMarker = @markers[index+1]
      if nextMarker?
        duration = calculateTimeDiffInMs(marker.time, nextMarker.time)
      else
        duration = calculateTimeDiffInMs(marker.time, endTime)

      console.log "\t * #{marker.label}: \t#{duration}ms"

    totalDuration = calculateTimeDiffInMs(@markers[0].time, endTime)

    console.log " Total duration: #{totalDuration}ms"
