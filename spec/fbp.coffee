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
