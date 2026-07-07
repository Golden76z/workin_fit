# Skater Squats — side view: one-leg stance with rear leg bent, then deep single-leg
# squat with the rear knee dropping toward the floor behind.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: standing on one leg, rear foot lifted behind, arms forward for balance.
s.add(SideFigure(
    pelvis=(300, 370),
    torso=85, head=85,
    upper_arm=-20, forearm=-10,
    thigh=-90, shin=-90, foot=0,
    far_thigh=-105, far_shin=140, far_foot=-130,
    highlights=HL,
))

# Pose B: deep single-leg squat, rear knee just above the floor behind the
# standing foot, arms extended forward as counterbalance.
s.add(SideFigure(
    pelvis=(770, 460),
    torso=55, head=70,
    upper_arm=5, forearm=5,
    thigh=-25, shin=-110, foot=0,
    far_thigh=-100, far_shin=150, far_foot=-100,
    highlights=HL,
))

s.chevrons(520, 280)
# hips sink straight down, rear knee toward the floor
s.arrow((660, 290), (630, 400), curve=30)

s.save("legs_019")
