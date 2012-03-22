# SCKit

SCKit is a collection of utility classes for [Cappuccino](https://github.com/cappuccino/cappuccino).

#### SCString
An awesome string template engine. Handles both simple and extremely complex string formatting needs.

#### SCURLConnection
A drop-in replacement for CPURLConnection that is much easier to use.

#### SCJSONPConnection
A drop-in replacement for CPJSONPConnection that is much easier to use.

#### SCConnectionUtils
A set of utilities for dealing with connection errors. Used by SCURLConnection and SCJSONPConnection.

#### SCStyledTextField
A drop-in replacement for CPTextField that allows you to format the output with html tags in the value.

#### SCBorderView
To be documented.

## Examples
To see SCString and SCURLConnection in action, do the following:

1. From the main directory, run `jake all`. This will build SCKit and make it available to applications.
1. Install LPKit on your system. You might try [this version](https://github.com/aljungberg/LPKit.git).
1. In a terminal, cd into the Tests directory.
1. Execute `capp gen -lf -F SCKit -F LPKit .` in a terminal.
1. Make the Tests directory accessible via a web server that supports PHP, and load index-debug.html.
