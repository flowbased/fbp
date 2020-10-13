var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = function serialize(graph, options) {
  var conn, getInOutName, getName, i, inPort, input, len, name, namedComponents, outPort, output, process, ref, ref1, ref2, src, srcName, srcPort, srcProcess, tgt, tgtName, tgtPort, tgtProcess;
  if (options == null) {
    options = {};
  }
  if (typeof(graph) === 'string') {
    input = JSON.parse(graph);
  } else {
    input = graph;
  }
  namedComponents = [];
  output = "";
  getName = function(name) {
    if (input.processes[name].metadata != null) {
      name = input.processes[name].metadata.label;
    }
    if (name.indexOf('/') > -1) {
      name = name.split('/').pop();
    }
    return name;
  };
  getInOutName = function(name, data) {
    if ((data.process != null) && (input.processes[data.process].metadata != null)) {
      name = input.processes[data.process].metadata.label;
    } else if (data.process != null) {
      name = data.process;
    }
    if (name.indexOf('/') > -1) {
      name = name.split('/').pop();
    }
    return name;
  };
  if (input.properties) {
    if (input.properties.environment && input.properties.environment.type) {
      output += "# @runtime " + input.properties.environment.type + "\n";
    }
    Object.keys(input.properties).forEach(function (prop) {
      if (!prop.match(/^[a-zA-Z0-9\-_]+$/)) {
        return;
      }
      var propval = input.properties[prop];
      if (typeof propval !== 'string') {
        return;
      }
      if (!propval.match(/^[a-zA-Z0-9\-_\s\.]+$/)) {
        return;
      }
      output += "# @" + prop + " " + propval + '\n';
    });
  }
  ref = input.inports;
  for (name in ref) {
    inPort = ref[name];
    process = getInOutName(name, inPort);
    name = input.caseSensitive ? name : name.toUpperCase();
    inPort.port = input.caseSensitive ? inPort.port : inPort.port.toUpperCase();
    output += "INPORT=" + process + "." + inPort.port + ":" + name + "\n";
  }
  ref1 = input.outports;
  for (name in ref1) {
    outPort = ref1[name];
    process = getInOutName(name, outPort);
    name = input.caseSensitive ? name : name.toUpperCase();
    outPort.port = input.caseSensitive ? outPort.port : outPort.port.toUpperCase();
    output += "OUTPORT=" + process + "." + outPort.port + ":" + name + "\n";
  }
  output += "\n";
  ref2 = input.connections;
  for (i = 0, len = ref2.length; i < len; i++) {
    conn = ref2[i];
    if (conn.data != null) {
      tgtPort = input.caseSensitive ? conn.tgt.port : conn.tgt.port.toUpperCase();
      tgtName = conn.tgt.process;
      tgtProcess = input.processes[tgtName].component;
      tgt = getName(tgtName);
      if (indexOf.call(namedComponents, tgtProcess) < 0) {
        tgt += "(" + tgtProcess + ")";
        namedComponents.push(tgtProcess);
      }
      output += '"' + conn.data + '"' + (" -> " + tgtPort + " " + tgt + "\n");
    } else {
      srcPort = input.caseSensitive ? conn.src.port : conn.src.port.toUpperCase();
      srcName = conn.src.process;
      srcProcess = input.processes[srcName].component;
      src = getName(srcName);
      if (indexOf.call(namedComponents, srcProcess) < 0) {
        src += "(" + srcProcess + ")";
        namedComponents.push(srcProcess);
      }
      tgtPort = input.caseSensitive ? conn.tgt.port : conn.tgt.port.toUpperCase();
      tgtName = conn.tgt.process;
      tgtProcess = input.processes[tgtName].component;
      tgt = getName(tgtName);
      if (indexOf.call(namedComponents, tgtProcess) < 0) {
        tgt += "(" + tgtProcess + ")";
        namedComponents.push(tgtProcess);
      }
      output += src + " " + srcPort + " -> " + tgtPort + " " + tgt + "\n";
    }
  }
  return output;
}
