const indexOf = [].indexOf
  || function indexOf(item) {
    for (let i = 0, l = this.length; i < l; i += 1) {
      if (i in this && this[i] === item) return i;
    }
    return -1;
  };

module.exports = function serialize(graph) {
  let input;
  if (typeof (graph) === 'string') {
    input = JSON.parse(graph);
  } else {
    input = graph;
  }
  const namedComponents = [];
  let output = '';
  function getName(n) {
    let name = n;
    if (input.processes[name].metadata != null) {
      name = input.processes[name].metadata.label;
    }
    if (name.indexOf('/') > -1) {
      name = name.split('/').pop();
    }
    return name;
  }
  function getInOutName(n, data) {
    let name = n;
    if ((data.process != null) && (input.processes[data.process].metadata != null)) {
      name = input.processes[data.process].metadata.label;
    } else if (data.process != null) {
      name = data.process;
    }
    if (name.indexOf('/') > -1) {
      name = name.split('/').pop();
    }
    return name;
  }
  if (input.properties) {
    if (input.properties.environment && input.properties.environment.type) {
      output += `# @runtime ${input.properties.environment.type}\n`;
    }
    Object.keys(input.properties).forEach((prop) => {
      if (!prop.match(/^[a-zA-Z0-9\-_]+$/)) {
        return;
      }
      const propval = input.properties[prop];
      if (typeof propval !== 'string') {
        return;
      }
      if (!propval.match(/^[a-zA-Z0-9\-_\s.]+$/)) {
        return;
      }
      output += `# @${prop} ${propval}\n`;
    });
  }
  Object.keys(input.inports).forEach((name) => {
    const inPort = input.inports[name];
    const process = getInOutName(name, inPort);
    const publicName = input.caseSensitive ? name : name.toUpperCase();
    inPort.port = input.caseSensitive ? inPort.port : inPort.port.toUpperCase();
    output += `INPORT=${process}.${inPort.port}:${publicName}\n`;
  });
  Object.keys(input.outports).forEach((name) => {
    const outPort = input.outports[name];
    const process = getInOutName(name, outPort);
    const publicName = input.caseSensitive ? name : name.toUpperCase();
    outPort.port = input.caseSensitive ? outPort.port : outPort.port.toUpperCase();
    output += `OUTPORT=${process}.${outPort.port}:${publicName}\n`;
  });
  output += '\n';
  for (let i = 0; i < input.connections.length; i += 1) {
    const conn = input.connections[i];
    if (conn.data != null) {
      const tgtPort = input.caseSensitive ? conn.tgt.port : conn.tgt.port.toUpperCase();
      const tgtName = conn.tgt.process;
      const tgtProcess = input.processes[tgtName].component;
      let tgt = getName(tgtName);
      if (indexOf.call(namedComponents, tgtProcess) < 0) {
        tgt += `(${tgtProcess})`;
        namedComponents.push(tgtProcess);
      }
      output += `"${conn.data}" -> ${tgtPort} ${tgt}\n`;
    } else {
      const srcPort = input.caseSensitive ? conn.src.port : conn.src.port.toUpperCase();
      const srcName = conn.src.process;
      const srcProcess = input.processes[srcName].component;
      let src = getName(srcName);
      if (indexOf.call(namedComponents, srcProcess) < 0) {
        src += `(${srcProcess})`;
        namedComponents.push(srcProcess);
      }
      const tgtPort = input.caseSensitive ? conn.tgt.port : conn.tgt.port.toUpperCase();
      const tgtName = conn.tgt.process;
      const tgtProcess = input.processes[tgtName].component;
      let tgt = getName(tgtName);
      if (indexOf.call(namedComponents, tgtProcess) < 0) {
        tgt += `(${tgtProcess})`;
        namedComponents.push(tgtProcess);
      }
      output += `${src} ${srcPort} -> ${tgtPort} ${tgt}\n`;
    }
  }
  return output;
};
