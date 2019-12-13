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
  , phrase : String
  , password : Maybe String
  , passwordAgain : Maybe String
  , email : Maybe String
  , playerList : List Player
  , loggedIn : Bool
  , gameState : GameState
  }

type GameState
  = DeathRow -- lobby for adding players
  | Gallows -- the in-game state
  | LedgerView
  

init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
  ( Model key url "" "" Nothing Nothing Nothing [] False DeathRow, Cmd.none )

type Player -- Limbs, Username, Phrase, (following are optional) Password (x2 for new user), Email (new users)
  = Persistent Int String String String -- if a user passes this in they will need to be validated via the db
  | Guest Int String String -- guest results will not be saved, a game won by a guest will be indexed with the winner as "guest"
  | NewPersistent Int String String String String String -- if user passes in all this they will need an account created in the db

ethanGuest : Player
ethanGuest = Guest 0 "ethanGuest" "accordion"

playerList : List Player
playerList = []

type alias Ledger =
  { gameId : Int
    , winner : Player
    , players : List Player
  }


-- Update

type Msg
  = LinkClicked Browser.UrlRequest
  | UrlChanged Url.Url
  | Name String
  | Phrase String
  | Password String
  | PasswordAgain String
  | Email String


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
    
    Phrase phrase ->
      ( { model | phrase = phrase }
      , Cmd.none
      )

    Password password ->
      ( { model | password = Just password }
      , Cmd.none
      )

    PasswordAgain passwordAgain ->
      ( { model | passwordAgain = Just passwordAgain }
      , Cmd.none
      )
    
    Email email ->
      ( { model | email = Just email}
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
      [ div []
          [ viewInput "text" "Player Name" model.name Name
          , viewInput "text" "Phrase" model.phrase Phrase
          , viewMaybeInput "text" "password (optional)" model.password Password
          , text "First time players:"
          , viewMaybeInput "text" "password again" model.passwordAgain PasswordAgain
          , viewMaybeInput "text" "email address" model.email Email
          , viewValidation model
          , button [ ] [ text "Add Player" ]
          ]
      , div []
          [ -- display players list
          ]
      ]
  }

header model =
  div []
    [ Html.text "Hangmen: a multiplayer knockout Hangman game"
      , ul []
          [ viewLink "Death Row"
          ]
    ]


viewLink : String -> Html msg
viewLink path =
  li [] [ Html.a [ href path ] [ Html.text path ] ]

viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

viewMaybeInput : String -> String -> Maybe String -> (String -> msg) -> Html msg
viewMaybeInput t p v toMsg =
  case v of
    Just a ->
      input [ type_ t, placeholder p, value a, onInput toMsg ] []
    Nothing ->
      input [ type_ t, placeholder p, onInput toMsg ] []


viewValidation : Model -> Html msg
viewValidation model =
  if model.password == model.passwordAgain then
    div [ style "color" "green" ] [ text "OK" ]
  else
    div [ style "color" "red" ] [ text "Passwords do not match!" ]