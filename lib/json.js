var indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

module.exports = {
  parse: function(graph, options) {
    var conn, getInOutName, getName, i, inPort, input, len, name, namedComponents, outPort, output, process, ref, ref1, ref2, src, srcName, srcPort, srcProcess, tgt, tgtName, tgtPort, tgtProcess;
    if (options == null) {
      options = {};
    }
    input = JSON.parse(graph);
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
    ref = input.inports;
    for (name in ref) {
      inPort = ref[name];
      process = getInOutName(name, inPort);
      name = name.toUpperCase();
      inPort.port = inPort.port.toUpperCase();
      output += "INPORT=" + process + "." + inPort.port + ":" + name + "\n";
    }
    ref1 = input.outports;
    for (name in ref1) {
      outPort = ref1[name];
      process = getInOutName(name, inPort);
      name = name.toUpperCase();
      outPort.port = outPort.port.toUpperCase();
      output += "OUTPORT=" + process + "." + outPort.port + ":" + name + "\n";
    }
    output += "\n";
    ref2 = input.connections;
    for (i = 0, len = ref2.length; i < len; i++) {
      conn = ref2[i];
      if (conn.data != null) {
        tgtPort = conn.tgt.port.toUpperCase();
        tgtName = conn.tgt.process;
        tgtProcess = input.processes[tgtName].component;
        tgt = getName(tgtName);
        if (indexOf.call(namedComponents, tgtProcess) < 0) {
          tgt += "(" + tgtProcess + ")";
          namedComponents.push(tgtProcess);
        }
        output += '"' + conn.data + '"' + (" -> " + tgtPort + " " + tgt + "\n");
      } else {
        srcPort = conn.src.port.toUpperCase();
        srcName = conn.src.process;
        srcProcess = input.processes[srcName].component;
        src = getName(srcName);
        if (indexOf.call(namedComponents, srcProcess) < 0) {
          src += "(" + srcProcess + ")";
          namedComponents.push(srcProcess);
        }
        tgtPort = conn.tgt.port.toUpperCase();
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
};
