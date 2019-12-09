module Main exposing (..)



import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Events exposing (onClick)
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
  }

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model key url, Cmd.none )

type alias Player =
    { name : String
    , gameId : Int -- should be set to 0 for the duration of a game and assigned a val when the game concludes, iterating off the latest concluded game
    -- gameId ties all players who shared a game together to the result of that game
    , gamesWon : Int
    , limbs : Int
    , phrase : String
    }

type alias Ledger =
  { gameId : Int
    , winner : String -- should be set to the Player.name who wins the game
    , players : List String
  }


-- Update

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url


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
      ]
  }


viewLink : String -> Html msg
viewLink path =
  li [] [ Html.a [ href path ] [ Html.text path ] ]