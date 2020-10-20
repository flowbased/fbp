var chai, parser;

if (typeof process !== 'undefined' && process.execPath && process.execPath.indexOf('node') !== -1) {
  if (!chai) {
    chai = require('chai');
  }
  parser = require('../lib/index');
  parser.validateSchema = true; // validate schema for every test on node.js. Don't have tv4 in the browser build
} else {
  parser = require('fbp');
}

describe('FBP parser', function() {
  it('should provide a parse method', function() {
    return chai.expect(parser.parse).to.be.a('function');
  });
  describe('with simple FBP string', function() {
    var fbpData, graphData;
    fbpData = "'somefile' -> SOURCE Read(ReadFile)";
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      chai.expect(graphData).to.be.an('object');
      return chai.expect(graphData.caseSensitive).to.equal(true);
    });
    return describe('the generated graph', function() {
      it('should contain one node', function() {
        return chai.expect(graphData.processes).to.eql({
          Read: {
            component: 'ReadFile'
          }
        });
      });
      return it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0]).to.eql({
          data: 'somefile',
          tgt: {
            process: 'Read',
            port: 'SOURCE'
          }
        });
      });
    });
  });
  describe('with three-statement FBP string', function() {
    var fbpData, graphData;
    fbpData = `'somefile.txt' -> SOURCE Read(ReadFile) OUT -> IN Display(Output)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain two nodes', function() {
        return chai.expect(graphData.processes).to.eql({
          Read: {
            component: 'ReadFile'
          },
          Display: {
            component: 'Output'
          }
        });
      });
      it('should contain an edge and an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        return chai.expect(graphData.connections.length).to.equal(2);
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with three-statement FBP string without instantiation', function() {
    return it('should not fail', function() {
      var fbpData, graphData;
      fbpData = `'db' -> KEY SetDb(Set)
SplitDb(Split) OUT -> VALUE SetDb CONTEXT -> IN MergeContext(Merge)`;
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData.connections).to.have.length(3);
    });
  });
  describe('with no spaces around arrows', function() {
    return it('should not fail', function() {
      var fbpData, graphData;
      fbpData = `a(A)->b(B) ->c(C)-> d(D)->e(E)`;
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData.connections).to.have.length(4);
    });
  });
  describe('with anonymous nodes in an FBP string', function() {
    var fbpData, graphData;
    fbpData = `(A) OUT -> IN (B) OUT -> IN (B)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain three nodes with unique names', function() {
        return chai.expect(graphData.processes).to.eql({
          _A_1: {
            component: 'A'
          },
          _B_1: {
            component: 'B'
          },
          _B_2: {
            component: 'B'
          }
        });
      });
      it('should contain two edges', function() {
        return chai.expect(graphData.connections).to.eql([
          {
            src: {
              process: '_A_1',
              port: 'OUT'
            },
            tgt: {
              process: '_B_1',
              port: 'IN'
            }
          },
          {
            src: {
              process: '_B_1',
              port: 'OUT'
            },
            tgt: {
              process: '_B_2',
              port: 'IN'
            }
          }
        ]);
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with default inport', function() {
    var fbpData, graphData;
    fbpData = `(A) OUT -> (B)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should default port name to "IN"', function() {
        return chai.expect(graphData.connections).to.eql([
          {
            src: {
              process: '_A_1',
              port: 'OUT'
            },
            tgt: {
              process: '_B_1',
              port: 'IN'
            }
          }
        ]);
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with default outport', function() {
    var fbpData, graphData;
    fbpData = `(A) -> IN (B)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should default port name to "OUT"', function() {
        return chai.expect(graphData.connections).to.eql([
          {
            src: {
              process: '_A_1',
              port: 'OUT'
            },
            tgt: {
              process: '_B_1',
              port: 'IN'
            }
          }
        ]);
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with default ports', function() {
    var fbpData, graphData;
    fbpData = `(A) -> (B) -> (C)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should correctly use default ports', function() {
        return chai.expect(graphData.connections).to.eql([
          {
            src: {
              process: '_A_1',
              port: 'OUT'
            },
            tgt: {
              process: '_B_1',
              port: 'IN'
            }
          },
          {
            src: {
              process: '_B_1',
              port: 'OUT'
            },
            tgt: {
              process: '_C_1',
              port: 'IN'
            }
          }
        ]);
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with a more complex FBP string', function() {
    var fbpData, graphData;
    fbpData = `'8003' -> LISTEN WebServer(HTTP/Server) REQUEST -> IN Profiler(HTTP/Profiler) OUT -> IN Authentication(HTTP/BasicAuth)
Authentication() OUT -> IN GreetUser(HelloController) OUT[0] -> IN[0] WriteResponse(HTTP/WriteResponse) OUT -> IN Send(HTTP/SendResponse)
'hello.jade' -> SOURCE ReadTemplate(ReadFile) OUT -> TEMPLATE Render(Template)
GreetUser() DATA -> OPTIONS Render() OUT -> STRING WriteResponse()`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain eight nodes', function() {
        chai.expect(graphData.processes).to.be.an('object');
        return chai.expect(graphData.processes).to.have.keys(['WebServer', 'Profiler', 'Authentication', 'GreetUser', 'WriteResponse', 'Send', 'ReadTemplate', 'Render']);
      });
      it('should contain ten edges and IIPs', function() {
        chai.expect(graphData.connections).to.be.an('array');
        return chai.expect(graphData.connections.length).to.equal(10);
      });
      return it('should contain no exports', function() {
        return chai.expect(graphData.exports).to.be.an('undefined');
      });
    });
  });
  describe('with multiple arrayport connections on same line', function() {
    var fbpData, graphData;
    fbpData = `'test 1' -> IN[0] Mux(mux) OUT[0] -> IN Display(console)
'test 2' -> IN[1] Mux OUT[1] -> IN Display`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      chai.expect(graphData).to.be.an('object');
      chai.expect(graphData.processes).to.be.an('object');
      return chai.expect(graphData.connections).to.be.an('array');
    });
    return describe('the generated graph', function() {
      it('should contain two nodes', function() {
        return chai.expect(graphData.processes).to.have.keys(['Mux', 'Display']);
      });
      it('should contain two IIPs', function() {
        var iips;
        iips = graphData.connections.filter(function(conn) {
          return conn.data;
        });
        chai.expect(iips.length).to.equal(2);
        chai.expect(iips[0].data).to.eql('test 1');
        chai.expect(iips[0].tgt).to.eql({
          process: 'Mux',
          port: 'IN',
          index: 0
        });
        chai.expect(iips[1].data).to.eql('test 2');
        return chai.expect(iips[1].tgt).to.eql({
          process: 'Mux',
          port: 'IN',
          index: 1
        });
      });
      it('should contain two regular connections', function() {
        var connections;
        connections = graphData.connections.filter(function(conn) {
          return conn.src;
        });
        chai.expect(connections.length).to.equal(2);
        chai.expect(connections[0].src).to.eql({
          process: 'Mux',
          port: 'OUT',
          index: 0
        });
        chai.expect(connections[0].tgt).to.eql({
          process: 'Display',
          port: 'IN'
        });
        chai.expect(connections[1].src).to.eql({
          process: 'Mux',
          port: 'OUT',
          index: 1
        });
        return chai.expect(connections[1].tgt).to.eql({
          process: 'Display',
          port: 'IN'
        });
      });
      return it('should contain no exports', function() {
        return chai.expect(graphData.exports).to.be.an('undefined');
      });
    });
  });
  describe('with FBP string containing an IIP with whitespace', function() {
    var fbpData, graphData;
    fbpData = `'foo Bar BAZ' -> IN Display(Output)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain a node', function() {
        return chai.expect(graphData.processes).to.eql({
          Display: {
            component: 'Output'
          }
        });
      });
      it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0].data).to.equal('foo Bar BAZ');
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with FBP string containing an empty IIP string', function() {
    var fbpData, graphData;
    fbpData = `'' -> IN Display(Output)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain a node', function() {
        return chai.expect(graphData.processes).to.eql({
          Display: {
            component: 'Output'
          }
        });
      });
      it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0].data).to.equal('');
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with FBP string containing a JSON IIP string', function() {
    var fbpData, graphData;
    fbpData = `{ "string": "s", "number": 123, "array": [1,2,3], "object": {}} -> IN Display(Output)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain a node', function() {
        return chai.expect(graphData.processes).to.eql({
          Display: {
            component: 'Output'
          }
        });
      });
      it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0].data).to.deep.equal({
          "string": "s",
          "number": 123,
          "array": [1, 2, 3],
          "object": {}
        });
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with FBP string containing comments', function() {
    var fbpData, graphData;
    fbpData = `# Do stuff
'foo bar' -> IN Display(Output) # Here we show the string`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain a node', function() {
        return chai.expect(graphData.processes).to.eql({
          Display: {
            component: 'Output'
          }
        });
      });
      it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0].data).to.equal('foo bar');
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with FBP string containing URL as IIP', function() {
    var fbpData, graphData;
    fbpData = `'http://localhost:5984/default' -> URL Conn(couchdb/OpenDatabase)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain a node', function() {
        return chai.expect(graphData.processes).to.eql({
          Conn: {
            component: 'couchdb/OpenDatabase'
          }
        });
      });
      it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0].data).to.equal('http://localhost:5984/default');
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with FBP string containing RegExp as IIP', function() {
    var fbpData, graphData;
    fbpData = `'_id=(\d+\.\d+\.\d*)=http://iks-project.eu/%deliverable/$1' -> REGEXP MapDeliverableUri(MapPropertyValue)
'path=/_(?!(includes|layouts)' -> REGEXP MapDeliverableUri(MapPropertyValue)
'@type=deliverable' -> PROPERTY SetDeliverableProps(SetProperty)
'#foo' -> SELECTOR Get(dom/GetElement)
'Hi, {{ name }}' -> TEMPLATE Get`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain two nodes', function() {
        return chai.expect(graphData.processes).to.eql({
          MapDeliverableUri: {
            component: 'MapPropertyValue'
          },
          SetDeliverableProps: {
            component: 'SetProperty'
          },
          Get: {
            component: 'dom/GetElement'
          }
        });
      });
      it('should contain IIPs', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(5);
        return chai.expect(graphData.connections[0].data).to.be.a('string');
      });
      return it('should contain no exports', function() {
        chai.expect(graphData.exports).to.be.an('undefined');
        chai.expect(graphData.inports).to.eql({});
        return chai.expect(graphData.outports).to.eql({});
      });
    });
  });
  describe('with FBP string with inports and outports', function() {
    var fbpData, graphData;
    fbpData = `INPORT=Read.IN:FILENAME
INPORT=Display.OPTIONS:OPTIONS
OUTPORT=Display.OUT:OUT
Read(ReadFile) OUT -> IN Display(Output)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain two nodes', function() {
        return chai.expect(graphData.processes).to.eql({
          Read: {
            component: 'ReadFile'
          },
          Display: {
            component: 'Output'
          }
        });
      });
      it('should contain no legacy exports', function() {
        return chai.expect(graphData.exports).to.be.an('undefined');
      });
      it('should contain a single connection', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0]).to.eql({
          src: {
            process: 'Read',
            port: 'OUT'
          },
          tgt: {
            process: 'Display',
            port: 'IN'
          }
        });
      });
      it('should contain two inports', function() {
        chai.expect(graphData.inports).to.be.an('object');
        chai.expect(graphData.inports.FILENAME).to.eql({
          process: 'Read',
          port: 'IN'
        });
        return chai.expect(graphData.inports.OPTIONS).to.eql({
          process: 'Display',
          port: 'OPTIONS'
        });
      });
      return it('should contain an outport', function() {
        chai.expect(graphData.outports).to.be.an('object');
        return chai.expect(graphData.outports.OUT).to.eql({
          process: 'Display',
          port: 'OUT'
        });
      });
    });
  });
  describe('with FBP string with legacy EXPORTs', function() {
    var fbpData, graphData;
    fbpData = `EXPORT=Read.IN:FILENAME
Read(ReadFile) OUT -> IN Display(Output)`;
    graphData = null;
    return it('should fail', function() {
      return chai.expect(function() {
        return graphData = parser.parse(fbpData, {
          caseSensitive: true
        });
      }).to.throw(Error);
    });
  });
  describe('with FBP string containing node metadata', function() {
    var fbpData, graphData;
    fbpData = `Read(ReadFile) OUT -> IN Display(Output:foo=bar)

# And we drop the rest
Display OUT -> IN Drop(Drop:foo=baz,baz=/foo/bar)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    it('should contain nodes with named routes', function() {
      return chai.expect(graphData.processes).to.eql({
        Read: {
          component: 'ReadFile'
        },
        Display: {
          component: 'Output',
          metadata: {
            foo: 'bar'
          }
        },
        Drop: {
          component: 'Drop',
          metadata: {
            foo: 'baz',
            baz: '/foo/bar'
          }
        }
      });
    });
    it('should contain two edges', function() {
      chai.expect(graphData.connections).to.be.an('array');
      return chai.expect(graphData.connections.length).to.equal(2);
    });
    return it('should contain no exports', function() {
      chai.expect(graphData.exports).to.be.an('undefined');
      chai.expect(graphData.inports).to.eql({});
      return chai.expect(graphData.outports).to.eql({});
    });
  });
  describe('with FBP string containing node x/y metadata', function() {
    var fbpData, graphData;
    fbpData = `Read(ReadFile) OUT -> IN Display(Output:foo=bar,x=17,y=42)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return it('should contain nodes with numerical x/y metadata', function() {
      return chai.expect(graphData.processes).to.eql({
        Read: {
          component: 'ReadFile'
        },
        Display: {
          component: 'Output',
          metadata: {
            foo: 'bar',
            x: 17,
            y: 42
          }
        }
      });
    });
  });
  describe('with an invalid FBP string', function() {
    var fbpData;
    fbpData = `'foo' --> Display(Output)`;
    return it('should fail with an Exception', function() {
      return chai.expect(function() {
        return parser.parse(fbpData, {
          caseSensitive: true
        });
      }).to.throw(Error);
    });
  });
  describe('with a component that contains dashes in name', function() {
    var fbpData, graphData;
    fbpData = "'somefile' -> SOURCE Read(my-cool-component/ReadFile)";
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain one node', function() {
        return chai.expect(graphData.processes).to.eql({
          Read: {
            component: 'my-cool-component/ReadFile'
          }
        });
      });
      return it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        return chai.expect(graphData.connections.length).to.equal(1);
      });
    });
  });
  describe('with commas to separate statements', function() {
    var fbpData, graphData;
    fbpData = "'Hello' -> IN Foo(Component), 'World' -> IN Bar(OtherComponent), Foo OUT -> DATA Bar";
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain two nodes', function() {
        return chai.expect(graphData.processes).to.eql({
          Foo: {
            component: 'Component'
          },
          Bar: {
            component: 'OtherComponent'
          }
        });
      });
      return it('should contain two IIPs and one edge', function() {
        return chai.expect(graphData.connections).to.eql([
          {
            data: 'Hello',
            tgt: {
              process: 'Foo',
              port: 'IN'
            }
          },
          {
            data: 'World',
            tgt: {
              process: 'Bar',
              port: 'IN'
            }
          },
          {
            src: {
              process: 'Foo',
              port: 'OUT'
            },
            tgt: {
              process: 'Bar',
              port: 'DATA'
            }
          }
        ]);
      });
    });
  });
  describe('with underscores and numbers in ports, nodes, and components', function() {
    var fbpData, graphData;
    fbpData = "'Hello 09' -> IN_2 Foo_Node_42(Component_15)";
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain one node', function() {
        return chai.expect(graphData.processes).to.eql({
          Foo_Node_42: {
            component: 'Component_15'
          }
        });
      });
      return it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0]).to.eql({
          data: 'Hello 09',
          tgt: {
            process: 'Foo_Node_42',
            port: 'IN_2'
          }
        });
      });
    });
  });
  describe('with dashes and numbers in nodes, and components', function() {
    var fbpData, graphData;
    fbpData = "'Hello 09' -> IN_2 Foo-Node-42(Component-15)";
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain one node', function() {
        return chai.expect(graphData.processes).to.eql({
          'Foo-Node-42': {
            component: 'Component-15'
          }
        });
      });
      return it('should contain an IIP', function() {
        chai.expect(graphData.connections).to.be.an('array');
        chai.expect(graphData.connections.length).to.equal(1);
        return chai.expect(graphData.connections[0]).to.eql({
          data: 'Hello 09',
          tgt: {
            process: 'Foo-Node-42',
            port: 'IN_2'
          }
        });
      });
    });
  });
  describe('with FBP string containing port indexes', function() {
    var fbpData, graphData;
    fbpData = `Read(ReadFile) OUT[1] -> IN Display(Output:foo=bar)

# And we drop the rest
Display OUT -> IN[0] Drop(Drop:foo=baz,baz=/foo/bar)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    it('should contain nodes with named routes', function() {
      return chai.expect(graphData.processes).to.eql({
        Read: {
          component: 'ReadFile'
        },
        Display: {
          component: 'Output',
          metadata: {
            foo: 'bar'
          }
        },
        Drop: {
          component: 'Drop',
          metadata: {
            foo: 'baz',
            baz: '/foo/bar'
          }
        }
      });
    });
    it('should contain two edges', function() {
      chai.expect(graphData.connections).to.be.an('array');
      return chai.expect(graphData.connections).to.eql([
        {
          src: {
            process: 'Read',
            port: 'OUT',
            index: 1
          },
          tgt: {
            process: 'Display',
            port: 'IN'
          }
        },
        {
          src: {
            process: 'Display',
            port: 'OUT'
          },
          tgt: {
            process: 'Drop',
            port: 'IN',
            index: 0
          }
        }
      ]);
    });
    return it('should contain no exports', function() {
      chai.expect(graphData.exports).to.be.an('undefined');
      chai.expect(graphData.inports).to.eql({});
      return chai.expect(graphData.outports).to.eql({});
    });
  });
  describe('with case-sensitive FBP string', function() {
    var fbpData, graphData;
    fbpData = "'Hello' -> in Foo(Component), 'World' -> inPut Bar(OtherComponent), Foo outPut -> data Bar";
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      return chai.expect(graphData).to.be.an('object');
    });
    return describe('the generated graph', function() {
      it('should contain two nodes', function() {
        return chai.expect(graphData.processes).to.eql({
          Foo: {
            component: 'Component'
          },
          Bar: {
            component: 'OtherComponent'
          }
        });
      });
      return it('should contain two IIPs and one edge', function() {
        return chai.expect(graphData.connections).to.eql([
          {
            data: 'Hello',
            tgt: {
              process: 'Foo',
              port: 'in'
            }
          },
          {
            data: 'World',
            tgt: {
              process: 'Bar',
              port: 'inPut'
            }
          },
          {
            src: {
              process: 'Foo',
              port: 'outPut'
            },
            tgt: {
              process: 'Bar',
              port: 'data'
            }
          }
        ]);
      });
    });
  });
  describe('should convert port names to lowercase by default', function() {
    var fbpData, graphData;
    fbpData = `INPORT=Read.IN:FILENAME
INPORT=Display.OPTIONS:OPTIONS
OUTPORT=Display.OUT:OUT
Read(ReadFile) OUT -> IN Display(Output)

ReadIndexed(ReadFile) OUT[1] -> IN DisplayIndexed(Output:foo=bar)
DisplayIndexed OUT -> IN[0] Drop(Drop:foo=baz,baz=/foo/bar)`;
    graphData = null;
    beforeEach(function() {
      return graphData = parser.parse(fbpData);
    });
    it('should produce a graph JSON object', function() {
      chai.expect(graphData).to.be.an('object');
      return chai.expect(graphData.caseSensitive).to.equal(false);
    });
    it('should contain connections', function() {
      chai.expect(graphData.connections).to.be.an('array');
      chai.expect(graphData.connections.length).to.equal(3);
      return chai.expect(graphData.connections).to.eql([
        {
          src: {
            process: 'Read',
            port: 'out'
          },
          tgt: {
            process: 'Display',
            port: 'in'
          }
        },
        {
          src: {
            process: 'ReadIndexed',
            port: 'out',
            index: 1
          },
          tgt: {
            process: 'DisplayIndexed',
            port: 'in'
          }
        },
        {
          src: {
            process: 'DisplayIndexed',
            port: 'out'
          },
          tgt: {
            process: 'Drop',
            port: 'in',
            index: 0
          }
        }
      ]);
    });
    it('should contain two inports', function() {
      chai.expect(graphData.inports).to.be.an('object');
      chai.expect(graphData.inports.filename).to.eql({
        process: 'Read',
        port: 'in'
      });
      return chai.expect(graphData.inports.options).to.eql({
        process: 'Display',
        port: 'options'
      });
    });
    return it('should contain an outport', function() {
      chai.expect(graphData.outports).to.be.an('object');
      return chai.expect(graphData.outports.out).to.eql({
        process: 'Display',
        port: 'out'
      });
    });
  });
  describe('with FBP string with source node that doesn\'t have a component defined', function() {
    var fbpData, graphData;
    fbpData = `instanceMissingComponentName OUT -> (core/Output)`;
    graphData = null;
    return it('should fail', function() {
      return chai.expect(function() {
        return graphData = parser.parse(fbpData, {
          caseSensitive: true
        });
      }).to.throw(Error, 'Edge to "_core_Output_1" port "IN" is connected to an undefined source node "instanceMissingComponentName"');
    });
  });
  describe('with FBP string with IIP sent to node that doesn\'t have a component defined', function() {
    var fbpData, graphData;
    fbpData = `'localhost' -> IN instanceMissingComponentName`;
    graphData = null;
    return it('should fail', function() {
      return chai.expect(function() {
        return graphData = parser.parse(fbpData, {
          caseSensitive: true
        });
      }).to.throw(Error, 'IIP containing "localhost" is connected to an undefined target node "instanceMissingComponentName"');
    });
  });
  describe('with FBP string with target node that doesn\'t have a component defined', function() {
    var fbpData, graphData;
    fbpData = `a(A)->b(B) ->c(C)-> d(D)->e`;
    graphData = null;
    return it('should fail', function() {
      return chai.expect(function() {
        return graphData = parser.parse(fbpData, {
          caseSensitive: true
        });
      }).to.throw(Error, 'Edge from "d" port "OUT" is connected to an undefined target node "e"');
    });
  });
  describe('with FBP string with exported inport pointing to non-existing node', function() {
    var fbpData, graphData;
    fbpData = `INPORT=noexist.IN:broken
INPORT=exist.IN:works
exist(foo/Bar)`;
    graphData = null;
    return it('should fail', function() {
      return chai.expect(function() {
        return graphData = parser.parse(fbpData, {
          caseSensitive: true
        });
      }).to.throw(Error, 'Inport "broken" is connected to an undefined target node "noexist"');
    });
  });
  describe('with FBP string with exported outport pointing to non-existing node', function() {
    var fbpData, graphData;
    fbpData = `INPORT=exist.IN:works
OUTPORT=noexist.OUT:broken
exist(foo/Bar)`;
    graphData = null;
    return it('should fail', function() {
      return chai.expect(function() {
        return graphData = parser.parse(fbpData, {
          caseSensitive: true
        });
      }).to.throw(Error, 'Outport "broken" is connected to an undefined source node "noexist"');
    });
  });
  describe('with FBP string containing a runtime annotation', function() {
    var fbpData, graphData;
    fbpData = `# @runtime foo
'somefile' -> SOURCE Read(ReadFile)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      chai.expect(graphData).to.be.an('object');
      return chai.expect(graphData.caseSensitive).to.equal(true);
    });
    return it('should contain the runtime type property', function() {
      return chai.expect(graphData.properties.environment.type).to.equal('foo');
    });
  });
  describe('with FBP string containing a name annotation', function() {
    var fbpData, graphData;
    fbpData = `# @name ReadSomefile
'somefile' -> SOURCE Read(ReadFile)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      chai.expect(graphData).to.be.an('object');
      return chai.expect(graphData.caseSensitive).to.equal(true);
    });
    return it('should contain the name', function() {
      return chai.expect(graphData.properties.name).to.equal('ReadSomefile');
    });
  });
  return describe('with FBP string containing two annotations', function() {
    var fbpData, graphData;
    fbpData = `# @runtime foo
# @name ReadSomefile
'somefile' -> SOURCE Read(ReadFile)`;
    graphData = null;
    it('should produce a graph JSON object', function() {
      graphData = parser.parse(fbpData, {
        caseSensitive: true
      });
      chai.expect(graphData).to.be.an('object');
      return chai.expect(graphData.caseSensitive).to.equal(true);
    });
    it('should contain the runtime type property', function() {
      return chai.expect(graphData.properties.environment.type).to.equal('foo');
    });
    return it('should contain the name', function() {
      return chai.expect(graphData.properties.name).to.equal('ReadSomefile');
    });
  });
});
