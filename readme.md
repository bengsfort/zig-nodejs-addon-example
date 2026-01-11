# Zig Node.js Addon Example

This is a very basic example of writing a native addon for node.js with Zig, as a simplistic example of what the flow looks like and how it works. This currently uses the raw node.js API's, but could be improved by utilizing the node-addon-api package instead which as a much nicer-to-use API that is less verbose.

## Node-API

The Node-API is an API independent from the JS runtime that allows native addons to be written in other languages, while being isolated from the underlying node.js engine so that they can remain working across multiple versions without recompilation (ABI-stable). More info available [here](https://github.com/nodejs/abi-stable-node/blob/doc/node-api-engine-bindings.md). These addons are shipped as `.node` files which are renamed dynamically linked libraries that export a module registration function, which defines the modules `exports` object.

In Zig, in it's simplest form this looks like this:

```zig
const node = @cImport({
    @cInclude("node_api.h");
});

// Entrypoint that node.js calls to load the module
export fn napi_register_module_v1(env: node.napi_env, exports: node.napi_value) node.napi_value {
    var world_str: node.napi_value = undefined;                          // Create a var to hold the node value
    _ = node.napi_create_string_utf8(env, "world", 5, &world_str);       // Create a string at the variable address
    _ = node.napi_set_named_property(env, exports, "hello", world_str);  // Set the variable on the "hello" property of module exports

    return exports;
}
```

In a real world project this would look much more complex as each API call would return a status code which should be checked to ensure nothing went wrong, but in it's most basic form this is the foundation.

## Improvements to look at

If you are looking at using Zig for writing Node.js addons, in addition to this example I would recommend looking into the following.

- The baseline Node-API calls are very verbose, however one could likely translate the [node-addon-api](https://github.com/nodejs/node-addon-api) package which is far less verbose and provides a lot of niceties when it comes to working with native node interop.
- This current example is not compatible with worker/thread usage, which would require implementing a [context aware addon](https://nodejs.org/docs/latest/api/addons.html#context-aware-addons).
- Take a look at if [napigen](https://github.com/cztomsik/napigen) suits your usecase. It is a very well made library for the NAPI bindings that provides a lot of comfort and quality-of-life features.
- At build time the `build.zig` file should likely execute a command to find the current location of the node.js executable so that it can find the include directory automatically on all systems.
  - These are generally within the `$(which node.js) + "/includes/node"` folder

## Further reading

- [Node.js Addon Docs](https://nodejs.org/docs/latest/api/addons.html)
- [N-API Docs](https://nodejs.org/docs/latest/api/n-api.html)
- [node-addon-api Docs](https://github.com/nodejs/node-addon-api)
- [Node.js ABI Stability Docs](https://nodejs.org/en/learn/modules/abi-stability)
- [Zig C Interop Docs](https://ziglang.org/documentation/master/#C)
