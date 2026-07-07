# Pistol Squat — side view: one-leg stand with free leg forward, then deep
# single-leg squat with the free leg extended straight ahead.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: standing on one leg, other leg raised straight forward, arms forward.
s.add(SideFigure(
    pelvis=(280, 370),
    torso=88, head=90,
    upper_arm=0, forearm=0,
    thigh=-90, shin=-90, foot=0,
    far_thigh=-25, far_shin=-25, far_foot=-15,
    highlights=HL,
))

# Pose B: pistol bottom — hips on heel, free leg held horizontal, arms forward.
s.add(SideFigure(
    pelvis=(740, 480),
    torso=60, head=75,
    upper_arm=5, forearm=5,
    thigh=-15, shin=-105, foot=0,
    far_thigh=10, far_shin=8, far_foot=18,
    highlights=HL,
))

s.chevrons(500, 280)
s.arrow((640, 300), (610, 410), curve=30)

s.save("legs_003")
