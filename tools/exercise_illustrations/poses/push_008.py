# Knee Push-up — push-up from the knees, shins raised and crossed back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2}

# Pose A: top position, arms extended, knees on the floor, feet up.
s.add(SideFigure(
    pelvis=(300, 440),
    torso=28, head=32,
    upper_arm=-78, forearm=-78,
    thigh=251, shin=160, foot=125,
    highlights=HL,
))

# Pose B: bottom, elbows bent back, chest low, knees stay grounded.
s.add(SideFigure(
    pelvis=(790, 470),
    torso=6, head=12,
    upper_arm=183, forearm=-84,
    thigh=226, shin=150, foot=120,
    highlights=HL,
))

s.chevrons(540, 280)
s.arrow((1000, 380), (1000, 470))
s.arrow((1040, 470), (1040, 380))

s.save("push_008")
