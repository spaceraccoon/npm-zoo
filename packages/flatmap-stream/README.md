# flatmap-stream@0.1.1

* Added: 20 Jan 2019
* Updated: 20 Jan 2019
* Removed: 26 Nov 2018
* Category: Encrypted
* Source: https://github.com/hannob/pypi-bad
* Reference: https://www.npmjs.com/advisories/737

## Summary

The package contains encoded data hidden in `test/data.js`. This directory is not available in the GitHub repository but is available in the raw flatmap-stream-0.1.1.tgz package. The encoded data is stored as an array of parts. Each of these parts are minified/obfuscated and also encrypted to various degrees. Some of the encrypted data includes method names which could alert the malicious behavior to static analysis tools, such as the string _compile, which is a method on require for creating a new module. 

The payload targets a very specific application, copay and because they shared the same description it would have likely worked for copay-dash.