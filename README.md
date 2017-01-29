# purescript-phantom

Purescript bindings to PhantomJS

![PhantomJS logo](https://raw.githubusercontent.com/Risto-Stevcev/purescript-phantom/master/logo.png)


## Motive

Purescript code is pure and total, so most testing is usually a form of documentation or done with generative tests. However, occasionally tests need to test FFI bindings, which is where PhantomJS comes in handy. If you need to test some code that deals with `Window`, or the DOM, or some web APIs, these bindings come in handy. It can be used as a simpler replacement to the karma test-runner framework.

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


## Tests

To run the tests, you'll need the [purescript-docker image](https://github.com/Risto-Stevcev/purescript-docker), tagged as "purescript-docker:0.10.5".  To build the image,
you can run the following...

```bash
  git clone github.com/gyeh/purescript-docker
  cd purescript-docker
  git checkout 0.10.5
  docker build --tag purescript-docker:0.10.5 .
```

You can then run the tests inside of a container by running the `./test.sh`.  This will create a container named `purescript-docker`
that uses the `purescript-docker:0.10.5` image, and run the tests with the --watch flag.


## Examples

If you do not have phantomjs installed, you can install `phantomjs-prebuilt` from npm, and it will be installed in `./node_modules/.bin/phantomjs`.
You can then run pulp with the `--runtime ./node_modules/.bin/phantomjs` and the compiled code will be run by phantomjs.

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
