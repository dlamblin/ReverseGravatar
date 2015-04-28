#!/usr/bin/jjs
var System  = Java.type("java.lang.System");
 
/*
for each (e in System.env.entrySet()) {
    print(e.key, "=", e.value)
}
*/

var props = System.properties;
if (arguments.length == 0) {
    props.list(java.lang.System.out);
} else {
    arguments.forEach(function (val, i, ar) {
        if ("-l" == val) {
            for each (p in props.entrySet()) {
                print(p.key, "=", p.value)
            }
        } else {
            print(val, "=", props.getProperty(val, "«UNDEFINED–PROPERTY»"));
        }
    });
}
