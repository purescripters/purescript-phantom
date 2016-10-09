# purescript-phantom

Purescript bindings to PhantomJS

![PhantomJS logo](https://raw.githubusercontent.com/Risto-Stevcev/purescript-phantom/master/logo.png)


## Motive

Purescript code is pure and total, so most testing is usually a form of documentation or done with generative tests. However, occasionally tests need to test FFI bindings, which is where PhantomJS comes in handy. If you need to test some code that deals with `Window`, or the DOM, or some web APIs, these bindings come in handy. It can be used as a simpler replacement to the karma test-runner framework.


## Example

Install `phantomjs-prebuild` from npm, and run `pulp run` or `pulp test` with `--runtime ./node_modules/.bin/phantomjs`

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
