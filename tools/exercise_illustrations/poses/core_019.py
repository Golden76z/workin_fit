# Side Plank with Leg Lift — front view of a side plank; leg down, then lifted.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"obliques": 3, "glutes": 2}

# Pose A: side plank on the forearm, legs stacked.
s.add(FrontFigure(
    pelvis=(270, 470),
    torso=163,
    l_upper_arm=-85, l_forearm=-3,      # support forearm flat on the floor
    r_upper_arm=100, r_forearm=78,       # top arm reaching up
    l_thigh=-17, l_shin=-17,
    r_thigh=-13, r_shin=-13,
    highlights=HL,
))

# Pose B: same plank, top leg lifted.
s.add(FrontFigure(
    pelvis=(740, 470),
    torso=163,
    l_upper_arm=-85, l_forearm=-3,
    r_upper_arm=100, r_forearm=78,
    l_thigh=-17, l_shin=-17,
    r_thigh=22, r_shin=22,
    highlights=HL,
))

s.chevrons(510, 300)
# top leg travels up
s.arrow((1000, 500), (1000, 380), curve=-20)

s.save("core_019")
