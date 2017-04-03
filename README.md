# purescript-phantom

Purescript bindings to PhantomJS

![PhantomJS logo](https://raw.githubusercontent.com/Risto-Stevcev/purescript-phantom/master/logo.png)

[![Build Status](https://travis-ci.org/dgendill/purescript-phantom.svg?branch=master)](https://travis-ci.org/dgendill/purescript-phantom)

* [Motive](#motive)
* [QuickStart](#quickstart)
* [Compatibility](#compatibility)
* [Tests](#tests)
* [Examples](#examples)

## Motive

Purescript code is pure and total, so most testing is usually a form of documentation or done with generative tests. However,
occasionally tests need to test FFI bindings, which is where PhantomJS comes in handy. If you need to test some code that deals
with `Window`, or the DOM, or some web APIs, these bindings come in handy. It can be used as a simpler replacement to the karma
test-runner framework.

## QuickStart

```purescript
import Prelude ((>>=), bind)
import Data.Enum (fromEnum)
import ExitCodes (ExitCode(Success))
import PhantomJS.Phantom (version, exit)
import Control.Monad.Eff.Console (logShow)

main = do
  version >>= logShow
  exit (fromEnum Success)
```

## Compatibility

| Purescript | purescript-phantom | phantomjs
|------------|------------------------|
| v0.11.0 | v2.x.x | 2.1.x |
| v0.10.1 - v0.10.7    | v1.x.x | 2.1.x |

## Tests

Assuming you have purescript and phantomjs installed, run the following in the project root...

`PHANTOM_TEST_PATH=$(pwd) pulp test --runtime phantomjs`

Or if you're using [phantomjs-prebuilt](https://www.npmjs.com/package/phantomjs-prebuilt)...

`PHANTOM_TEST_PATH=$(pwd) pulp test --runtime ./node_modules/.bin/phantomjs`

You can also run the tests, in the [purescript-docker image](https://github.com/Risto-Stevcev/purescript-docker).
If you're using docker, follow the instructions in the comments of `test.sh` to get a working container.  You can then run the
tests inside of the container by running `./test.sh` on the host, which will run `pulp --watch test` inside the container.

## Examples

If you do not have phantomjs installed, you can install `phantomjs-prebuilt` from npm, and it will be installed in
`./node_modules/.bin/phantomjs`. You can then run pulp with the `--runtime ./node_modules/.bin/phantomjs` and the compiled
code will be run by phantomjs.

The `examples` folder contains two examples.  First compile by running:

```
pulp build --include examples --main Example --to examples-output/example.js
# or
pulp build --include examples --main Example.Stream --to examples-output/stream.js
```

You can then run the examples in the examples-output folder:

```
cd examples-output
../node_modules/.bin/phantomjs example.js
../node_modules/.bin/phantomjs stream.js
```
