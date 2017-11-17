if typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1
  chai = require 'chai' unless chai
  parser = require '../lib/fbp'
  parser.validateSchema = true # validate schema for every test on node.js. Don't have tv4 in the browser build
else
  parser = require 'fbp'

describe 'FBP parser', ->
  it 'should provide a parse method', ->
    chai.expect(parser.parse).to.be.a 'function'
  describe 'with simple FBP string', ->
    fbpData = "'somefile' -> SOURCE Read(ReadFile)"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
      chai.expect(graphData.caseSensitive).to.equal true
    describe 'the generated graph', ->
      it 'should contain one node', ->
        chai.expect(graphData.processes).to.eql
          Read:
            component: 'ReadFile'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0]).to.eql
          data: 'somefile'
          tgt:
            process: 'Read'
            port: 'SOURCE'

  describe 'with three-statement FBP string', ->
    fbpData = """
    'somefile.txt' -> SOURCE Read(ReadFile) OUT -> IN Display(Output)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.processes).to.eql
          Read:
            component: 'ReadFile'
          Display:
            component: 'Output'
      it 'should contain an edge and an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 2
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with three-statement FBP string without instantiation', ->
    it 'should not fail', ->
      fbpData = """
      'db' -> KEY SetDb(Set)
      SplitDb(Split) OUT -> VALUE SetDb CONTEXT -> IN MergeContext(Merge)
      """
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData.connections).to.have.length 3

  describe 'with no spaces around arrows', ->
    it 'should not fail', ->
      fbpData = """
      a(A)->b(B) ->c(C)-> d(D)->e(E)
      """
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData.connections).to.have.length 4

  describe 'with anonymous nodes in an FBP string', ->
    fbpData = """
    (A) OUT -> IN (B) OUT -> IN (B)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain three nodes with unique names', ->
        chai.expect(graphData.processes).to.eql
          _A_1:
            component: 'A'
          _B_1:
            component: 'B'
          _B_2:
            component: 'B'
      it 'should contain two edges', ->
        chai.expect(graphData.connections).to.eql [
          { src: { process: '_A_1', port: 'OUT' }, tgt: { process: '_B_1', port: 'IN' } }
          { src: { process: '_B_1', port: 'OUT' }, tgt: { process: '_B_2', port: 'IN' } }
        ]
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with default inport', ->
    fbpData = """
    (A) OUT -> (B)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should default port name to "IN"', ->
        chai.expect(graphData.connections).to.eql [
          { src: { process: '_A_1', port: 'OUT' }, tgt: { process: '_B_1', port: 'IN' } }
        ]
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with default outport', ->
    fbpData = """
    (A) -> IN (B)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should default port name to "OUT"', ->
        chai.expect(graphData.connections).to.eql [
          { src: { process: '_A_1', port: 'OUT' }, tgt: { process: '_B_1', port: 'IN' } }
        ]
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with default ports', ->
    fbpData = """
    (A) -> (B) -> (C)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should correctly use default ports', ->
        chai.expect(graphData.connections).to.eql [
          { src: { process: '_A_1', port: 'OUT' }, tgt: { process: '_B_1', port: 'IN' } }
          { src: { process: '_B_1', port: 'OUT' }, tgt: { process: '_C_1', port: 'IN' } }
        ]
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with a more complex FBP string', ->
    fbpData = """
    '8003' -> LISTEN WebServer(HTTP/Server) REQUEST -> IN Profiler(HTTP/Profiler) OUT -> IN Authentication(HTTP/BasicAuth)
    Authentication() OUT -> IN GreetUser(HelloController) OUT[0] -> IN[0] WriteResponse(HTTP/WriteResponse) OUT -> IN Send(HTTP/SendResponse)
    'hello.jade' -> SOURCE ReadTemplate(ReadFile) OUT -> TEMPLATE Render(Template)
    GreetUser() DATA -> OPTIONS Render() OUT -> STRING WriteResponse()
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain eight nodes', ->
        chai.expect(graphData.processes).to.be.an 'object'
        chai.expect(graphData.processes).to.have.keys [
          'WebServer'
          'Profiler'
          'Authentication'
          'GreetUser'
          'WriteResponse'
          'Send'
          'ReadTemplate'
          'Render'
        ]
      it 'should contain ten edges and IIPs', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 10
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'

  describe 'with multiple arrayport connections on same line', ->
    fbpData = """
    'test 1' -> IN[0] Mux(mux) OUT[0] -> IN Display(console)
    'test 2' -> IN[1] Mux OUT[1] -> IN Display
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive: true
      chai.expect(graphData).to.be.an 'object'
      chai.expect(graphData.processes).to.be.an 'object'
      chai.expect(graphData.connections).to.be.an 'array'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.processes).to.have.keys [
          'Mux'
          'Display'
        ]
      it 'should contain two IIPs', ->
        iips = graphData.connections.filter (conn) -> conn.data
        chai.expect(iips.length).to.equal 2
        chai.expect(iips[0].data).to.eql 'test 1'
        chai.expect(iips[0].tgt).to.eql
          process: 'Mux'
          port: 'IN'
          index: 0
        chai.expect(iips[1].data).to.eql 'test 2'
        chai.expect(iips[1].tgt).to.eql
          process: 'Mux'
          port: 'IN'
          index: 1
      it 'should contain two regular connections', ->
        connections = graphData.connections.filter (conn) -> conn.src
        chai.expect(connections.length).to.equal 2
        chai.expect(connections[0].src).to.eql
          process: 'Mux'
          port: 'OUT'
          index: 0
        chai.expect(connections[0].tgt).to.eql
          process: 'Display'
          port: 'IN'
        chai.expect(connections[1].src).to.eql
          process: 'Mux'
          port: 'OUT'
          index: 1
        chai.expect(connections[1].tgt).to.eql
          process: 'Display'
          port: 'IN'
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'

  describe 'with FBP string containing an IIP with whitespace', ->
    fbpData = """
    'foo Bar BAZ' -> IN Display(Output)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain a node', ->
        chai.expect(graphData.processes).to.eql
          Display:
            component: 'Output'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0].data).to.equal 'foo Bar BAZ'
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with FBP string containing an empty IIP string', ->
    fbpData = """
    '' -> IN Display(Output)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain a node', ->
        chai.expect(graphData.processes).to.eql
          Display:
            component: 'Output'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0].data).to.equal ''
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with FBP string containing a JSON IIP string', ->
    fbpData = """
    { "string": "s", "number": 123, "array": [1,2,3], "object": {}} -> IN Display(Output)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain a node', ->
        chai.expect(graphData.processes).to.eql
          Display:
            component: 'Output'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0].data).to.deep.equal { "string": "s", "number": 123, "array": [1,2,3], "object": {}}
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with FBP string containing comments', ->
    fbpData = """
    # Do stuff
    'foo bar' -> IN Display(Output) # Here we show the string
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain a node', ->
        chai.expect(graphData.processes).to.eql
          Display:
            component: 'Output'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0].data).to.equal 'foo bar'
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with FBP string containing URL as IIP', ->
    fbpData = """
    'http://localhost:5984/default' -> URL Conn(couchdb/OpenDatabase)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain a node', ->
        chai.expect(graphData.processes).to.eql
          Conn:
            component: 'couchdb/OpenDatabase'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0].data).to.equal 'http://localhost:5984/default'
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with FBP string containing RegExp as IIP', ->
    fbpData = """
    '_id=(\d+\.\d+\.\d*)=http://iks-project.eu/%deliverable/$1' -> REGEXP MapDeliverableUri(MapPropertyValue)
    'path=/_(?!(includes|layouts)' -> REGEXP MapDeliverableUri(MapPropertyValue)
    '@type=deliverable' -> PROPERTY SetDeliverableProps(SetProperty)
    '#foo' -> SELECTOR Get(dom/GetElement)
    'Hi, {{ name }}' -> TEMPLATE Get
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.processes).to.eql
          MapDeliverableUri:
            component: 'MapPropertyValue'
          SetDeliverableProps:
            component: 'SetProperty'
          Get:
            component: 'dom/GetElement'
      it 'should contain IIPs', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 5
        chai.expect(graphData.connections[0].data).to.be.a 'string'
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
        chai.expect(graphData.inports).to.eql {}
        chai.expect(graphData.outports).to.eql {}

  describe 'with FBP string with inports and outports', ->
    fbpData = """
    INPORT=Read.IN:FILENAME
    INPORT=Display.OPTIONS:OPTIONS
    OUTPORT=Display.OUT:OUT
    Read(ReadFile) OUT -> IN Display(Output)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.processes).to.eql
          Read:
            component: 'ReadFile'
          Display:
            component: 'Output'
      it 'should contain no legacy exports', ->
        chai.expect(graphData.exports).to.be.an 'undefined'
      it 'should contain a single connection', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0]).to.eql
          src:
            process: 'Read'
            port: 'OUT'
          tgt:
            process: 'Display'
            port: 'IN'
      it 'should contain two inports', ->
        chai.expect(graphData.inports).to.be.an 'object'
        chai.expect(graphData.inports.FILENAME).to.eql
          process: 'Read'
          port: 'IN'
        chai.expect(graphData.inports.OPTIONS).to.eql
          process: 'Display'
          port: 'OPTIONS'
      it 'should contain an outport', ->
        chai.expect(graphData.outports).to.be.an 'object'
        chai.expect(graphData.outports.OUT).to.eql
          process: 'Display'
          port: 'OUT'

  describe 'with FBP string with legacy EXPORTs', ->
    fbpData = """
    EXPORT=Read.IN:FILENAME
    Read(ReadFile) OUT -> IN Display(Output)
    """
    graphData = null
    it 'should fail', ->
      chai.expect(->
        graphData = parser.parse fbpData, caseSensitive:true
      ).to.throw Error

  describe 'with FBP string containing node metadata', ->
    fbpData = """
    Read(ReadFile) OUT -> IN Display(Output:foo=bar)

    # And we drop the rest
    Display OUT -> IN Drop(Drop:foo=baz,baz=/foo/bar)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    it 'should contain nodes with named routes', ->
      chai.expect(graphData.processes).to.eql
        Read:
          component: 'ReadFile'
        Display:
          component: 'Output'
          metadata:
            foo: 'bar'
        Drop:
          component: 'Drop'
          metadata:
            foo: 'baz'
            baz: '/foo/bar'
    it 'should contain two edges', ->
      chai.expect(graphData.connections).to.be.an 'array'
      chai.expect(graphData.connections.length).to.equal 2
    it 'should contain no exports', ->
      chai.expect(graphData.exports).to.be.an 'undefined'
      chai.expect(graphData.inports).to.eql {}
      chai.expect(graphData.outports).to.eql {}

  describe 'with FBP string containing node x/y metadata', ->
    fbpData = """
    Read(ReadFile) OUT -> IN Display(Output:foo=bar,x=17,y=42)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    it 'should contain nodes with numerical x/y metadata', ->
      chai.expect(graphData.processes).to.eql
        Read:
          component: 'ReadFile'
        Display:
          component: 'Output'
          metadata:
            foo: 'bar'
            x: 17
            y: 42

  describe 'with an invalid FBP string', ->
    fbpData = """
    'foo' --> Display(Output)
    """
    it 'should fail with an Exception', ->
      chai.expect(-> parser.parse fbpData, caseSensitive:true).to.throw Error

  describe 'with a component that contains dashes in name', ->
    fbpData = "'somefile' -> SOURCE Read(my-cool-component/ReadFile)"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain one node', ->
        chai.expect(graphData.processes).to.eql
          Read:
            component: 'my-cool-component/ReadFile'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1

  describe 'with commas to separate statements', ->
    fbpData = "'Hello' -> IN Foo(Component), 'World' -> IN Bar(OtherComponent), Foo OUT -> DATA Bar"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.processes).to.eql
          Foo:
            component: 'Component'
          Bar:
            component: 'OtherComponent'
      it 'should contain two IIPs and one edge', ->
        chai.expect(graphData.connections).to.eql [
            data: 'Hello'
            tgt:
              process: 'Foo'
              port: 'IN'
          ,
            data: 'World'
            tgt:
              process: 'Bar'
              port: 'IN'
          ,
            src:
              process: 'Foo'
              port: 'OUT'
            tgt:
              process: 'Bar'
              port: 'DATA'

        ]

  describe 'with underscores and numbers in ports, nodes, and components', ->
    fbpData = "'Hello 09' -> IN_2 Foo_Node_42(Component_15)"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain one node', ->
        chai.expect(graphData.processes).to.eql
          Foo_Node_42:
            component: 'Component_15'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0]).to.eql
          data: 'Hello 09'
          tgt:
            process: 'Foo_Node_42'
            port: 'IN_2'

  describe 'with dashes and numbers in nodes, and components', ->
    fbpData = "'Hello 09' -> IN_2 Foo-Node-42(Component-15)"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain one node', ->
        chai.expect(graphData.processes).to.eql
          'Foo-Node-42':
            component: 'Component-15'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0]).to.eql
          data: 'Hello 09'
          tgt:
            process: 'Foo-Node-42'
            port: 'IN_2'

  describe 'with FBP string containing port indexes', ->
    fbpData = """
    Read(ReadFile) OUT[1] -> IN Display(Output:foo=bar)

    # And we drop the rest
    Display OUT -> IN[0] Drop(Drop:foo=baz,baz=/foo/bar)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    it 'should contain nodes with named routes', ->
      chai.expect(graphData.processes).to.eql
        Read:
          component: 'ReadFile'
        Display:
          component: 'Output'
          metadata:
            foo: 'bar'
        Drop:
          component: 'Drop'
          metadata:
            foo: 'baz'
            baz: '/foo/bar'
    it 'should contain two edges', ->
      chai.expect(graphData.connections).to.be.an 'array'
      chai.expect(graphData.connections).to.eql [
        src:
          process: 'Read'
          port: 'OUT'
          index: 1
        tgt:
          process: 'Display'
          port: 'IN'
      ,
        src:
          process: 'Display'
          port: 'OUT'
        tgt:
          process: 'Drop'
          port: 'IN'
          index: 0
      ]
    it 'should contain no exports', ->
      chai.expect(graphData.exports).to.be.an 'undefined'
      chai.expect(graphData.inports).to.eql {}
      chai.expect(graphData.outports).to.eql {}

  describe 'with case-sensitive FBP string', ->
    fbpData = "'Hello' -> in Foo(Component), 'World' -> inPut Bar(OtherComponent), Foo outPut -> data Bar"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.processes).to.eql
          Foo:
            component: 'Component'
          Bar:
            component: 'OtherComponent'
      it 'should contain two IIPs and one edge', ->
        chai.expect(graphData.connections).to.eql [
            data: 'Hello'
            tgt:
              process: 'Foo'
              port: 'in'
          ,
            data: 'World'
            tgt:
              process: 'Bar'
              port: 'inPut'
          ,
            src:
              process: 'Foo'
              port: 'outPut'
            tgt:
              process: 'Bar'
              port: 'data'

        ]

  describe 'should convert port names to lowercase by default', ->
    fbpData = """
    INPORT=Read.IN:FILENAME
    INPORT=Display.OPTIONS:OPTIONS
    OUTPORT=Display.OUT:OUT
    Read(ReadFile) OUT -> IN Display(Output)

    ReadIndexed(ReadFile) OUT[1] -> IN DisplayIndexed(Output:foo=bar)
    DisplayIndexed OUT -> IN[0] Drop(Drop:foo=baz,baz=/foo/bar)
    """
    graphData = null

    beforeEach ->
      graphData = parser.parse fbpData

    it 'should produce a graph JSON object', ->
      chai.expect(graphData).to.be.an 'object'
      chai.expect(graphData.caseSensitive).to.equal false

    it 'should contain connections', ->
      chai.expect(graphData.connections).to.be.an 'array'
      chai.expect(graphData.connections.length).to.equal 3
      chai.expect(graphData.connections).to.eql [
        src:
          process: 'Read'
          port: 'out'
        tgt:
          process: 'Display'
          port: 'in'
      ,
        src:
          process: 'ReadIndexed'
          port: 'out'
          index: 1
        tgt:
          process: 'DisplayIndexed'
          port: 'in'
      ,
        src:
          process: 'DisplayIndexed'
          port: 'out'
        tgt:
          process: 'Drop'
          port: 'in'
          index: 0
      ]

    it 'should contain two inports', ->
      chai.expect(graphData.inports).to.be.an 'object'
      chai.expect(graphData.inports.filename).to.eql
        process: 'Read'
        port: 'in'
      chai.expect(graphData.inports.options).to.eql
        process: 'Display'
        port: 'options'

    it 'should contain an outport', ->
      chai.expect(graphData.outports).to.be.an 'object'
      chai.expect(graphData.outports.out).to.eql
        process: 'Display'
        port: 'out'

  describe 'with FBP string with source node that doesn\'t have a component defined', ->
    fbpData = """
    instanceMissingComponentName OUT -> (core/Output)
    """
    graphData = null
    it 'should fail', ->
      chai.expect(->
        graphData = parser.parse fbpData, caseSensitive:true
      ).to.throw Error, 'Edge to "_core_Output_1" port "IN" is connected to an undefined source node "instanceMissingComponentName"'
  describe 'with FBP string with IIP sent to node that doesn\'t have a component defined', ->
    fbpData = """
    'localhost' -> IN instanceMissingComponentName
    """
    graphData = null
    it 'should fail', ->
      chai.expect(->
        graphData = parser.parse fbpData, caseSensitive:true
      ).to.throw Error, 'IIP containing "localhost" is connected to an undefined target node "instanceMissingComponentName"'
  describe 'with FBP string with target node that doesn\'t have a component defined', ->
    fbpData = """
    a(A)->b(B) ->c(C)-> d(D)->e
    """
    graphData = null
    it 'should fail', ->
      chai.expect(->
        graphData = parser.parse fbpData, caseSensitive:true
      ).to.throw Error, 'Edge from "d" port "OUT" is connected to an undefined target node "e"'
  describe 'with FBP string with exported inport pointing to non-existing node', ->
    fbpData = """
    INPORT=noexist.IN:broken
    INPORT=exist.IN:works
    exist(foo/Bar)
    """
    graphData = null
    it 'should fail', ->
      chai.expect(->
        graphData = parser.parse fbpData, caseSensitive:true
      ).to.throw Error, 'Inport "broken" is connected to an undefined target node "noexist"'
  describe 'with FBP string with exported outport pointing to non-existing node', ->
    fbpData = """
    INPORT=exist.IN:works
    OUTPORT=noexist.OUT:broken
    exist(foo/Bar)
    """
    graphData = null
    it 'should fail', ->
      chai.expect(->
        graphData = parser.parse fbpData, caseSensitive:true
      ).to.throw Error, 'Outport "broken" is connected to an undefined source node "noexist"'
  describe 'with FBP string containing a runtime annotation', ->
    fbpData = """
    # @runtime foo
    'somefile' -> SOURCE Read(ReadFile)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
      chai.expect(graphData.caseSensitive).to.equal true
    it 'should contain the runtime type property', ->
      chai.expect(graphData.properties.environment.type).to.equal 'foo'
  describe 'with FBP string containing a name annotation', ->
    fbpData = """
    # @name ReadSomefile
    'somefile' -> SOURCE Read(ReadFile)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
      chai.expect(graphData.caseSensitive).to.equal true
    it 'should contain the name', ->
      chai.expect(graphData.properties.name).to.equal 'ReadSomefile'
  describe 'with FBP string containing two annotations', ->
    fbpData = """
    # @runtime foo
    # @name ReadSomefile
    'somefile' -> SOURCE Read(ReadFile)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'
      chai.expect(graphData.caseSensitive).to.equal true
    it 'should contain the runtime type property', ->
      chai.expect(graphData.properties.environment.type).to.equal 'foo'
    it 'should contain the name', ->
      chai.expect(graphData.properties.name).to.equal 'ReadSomefile'
