# Single Leg Squat (pistol) — side view: one-leg stance with the free leg held
# forward, then a full-depth squat with the free leg extended straight ahead.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: standing on one leg, free leg raised slightly forward, arms out front.
s.add(SideFigure(
    pelvis=(280, 370),
    torso=85, head=85,
    upper_arm=-15, forearm=-5,
    thigh=-90, shin=-90, foot=0,
    far_thigh=-48, far_shin=-30, far_foot=35,
    highlights=HL,
))

# Pose B: pistol bottom — hips at heel height, standing knee fully bent,
# free leg extended straight forward, arms reaching forward for balance.
s.add(SideFigure(
    pelvis=(740, 490),
    torso=65, head=75,
    upper_arm=5, forearm=5,
    thigh=-10, shin=-115, foot=0,
    far_thigh=8, far_shin=8, far_foot=65,
    highlights=HL,
))

s.chevrons(520, 280)
# hips drop all the way down onto the heel
s.arrow((640, 300), (610, 420), curve=30)

s.save("legs_022")
