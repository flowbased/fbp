chai = require 'chai' unless chai
parser = require '../lib/fbp'

describe 'FBP parser', ->
  it 'should provide a parse method', ->
    chai.expect(parser.parse).to.be.a 'function'
  describe 'with simple FBP string', ->
    fbpData = "'somefile' -> SOURCE Read(ReadFile)"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain one node', ->
        chai.expect(graphData.processes).to.eql
          Read:
            component: 'ReadFile'
      it 'should contain an IIP', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1

  describe 'with three-statement FBP string', ->
    fbpData = "'somefile.txt' -> SOURCE Read(ReadFile) OUT -> IN Display(Output)"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
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
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 0

  describe 'with a more complex FBP string', ->
    fbpData = """
    '8003' -> LISTEN WebServer(HTTP/Server) REQUEST -> IN Profiler(HTTP/Profiler) OUT -> IN Authentication(HTTP/BasicAuth)
    Authentication() OUT -> IN GreetUser(HelloController) OUT -> IN WriteResponse(HTTP/WriteResponse) OUT -> IN Send(HTTP/SendResponse)
    'hello.jade' -> SOURCE ReadTemplate(ReadFile) OUT -> TEMPLATE Render(Template)
    GreetUser() DATA -> OPTIONS Render() OUT -> STRING WriteResponse()
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
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
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 0

  describe 'with FBP string containing an IIP with whitespace', ->
    fbpData = """
    'foo Bar BAZ' -> IN Display(Output)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
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
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 0

  describe 'with FBP string containing an empty IIP string', ->
    fbpData = """
    '' -> IN Display(Output)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
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
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 0

  describe 'with FBP string containing comments', ->
    fbpData = """
    # Do stuff
    'foo bar' -> IN Display(Output) # Here we show the string
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
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
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 0

  describe 'with FBP string containing URL as IIP', ->
    fbpData = """
    'http://localhost:5984/default' -> URL Conn(couchdb/OpenDatabase)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
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
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 0

  describe 'with FBP string containing RegExp as IIP', ->
    fbpData = """
    '_id=(\d+\.\d+\.\d*)=http://iks-project.eu/deliverable/$1' -> REGEXP MapDeliverableUri(MapPropertyValue)
    '@type=deliverable' -> PROPERTY SetDeliverableProps(SetProperty)
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.processes).to.eql
          MapDeliverableUri:
            component: 'MapPropertyValue'
          SetDeliverableProps:
            component: 'SetProperty'
      it 'should contain two IIPs', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 2
        chai.expect(graphData.connections[0].data).to.be.a 'string'
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 0

  describe 'with FBP string with EXPORTs', ->
    fbpData = """
    EXPORT=READ.IN:FILENAME
    Read(ReadFile) OUT -> IN Display(Output) 
    """
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.processes).to.eql
          Read:
            component: 'ReadFile'
          Display:
            component: 'Output'
      it 'should contain a single connection', ->
        chai.expect(graphData.connections).to.be.an 'array'
        chai.expect(graphData.connections.length).to.equal 1
        chai.expect(graphData.connections[0]).to.eql
          src:
            process: 'Read'
            port: 'out'
          tgt:
            process: 'Display'
            port: 'in'
      it 'should contain an export', ->
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 1
        chai.expect(graphData.exports[0]).to.eql
          private: 'READ.IN'
          public: 'FILENAME'

  describe 'with an invalid FBP string', ->
    fbpData = """
    'foo' -> Display(Output)
    """
    it 'should fail with an Exception', ->
      chai.expect(-> parser.parse fbpData).to.throw Error
