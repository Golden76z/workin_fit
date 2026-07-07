# Shrimp Squat — side view: standing holding the rear foot, then deep single-leg squat.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: standing on one leg, rear foot held behind the glutes by the far hand.
s.add(SideFigure(
    pelvis=(300, 370),
    torso=88, head=90,
    upper_arm=-5, forearm=0,
    far_upper_arm=-115, far_forearm=-150,
    thigh=-90, shin=-90, foot=0,
    far_thigh=-105, far_shin=135, far_foot=170,
    highlights=HL,
))

# Pose B: deep single-leg squat, rear knee reaching down behind, foot still held.
s.add(SideFigure(
    pelvis=(780, 460),
    torso=62, head=75,
    upper_arm=5, forearm=5,
    far_upper_arm=-138, far_forearm=-138,
    thigh=-5, shin=-100, foot=0,
    far_thigh=-115, far_shin=105, far_foot=190,
    highlights=HL,
))

s.chevrons(520, 280)
# hips sink straight down
s.arrow((650, 300), (630, 400), curve=25)

s.save("legs_038")
