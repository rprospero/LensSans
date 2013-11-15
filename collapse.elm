import Automaton
import Graphics.Element
import Mouse
import Time
import Signal

title = plainText "Hello"

segment op = flow down [title,
                        opacity op <| plainText "World!",
                        opacity op <| plainText "I love",
                        opacity op <| plainText "Stacy"]

dropper op h = height h (segment op)

dbox op h = flow down [dropper op h, plainText "Next"]

move2 : (Int,Int) -> (Bool,Time.Time) -> Int -> Int
move2 (bottom,top) (click,_) value =
  let goal = if click then top else bottom
      newVal = if value > goal then value - 1
               else if value < goal
                    then value + 1
                    else value
  in newVal

tuple a b = (a,b)

clickTimer = lift2 tuple (signalFlipper Mouse.isDown) (Time.every (15 * millisecond))

slider : Automaton.Automaton (Bool,Time.Time) Int
slider = Automaton.state 0 (move2 (100,10))

flipper : Bool -> (Bool,Bool) -> ((Bool,Bool),Bool)
flipper click (oldclick,state) =
  let output = if (click && (not oldclick)) then not state else state
  in ((click,output),output)

signalFlipper : Signal Bool -> Signal Bool
signalFlipper = Automaton.run (Automaton.hiddenState (False,False) flipper) False     

main = lift (flow right) <| combine [lift2 dbox (lift (\x -> if x then 0.01 else 0.99) Mouse.isDown) <|
                                     (Automaton.run slider 100 clickTimer),
                                     lift (plainText . show) clickTimer,
                                     lift (plainText . show) <| signalFlipper Mouse.isDown]
