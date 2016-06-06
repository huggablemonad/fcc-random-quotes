module Fortune exposing
  ( Model, init
  , Msg, update
  , subscriptions
  , view
  )

{-| This library contains functions to retrieve and display random Plan 9
fortunes.

# Model
@docs Model, init

# Update
@docs Msg, update

# Subscriptions
@docs subscriptions

# View
@docs view

-}

import Json.Decode exposing ((:=))
import Json.Decode as J
import Html
import Html.Attributes
import Html.Events exposing (onClick)
import Http
import Random
import Task
import Time


{-| Model for storing the fortune. -}
type alias Model =
  { fortune : String
  , seed : Random.Seed
  }


{-| Initialize the `Model`. -}
init : String -> (Model, Cmd Msg)
init fortune =
  (Model fortune <| Random.initialSeed 42, initFortune)


{-| Messages for retrieving a new random fortune. -}
type Msg
  = GetFortune
  | NewFortune (String, Random.Seed)
  | FetchFail Http.Error


{-| Update the `Model` with a new random fortune. -}
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    GetFortune ->
      (model, getFortune model.seed)

    NewFortune (fortune, seed) ->
      (Model fortune seed, Cmd.none)

    FetchFail _ ->
      ({ model | fortune = "Random Quote Machine error."}, Cmd.none)


{-| Return a random fortune in JSON format. -}
getFortune : Random.Seed -> Cmd Msg
getFortune seed =
  nextFortune seed
    |> Task.perform FetchFail NewFortune


{-| Return the initial random seed. -}
initSeed : Task.Task x Random.Seed
initSeed =
  let f x =
        Time.inMilliseconds x
          |> truncate
          |> Random.initialSeed
  in Task.map f Time.now


{-| Return a `Task` for getting a new fortune. -}
nextFortune : Random.Seed -> Task.Task Http.Error (String, Random.Seed)
nextFortune seed =
  let ((n, m), seed') = generateRandomPair seed
      dir = toString n
      file = toString m
      url = "fortunes/" ++ dir ++ "/" ++ file ++ ".json"
      fortune = J.object1 identity ("fortune" := J.string)
  in Http.get fortune url
       |> Task.map (\x -> (x, seed'))


{-| Initialize the random seed and get a new fortune.

This function lets us show a fortune when the page is loaded. If showing a
placeholder text like `Random Quote Machine` on page load is fine, then turn
`initSeed` into a `Cmd Msg` and pass that to `init` instead.
-}
initFortune : Cmd Msg
initFortune =
  initSeed `Task.andThen` nextFortune
    |> Task.perform FetchFail NewFortune


{-| Return a random pair of integers.

The first integer lies in the interval `[1, 8]` and is used for choosing a
fortune directory.

The second integer lies in the interval `[1, 541]` and is used for choosing a
fortune.
-}
generateRandomPair : Random.Seed -> ((Int, Int), Random.Seed)
generateRandomPair seed =
  let generator = Random.pair (Random.int 1 8) (Random.int 1 541)
  in Random.step generator seed


{-| Return subscriptions to event sources. -}
subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


{-| Render the fortune. -}
view : Model -> Html.Html Msg
view model =
  Html.div [cssDivViewPort]
    [ Html.div [cssDivMain]
        [ Html.div [cssDivControls]
            [ Html.a [tweet model.fortune, cssButton]
                [Html.text "Tweet"]
            , Html.button [onClick GetFortune, cssButton]
                [Html.text "New Fortune"]
            ]
        , Html.div [cssDivFortune]
            [ Html.pre [cssPre]
                [Html.text model.fortune]
            ]
        ]
    ]


{-| Return a Twitter url for tweeting the fortune. -}
tweet : String -> Html.Attribute Msg
tweet fortune =
  let url = "https://twitter.com/intent/tweet?text="
  in Html.Attributes.href
       <| url ++ Http.uriEncode fortune


{-| Return the CSS for changing the viewport background. -}
cssDivViewPort : Html.Attribute Msg
cssDivViewPort =
  Html.Attributes.style
    [ ("background", "cornflowerblue")
    , ("display", "flex")
    , ("height", "100vh")
    ]


{-| Return the CSS for centering the fortune and controls.

Credit: [CSS3 Flexible Box](http://www.w3schools.com/css/css3_flexbox.asp)
-}
cssDivMain : Html.Attribute Msg
cssDivMain =
  Html.Attributes.style
    [ ("display", "flex")
    , ("flex-direction", "column")
    , ("margin", "auto")
    , ("width", "60%")
    ]


{-| Return the CSS for the `div` containing the controls (getting a new fortune
and tweeting it).
-}
cssDivControls : Html.Attribute Msg
cssDivControls =
  Html.Attributes.style
    [ ("display", "flex")
    , ("justify-content", "flex-end")
    , ("margin-right", ".5em")
    ]


{-| Return the CSS for styling buttons and links.

Credit: [CSS Buttons](http://www.w3schools.com/css/css3_buttons.asp)
-}
cssButton : Html.Attribute Msg
cssButton =
  Html.Attributes.style
    [ ("background", "black")
    , ("border", "none")
    , ("color", "lemonchiffon")
    , ("cursor", "pointer")
    , ("font-size", "1.2em")
    , ("margin-left", ".5em")
    , ("padding", ".5em")
    , ("text-align", "center")
    , ("text-decoration", "none")
    ]


{-| Return the CSS for the `div` containing the fortune. -}
cssDivFortune : Html.Attribute Msg
cssDivFortune =
  Html.Attributes.style
    [ ("background", "black")
    , ("margin", ".5em")
    ]


{-| Return the CSS for the fortune. -}
cssPre : Html.Attribute Msg
cssPre =
  Html.Attributes.style
    [ ("color", "lemonchiffon")
    , ("font-size", "2em")
    , ("margin", ".5em")
    , ("max-height", "85vh")
    , ("overflow", "auto")
    , ("padding", ".5em")
    , ("white-space", "pre-wrap")
    ]
