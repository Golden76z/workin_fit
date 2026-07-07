# Handstand Push-up — inverted against wall: arms extended, then head near floor.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"shoulders": 3, "triceps": 2, "abs": 2}

# Pose A: full handstand, arms locked out, heels on the wall.
s.wall(248)
s.add(SideFigure(
    pelvis=(290, 250),
    torso=-92, head=-90,
    upper_arm=-75, forearm=-85,
    thigh=94, shin=96, foot=140,
    scale=0.9,
    highlights=HL,
))

# Pose B: bottom, elbows bent, head close to the floor.
s.wall(728)
s.add(SideFigure(
    pelvis=(770, 320),
    torso=-92, head=-90,
    upper_arm=-30, forearm=-115,
    thigh=94, shin=96, foot=140,
    scale=0.9,
    highlights=HL,
))

s.chevrons(500, 280)
# down-then-up press cue near pose B
s.arrow((960, 380), (960, 470))
s.arrow((1000, 470), (1000, 380))

s.save("push_019")
