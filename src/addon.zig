const std = @import("std");
const node = @cImport({
    @cInclude("node_api.h");
});

pub fn add(a: f64, b: f64) f64 {
    return a + b;
}

fn node_add(env: node.napi_env, info: node.napi_callback_info) callconv(.c) node.napi_value {
    // Parse the arguments passed with the callback.
    var arg_count: usize = 2;
    var arg_values: [2]node.napi_value = undefined;
    _ = node.napi_get_cb_info(env, info, &arg_count, &arg_values, null, null);

    // Parse each arguments float value
    var a: f64 = undefined;
    var b: f64 = undefined;
    _ = node.napi_get_value_double(env, arg_values[0], &a);
    _ = node.napi_get_value_double(env, arg_values[1], &b);

    // Create a value for the result, then pass the arguments to the function.
    var result: node.napi_value = undefined;
    _ = node.napi_create_double(env, add(a, b), &result);

    return result;
}

// Entrypoint that node.js calls to load the module
export fn napi_register_module_v1(env: node.napi_env, exports: node.napi_value) node.napi_value {
    // Create a value for our exposed function and add it to the exports object.
    var add_fn: node.napi_value = undefined;
    _ = node.napi_create_function(env, "add", node.NAPI_AUTO_LENGTH, node_add, null, &add_fn);
    _ = node.napi_set_named_property(env, exports, "add", add_fn);

    // Create a value for the test 'bar' string and add it to the exports object.
    var bar_val: node.napi_value = undefined;
    _ = node.napi_create_string_utf8(env, "bar", 3, &bar_val);
    _ = node.napi_set_named_property(env, exports, "foo", bar_val);

    return exports;
}

test "basic add functionality" {
    try std.testing.expect(add(3, 7) == 10);
}
