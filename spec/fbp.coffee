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
