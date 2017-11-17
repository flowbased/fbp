# fbp 1.7.0 - released 17.11.2017

* Added support for annotations like `# @runtime noflo-nodejs` or `# @name SomeComponent`
* Added basic validation for parsed graphs to find issues with misnamed or misconfigured components
* Fixed JSON-to-FBP serialization with case sensitive graphs

# fbp 1.6.0 - released 03.11.2017

* Removed support for deprecated `EXPORT` keyword

# fbp 1.5.0 - released 06.07.2016

* Add API for serializating back to FBP DSL: `fbp.serialize(graph)`
* Let `fbp somegraph.json` serialize back to FBP DSL

# fbp 1.4.0 - released 17.06.2016

* Allow JSON as IIPs, `{ "foo": { "bar": { "baz": 1234 }}} -> IN Display(Output)`
* Allow anonymous nodes `'foo' -> IN (Output) OUT -> myfoo(Component)`
* Allow declaring components without making a connection `Display(Output)`
* Allow not specifying ports. Will default to `IN` and `OUT` respectively. `(A) -> (B)` and `(A) OUT -> (B)`

# fbp 1.3.0 - released 24.05.2016

* Include JSON schema definition for graph output
* Support enforcing the schema in parser via `validateSchema` option. Requires optional dependency `tv4`.

# fbp 1.2.0 - released 23.05.2016

* Support case-preserving in ports. Opt-in, via `caseSensitive` option.

# fbp 1.1.4 - released 05.10.2015

* Support for dashes `-` in node names

# fbp 1.1.2 - released 25.04.2014

* Support for array port index `[0]` in connections

# fbp 1.1.0 - released 19.02.2014

* Support for `INPORT` and `OUTPORT`, for exporting ports.

# fbp 1.0.0 - released 30.05.2013

* Initial release
