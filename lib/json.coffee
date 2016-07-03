module.exports =
  parse: (graph, options = {}) ->
    input = JSON.parse graph
    namedComponents = []
    output = ""

    getName = (name) ->
      if input.processes[name].metadata?
        name = input.processes[name].metadata.label

      if name.indexOf('/') > -1
        name = name.split('/').pop()
        #name = name.replace('/', '_')

      return name

    getInOutName = (name, data) ->
      if data.process? and input.processes[data.process].metadata?
        name = input.processes[data.process].metadata.label

      else if data.process?
        name = data.process

      if name.indexOf('/') > -1
        name = name.split('/').pop()

      return name

    for name, inPort of input.inports
      process = getInOutName name, inPort
      name = name.toUpperCase()
      inPort.port = inPort.port.toUpperCase()
      output += "INPORT=#{process}.#{inPort.port}:#{name}\n"

    for name, outPort of input.outports
      process = getInOutName name, inPort
      name = name.toUpperCase()
      outPort.port = outPort.port.toUpperCase()
      output += "OUTPORT=#{process}.#{outPort.port}:#{name}\n"

    # add new lines after input and outports
    output += "\n"

    for conn in input.connections
      # it is data added in the noflo graph (IP)
      if conn.data?
        tgtPort = conn.tgt.port.toUpperCase()
        tgtName = conn.tgt.process
        tgtProcess = input.processes[tgtName].component
        tgt = getName tgtName
        unless tgtProcess in namedComponents
          tgt += "(#{tgtProcess})"
          namedComponents.push tgtProcess
        output += '"' + conn.data + '"' + " -> #{tgtPort} #{tgt}\n"
      # is not data, is a connection
      else
        srcPort = conn.src.port.toUpperCase()
        srcName = conn.src.process
        srcProcess = input.processes[srcName].component
        src = getName srcName
        unless srcProcess in namedComponents
          src += "(#{srcProcess})"
          namedComponents.push srcProcess

        tgtPort = conn.tgt.port.toUpperCase()
        tgtName = conn.tgt.process
        tgtProcess = input.processes[tgtName].component
        tgt = getName tgtName
        unless tgtProcess in namedComponents
          tgt += "(#{tgtProcess})"
          namedComponents.push tgtProcess
        output += "#{src} #{srcPort} -> #{tgtPort} #{tgt}\n"

    return output
