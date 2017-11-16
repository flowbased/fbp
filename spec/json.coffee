if typeof process isnt 'undefined' and process.execPath and process.execPath.indexOf('node') isnt -1
  chai = require 'chai' unless chai
  parser = require '../lib/fbp'
  parser.validateSchema = true # validate schema for every test on node.js. Don't have tv4 in the browser build
else
  parser = require 'fbp'

describe 'JSON to FBP parser', ->
  it 'should provide a parse method', ->
    chai.expect(parser.parse).to.be.a 'function'
    chai.expect(parser.serialize).to.be.a 'function'

  describe 'roundtrip', ->
    describe 'with simple FBP string', ->
      fbpData = """
      '8003' -> LISTEN WebServer(HTTP/Server) REQUEST -> IN Profiler(HTTP/Profiler) OUT -> IN Authentication(HTTP/BasicAuth)
      Authentication() OUT -> IN GreetUser(HelloController) OUT[0] -> IN[0] WriteResponse(HTTP/WriteResponse) OUT -> IN Send(HTTP/SendResponse)
      'hello.jade' -> SOURCE ReadTemplate(ReadFile) OUT -> TEMPLATE Render(Template)
      GreetUser() DATA -> OPTIONS Render() OUT -> STRING WriteResponse()
      """
      roundTrippedFbpData = ""
      graphString = ""
      graphData = null
      graphData2 = null

      it 'should produce a graph JSON object', ->
        # fbp -> json
        graphData = parser.parse fbpData, caseSensitive:true
        chai.expect(graphData).to.be.an 'object'
        chai.expect(graphData.caseSensitive).to.equal true

        # json -> fbp
        roundTrippedFbpData = parser.serialize graphData

        # fbp -> json
        graphData2 = parser.parse roundTrippedFbpData, caseSensitive:true

        # json -> fbp, to test
        fbp2 = parser.serialize graphData2

        chai.expect(roundTrippedFbpData).to.equal fbp2

      describe 'the generated graph', ->
        it 'should contain eight nodes', ->
          chai.expect(graphData2.processes).to.be.an 'object'
          chai.expect(graphData2.processes).to.have.keys [
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
          chai.expect(graphData2.connections).to.be.an 'array'
          chai.expect(graphData2.connections.length).to.equal 10
        it 'should contain no exports', ->
          chai.expect(graphData2.exports).to.be.an 'undefined'

  describe 'with flowhub json graph (from ingress c-base table)', ->
    jsonData = """
    {
        "properties": {
            "name": "ConfigPaths",
            "environment": {
                "type": "noflo-nodejs"
            },
            "description": "Read Ingress Table configuration files",
            "icon": "file"
        },
        "inports": {
            "envvar": {
                "process": "core/ReadEnv_2mde7",
                "port": "key",
                "metadata": {
                    "x": -612,
                    "y": 432,
                    "width": 72,
                    "height": 72
                }
            },
            "serverfile": {
                "process": "core/Repeat_ktvob",
                "port": "in",
                "metadata": {
                    "x": -612,
                    "y": 324,
                    "width": 72,
                    "height": 72
                }
            },
            "portalfile": {
                "process": "core/Repeat_r65df",
                "port": "in",
                "metadata": {
                    "x": -612,
                    "y": 540,
                    "width": 72,
                    "height": 72
                }
            }
        },
        "outports": {
            "error": {
                "process": "core/ReadEnv_2mde7",
                "port": "error",
                "metadata": {
                    "x": -324,
                    "y": 684,
                    "width": 72,
                    "height": 72
                }
            },
            "serverfile": {
                "process": "strings/CompileString_pjcg2",
                "port": "out",
                "metadata": {
                    "x": 0,
                    "y": 432,
                    "width": 72,
                    "height": 72
                }
            },
            "portalfile": {
                "process": "strings/CompileString_667tt",
                "port": "out",
                "metadata": {
                    "x": 0,
                    "y": 540,
                    "width": 72,
                    "height": 72
                }
            }
        },
        "groups": [],
        "processes": {
            "core/ReadEnv_2mde7": {
                "component": "core/ReadEnv",
                "metadata": {
                    "label": "core/ReadEnv",
                    "x": -468,
                    "y": 432,
                    "width": 72,
                    "height": 72
                }
            },
            "core/Repeat_ktvob": {
                "component": "core/Repeat",
                "metadata": {
                    "label": "core/Repeat",
                    "x": -324,
                    "y": 324,
                    "width": 72,
                    "height": 72
                }
            },
            "packets/DoNotDisconnect_uev3m": {
                "component": "packets/DoNotDisconnect",
                "metadata": {
                    "label": "packets/DoNotDisconnect",
                    "x": -324,
                    "y": 432,
                    "width": 72,
                    "height": 72
                }
            },
            "strings/CompileString_pjcg2": {
                "component": "strings/CompileString",
                "metadata": {
                    "label": "strings/CompileString",
                    "x": -144,
                    "y": 432,
                    "width": 72,
                    "height": 72
                }
            },
            "strings/CompileString_667tt": {
                "component": "strings/CompileString",
                "metadata": {
                    "label": "strings/CompileString",
                    "x": -144,
                    "y": 540,
                    "width": 72,
                    "height": 72
                }
            },
            "core/Repeat_r65df": {
                "component": "core/Repeat",
                "metadata": {
                    "label": "core/Repeat",
                    "x": -324,
                    "y": 540,
                    "width": 72,
                    "height": 72
                }
            }
        },
        "connections": [
            {
                "src": {
                    "process": "core/Repeat_r65df",
                    "port": "out"
                },
                "tgt": {
                    "process": "strings/CompileString_667tt",
                    "port": "in"
                }
            },
            {
                "src": {
                    "process": "core/Repeat_ktvob",
                    "port": "out"
                },
                "tgt": {
                    "process": "strings/CompileString_pjcg2",
                    "port": "in"
                }
            },
            {
                "src": {
                    "process": "core/ReadEnv_2mde7",
                    "port": "out"
                },
                "tgt": {
                    "process": "packets/DoNotDisconnect_uev3m",
                    "port": "in"
                },
                "metadata": {
                    "route": null
                }
            },
            {
                "src": {
                    "process": "packets/DoNotDisconnect_uev3m",
                    "port": "out"
                },
                "tgt": {
                    "process": "strings/CompileString_pjcg2",
                    "port": "in"
                }
            },
            {
                "src": {
                    "process": "packets/DoNotDisconnect_uev3m",
                    "port": "out"
                },
                "tgt": {
                    "process": "strings/CompileString_667tt",
                    "port": "in"
                }
            },
            {
                "data": "/",
                "tgt": {
                    "process": "strings/CompileString_pjcg2",
                    "port": "delimiter"
                }
            },
            {
                "data": "/",
                "tgt": {
                    "process": "strings/CompileString_667tt",
                    "port": "delimiter"
                }
            }
        ]
    }
    """
    roundTrippedFbpData = ""
    graphString = ""
    graphData = null
    graphData2 = null

    it 'should produce a graph JSON object', ->
      fbpData = parser.serialize jsonData
      jsonFromFbp = parser.parse fbpData, caseSensitive:true
    it 'should have retained properties', ->
      fbpData = parser.serialize jsonData
      jsonFromFbp = parser.parse fbpData, caseSensitive:true
      chai.expect(jsonFromFbp.properties).to.eql JSON.parse(jsonData).properties

  describe 'roundtrip with FBP string with inports and outports', ->
    fbpData = """
    INPORT=Read.IN:FILENAME
    INPORT=Display.OPTIONS:OPTIONS
    OUTPORT=Display.OUT:OUT
    Read(ReadFile) OUT -> IN Display(Output)
    """
    graphData = null
    graphData2 = null
    it 'should produce a graph JSON object', ->
      # $1 fbp -> json
      graphData = parser.parse fbpData, caseSensitive:true
      chai.expect(graphData).to.be.an 'object'

      # json -> fbp
      jsonGraph = parser.serialize graphData

      # fbp -> json
      graphData2 = parser.parse jsonGraph, caseSensitive:true

      # $2 json -> fbp
      fbpData2 = parser.serialize graphData2

      # remove the formatting
      fbpData = fbpData.replace /(\n)+/g, ""
      fbpData2 = fbpData2.replace /(\n)+/g, ""

      # make sure $1 and $2 match
      chai.expect(fbpData).to.equal fbpData2

    describe 'the generated graph', ->
      it 'should contain two nodes', ->
        chai.expect(graphData2.processes).to.eql
          Read:
            component: 'ReadFile'
          Display:
            component: 'Output'
      it 'should contain no legacy exports', ->
        chai.expect(graphData2.exports).to.be.an 'undefined'
      it 'should contain a single connection', ->
        chai.expect(graphData2.connections).to.be.an 'array'
        chai.expect(graphData2.connections.length).to.equal 1
        chai.expect(graphData2.connections[0]).to.eql
          src:
            process: 'Read'
            port: 'OUT'
          tgt:
            process: 'Display'
            port: 'IN'
      it 'should contain two inports', ->
        chai.expect(graphData2.inports).to.be.an 'object'
        chai.expect(graphData2.inports.FILENAME).to.eql
          process: 'Read'
          port: 'IN'
        chai.expect(graphData2.inports.OPTIONS).to.eql
          process: 'Display'
          port: 'OPTIONS'
      it 'should contain an outport', ->
        chai.expect(graphData2.outports).to.be.an 'object'
        chai.expect(graphData2.outports.OUT).to.eql
          process: 'Display'
          port: 'OUT'

  describe 'annotations', ->
    fbpData = """
# @runtime foo
# @name ReadSomefile

"somefile" -> SOURCE Read(ReadFile)

    """
    graphData =
      caseSensitive: false
      properties:
        name: 'ReadSomefile'
        environment:
          type: 'foo'
      inports: {}
      outports: {}
      groups: []
      processes:
        Read:
          component: 'ReadFile'
      connections: [
        data: 'somefile'
        tgt:
          process: 'Read'
          port: 'source'
      ]
    it 'should produce expected FBP string', ->
      serialized = parser.serialize graphData
      chai.expect(serialized).to.equal fbpData
    it 'should produce expected FBP graph', ->
      serialized = parser.parse fbpData
      chai.expect(serialized).to.eql graphData

  describe 'annotations in case sensitive graph', ->
    fbpData = """
# @runtime foo
# @name ReadSomefile
INPORT=Read.Encoding:FileEncoding
OUTPORT=Read.Out:Result

"somefile" -> SourceCode Read(ReadFile)
Read Errors -> TryAgain Read

    """
    graphData =
      caseSensitive: true
      properties:
        name: 'ReadSomefile'
        environment:
          type: 'foo'
      inports:
        FileEncoding:
          process: 'Read'
          port: 'Encoding'
      outports:
        Result:
          process: 'Read'
          port: 'Out'
      groups: []
      processes:
        Read:
          component: 'ReadFile'
      connections: [
        data: 'somefile'
        tgt:
          process: 'Read'
          port: 'SourceCode'
      ,
        src:
          process: 'Read'
          port: 'Errors'
        tgt:
          process: 'Read'
          port: 'TryAgain'
      ]
    it 'should produce expected FBP string', ->
      serialized = parser.serialize graphData
      chai.expect(serialized).to.equal fbpData
    it 'should produce expected FBP graph', ->
      serialized = parser.parse fbpData,
        caseSensitive: true
      chai.expect(serialized).to.eql graphData
