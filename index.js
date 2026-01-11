const addon = require('./zig-out/zig-addon.node');

console.log("zig addon:", addon);
console.log("zig add 5 + 10:", addon.add(5, 10));
