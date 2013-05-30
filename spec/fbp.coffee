chai = require 'chai' unless chai
parser = require '../lib/fbp'

describe 'FBP parser', ->
  describe 'with simple FBP string', ->
    fbpData = "'somefile.txt' -> SOURCE Read(ReadFile) OUT -> IN Display(Output)"
    graphData = null
    it 'should produce a graph JSON object', ->
      graphData = parser.parse fbpData
      chai.expect(graphData).to.be.an 'object'
    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData.nodes).to.be.an 'array'
        chai.expect(graphData.nodes.length).to.equal 2
      it 'should contain an edge', ->
        chai.expect(graphData.edges).to.be.an 'array'
        chai.expect(graphData.edges.length).to.equal 1
      it 'should contain an IIP', ->
        chai.expect(graphData.initializers).to.be.an 'array'
        chai.expect(graphData.initializers.length).to.equal 1
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
        chai.expect(graphData.nodes).to.be.an 'array'
        chai.expect(graphData.nodes.length).to.equal 8
      it 'should contain eight edges', ->
        chai.expect(graphData.edges).to.be.an 'array'
        chai.expect(graphData.edges.length).to.equal 8
      it 'should contain two IIPs', ->
        chai.expect(graphData.initializers).to.be.an 'array'
        chai.expect(graphData.initializers.length).to.equal 2
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
        chai.expect(graphData.nodes).to.be.an 'array'
        chai.expect(graphData.nodes.length).to.equal 1
      it 'should contain no edges', ->
        chai.expect(graphData.edges).to.be.an 'array'
        chai.expect(graphData.edges.length).to.equal 0
      it 'should contain an IIP', ->
        chai.expect(graphData.initializers).to.be.an 'array'
        chai.expect(graphData.initializers.length).to.equal 1
        chai.expect(dataphData.initializers[0].data).to.equal 'foo Bar BAZ'
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
        chai.expect(graphData.nodes).to.be.an 'array'
        chai.expect(graphData.nodes.length).to.equal 1
      it 'should contain no edges', ->
        chai.expect(graphData.edges).to.be.an 'array'
        chai.expect(graphData.edges.length).to.equal 0
      it 'should contain an IIP', ->
        chai.expect(graphData.initializers).to.be.an 'array'
        chai.expect(graphData.initializers.length).to.equal 1
        chai.expect(dataphData.initializers[0].data).to.equal ''
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
        chai.expect(graphData.nodes).to.eql
          Display:
            component: 'Output'
      it 'should contain no edges', ->
        chai.expect(graphData.edges).to.be.an 'array'
        chai.expect(graphData.edges.length).to.equal 0
      it 'should contain an IIP', ->
        chai.expect(graphData.initializers).to.be.an 'array'
        chai.expect(graphData.initializers.length).to.equal 1
        chai.expect(dataphData.initializers[0].data).to.equal 'foo bar'
      it 'should contain no exports', ->
        chai.expect(graphData.exports).to.be.an 'array'
        chai.expect(graphData.exports.length).to.equal 0

  describe 'with an invalid FBP string', ->
    fbpData = """
    'foo' -> Display(Output)
    """
    it 'should fail with an Exception', ->
      chai.expect(-> parser.parse fbpData).to.throw Error


