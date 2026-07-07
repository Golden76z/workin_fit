# Staggered Push-up — one hand forward, one hand back; top then bottom.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2}

# Pose A: plank top — near hand under shoulder, far hand planted forward.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-95, forearm=-95,
    far_upper_arm=-75, far_forearm=-80,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom — both elbows bent, both staggered hands planted on the floor.
s.add(SideFigure(
    pelvis=(790, 470),
    torso=8, head=16,
    upper_arm=185, forearm=-76,
    far_upper_arm=-15, far_forearm=-58,
    thigh=190, shin=192, foot=-110,
    highlights=HL,
))

s.chevrons(540, 280)
s.arrow((1020, 380), (1020, 470))

s.save("push_021")
