FBP flow definition language parser [![Build Status](https://travis-ci.org/flowbased/fbp.png?branch=master)](https://travis-ci.org/flowbased/fbp) [![Build status](https://ci.appveyor.com/api/projects/status/cye5ylmhfybnb8t9)](https://ci.appveyor.com/project/bergie/fbp) [![Greenkeeper badge](https://badges.greenkeeper.io/flowbased/fbp.svg)](https://greenkeeper.io/) [![Coverage Status](https://coveralls.io/repos/github/flowbased/fbp/badge.svg?branch=master)](https://coveralls.io/github/flowbased/fbp?branch=master)
===================================

The *fbp* library provides a parser for a domain-specific language for flow-based-programming (FBP),
used for defining graphs for FBP programming environments like
[NoFlo](https://noflojs.org), [MicroFlo](https://microflo.org) and [MsgFlo](http://msgflo.org).

## Usage

You can use the FBP parser in your JavaScript code with the following:

```javascript
var parser = require('fbp');

// Some FBP syntax code
var fbpData = "'hello, world!' -> IN Display(Output)";

// Parse into a Graph definition JSON object
var graphDefinition = parser.parse(fbpData, {caseSensitive: true});
```

When `caseSensitive` is `false` the parser will convert port names to lowercase. This is currently the default behavior, but in future releases the default will change to preserve case. It is therefore recommended that you always specify the `caseSensitive` option to make your code future-proof.


### Command-line

The *fbp* package also provides a command-line tool for converting FBP files into JSON:

```
$ fbp somefile.fbp [--case-sensitive] > somefile.json
```

And for converting JSON files into FBP:

```
$ fbp somefile.json [--case-sensitive] > somefile.fbp
```


## Language for Flow-Based Programming

FBP is a Domain-Specific Language (DSL) for easy graph definition. The syntax is the following:

* `'somedata' -> PORT Process(Component)` sends initial data _somedata_ to port _PORT_ of process _Process_ that runs component _Component_
* `A(Component1) X -> Y B(Component2)` sets up a connection between port _X_ of process _A_ that runs component _Component1_ and port _Y_ of process _B_ that runs component _Component2_

You can connect multiple components and ports together on one line, and separate connection definitions with a newline or a comma (`,`).

Components only have to be specified the first time you mention a new process. Afterwards, simply use the process name.

Example:

```fbp
'somefile.txt' -> SOURCE Read(ReadFile) OUT -> IN Split(SplitStr)
Split OUT -> IN Count(Counter) COUNT -> IN Display(Output)
Read ERROR -> IN Display
```

The syntax also supports blank lines and comments. Comments start with the `#` character.

Example with the same graph than above :

```fbp
# Read the content of "somefile.txt" and split it by line
'somefile.txt' -> SOURCE Read(ReadFile) OUT -> IN Split(SplitStr)

# Count the lines and display the result
Split() OUT -> IN Count(Counter) COUNT -> IN Display(Output)

# The read errors are also displayed
Read() ERROR -> IN Display()
```

### Exporting ports

When FBP-defined graphs are used as subgraphs in other flows, it is often desirable to give more user-friendly names to their available ports. In the FBP language this is done by `INPORT` and `OUTPORT` statements.

Example:

```fbp
INPORT=Read.IN:FILENAME
Read(ReadFile) OUT -> IN Display(Output)
```

This line would export the *IN* port of the *Read* node as *FILENAME*.

### Node metadata

It is possible to append metadata to Nodes when declaring them by adding the metadata string to the Component part after a colon (`:`).

Example:

```fbp
'somefile.txt' -> SOURCE Read(ReadFile:main)
Read() OUT -> IN Split(SplitStr:main)
Split() OUT -> IN Count(Counter:main)
Count() COUNT -> IN Display(Output:main)
Read() ERROR -> IN Display()
```

In this case the route leading from *Read* to *Display* through *Split* and *Count* would be identified with the string *main*. You can also provide arbitrary metadata keys with the `=` syntax:

```fbp
Read() OUT -> IN Split(SplitStr:foo=bar,baz=123)
```

In this case the *Split* node would contain the metadata keys `foo` and `baz` with values `bar` and `123`.

### Annotations

FBP graphs also support annotations for specifying things like graph name, description, icon, or the FBP runtime to be used for executing the graph.

The syntax for annotations is `# @name value`, for example:

```fbp
# @runtime noflo-nodejs
# @name ReadSomefile
'somefile' -> SOURCE Read(ReadFile)
```
