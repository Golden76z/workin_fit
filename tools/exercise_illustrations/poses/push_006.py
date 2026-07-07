# Pike Push-up — hips high (downward dog), head lowers between the hands.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"shoulders": 3, "triceps": 2}
HINT = (0, 1)  # belly faces down/feet side in the pike

# Pose A: inverted V, arms in line with the torso.
s.add(SideFigure(
    pelvis=(300, 300),
    torso=-50, head=-85,
    upper_arm=-51, forearm=-51,
    thigh=246, shin=248, foot=-58,
    front_hint=HINT,
    highlights=HL,
))

# Pose B: elbows bent, head dips toward the floor, hips stay high.
s.add(SideFigure(
    pelvis=(790, 310),
    torso=-62, head=-75,
    upper_arm=-30, forearm=-95,
    thigh=250, shin=253, foot=-62,
    front_hint=HINT,
    highlights=HL,
))

s.chevrons(560, 280)
s.arrow((980, 380), (940, 480), curve=-20)

s.save("push_006")
