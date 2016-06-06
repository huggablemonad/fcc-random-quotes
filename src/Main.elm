module Main exposing (main)

{-| # Build a Random Quote Machine
----------------------------------

**Objective**: Build an app that is functionally similar to this:
<https://codepen.io/FreeCodeCamp/full/ONjoLe/>.

1. **Rule #1:** Don't look at the example project's code. Figure it out for
   yourself.

2. **Rule #2:** Fulfill the below [user
   stories](https://en.wikipedia.org/wiki/User_story). Use whichever libraries
   or APIs you need. Give it your own personal style.

3. **User Story:** I can click a button to show me a new random quote.

4. **User Story:** I can press a button to tweet out a quote.

<https://www.freecodecamp.com/challenges/build-a-random-quote-machine>

# Main
@docs main

-}

import Fortune
import Html.App


{-| Main entry point. -}
main : Program Never
main =
  Html.App.program
    { init = Fortune.init "Random Quote Machine"
    , update = Fortune.update
    , view = Fortune.view
    , subscriptions = Fortune.subscriptions
    }
