# Arm Circles — arms extended out to the sides, drawing controlled circles.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"shoulders": 3}

# Pose A: arms straight out to the sides (T position).
s.add(FrontFigure(
    pelvis=(300, 370),
    l_upper_arm=178, l_forearm=178,
    r_upper_arm=2, r_forearm=2,
    l_thigh=-95, r_thigh=-85,
    highlights=HL,
))

# Pose B: arms tilted mid-circle, with circular motion arrows at the hands.
s.add(FrontFigure(
    pelvis=(770, 370),
    l_upper_arm=162, l_forearm=162,
    r_upper_arm=18, r_forearm=18,
    l_thigh=-95, r_thigh=-85,
    highlights=HL,
))

s.chevrons(535, 280)
# circular cue arrows wrapping pose B hands
s.arrow((586, 182), (582, 262), curve=32)
s.arrow((648, 278), (652, 198), curve=32)
s.arrow((954, 182), (958, 262), curve=-32)
s.arrow((892, 278), (888, 198), curve=-32)

s.save("push_024")
