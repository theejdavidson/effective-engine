module Main exposing (..)



import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (..)
import Url

-- Main
main : Program () Model Msg
main =
  Browser.application
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    , onUrlChange = UrlChanged
    , onUrlRequest = LinkClicked
    }


-- Model

type alias Model =
  { key : Nav.Key
  , url : Url.Url
  , name : String
  , password : String
  , passwordAgain : String
  }

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model key url "" "" "", Cmd.none )

type alias Player =
    { name : String
    , limbs : Int
    , phrase : String
    }

ethan : Player

ethan = { name = "ethan", limbs = 0, phrase = "_" }

-- gameId should be set to 0 for the duration of a game and assigned a val when the game concludes, iterating off the latest concluded game
-- gameId ties all players who shared a game together to the result of that game
type User 
  = Persistent Player { gameId : Int, gamesWon : Int}
  | Guest Player

type alias Ledger =
  { gameId : Int
    , winner : User
    , players : List User
  }


-- Update

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | Name String
  | Password String
  | PasswordAgain String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    LinkClicked urlRequest ->
      case urlRequest of
        Browser.Internal url ->
          ( model, Nav.pushUrl model.key (Url.toString url) )

        Browser.External href ->
          ( model, Nav.load href )

    UrlChanged url ->
      ( { model | url = url }
      , Cmd.none
      )

    Name name ->
      ( { model | name = name }
      , Cmd.none
      )

    Password password ->
      ( { model | password = password }
      , Cmd.none
      )

    PasswordAgain password ->
      ( { model | passwordAgain = password }
      , Cmd.none
      )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
  Sub.none


-- View

view : Model -> Browser.Document Msg
view model =
  { title = "Hangmen"
  , body =
      [ Html.text "Hangmen: a multiplayer knockout Hangman game"
      , ul []
          [ viewLink "Death Row"
          , viewLink "Gallows"
          , viewLink "Ledger"
          ]
      , div []
          [ viewInput "text" "Player Name" model.name Name
          , viewInput "text" "password (optional)" model.password Password
          , viewInput "text" "password again (first time users)" model.passwordAgain PasswordAgain
          , viewValidation model
          ]
      ]
  }


viewLink : String -> Html msg
viewLink path =
  li [] [ Html.a [ href path ] [ Html.text path ] ]

viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
  if model.password == model.passwordAgain then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Passwords do not match!" ]