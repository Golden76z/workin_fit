# Flutter Kicks — supine, straight legs alternately kicking up and down.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
SUPINE = (0, -1)
HL = {"abs": 3}

# Pose 1: near leg up, far leg low above the floor.
s.add(SideFigure(
    pelvis=(280, 505),
    torso=178, head=172,
    upper_arm=-20, forearm=-15,    # hands beside/under hips
    thigh=28, shin=26, foot=55,
    far_thigh=8, far_shin=6, far_foot=35,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose 2: legs switched.
s.add(SideFigure(
    pelvis=(750, 505),
    torso=178, head=172,
    upper_arm=-20, forearm=-15,
    thigh=8, shin=6, foot=35,
    far_thigh=28, far_shin=26, far_foot=55,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(520, 330)
s.arrow((960, 380), (960, 470))
s.arrow((1000, 470), (1000, 380))

s.save("core_006")
