# Jumping Lunge — side view: lunge bottom, then airborne with the legs
# scissoring to switch sides.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2}

# Pose A: lunge bottom, loaded.
s.add(SideFigure(
    pelvis=(270, 430),
    torso=88, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-15, shin=-95, foot=0,
    far_thigh=-100, far_shin=172, far_foot=-100,
    highlights=HL,
))

# Pose B: airborne — legs scissoring mid-switch, arms split for balance.
s.add(SideFigure(
    pelvis=(770, 330),
    torso=90, head=90,
    upper_arm=-35, forearm=-15,
    thigh=-45, shin=-130, foot=-55,
    far_upper_arm=-130, far_forearm=-155,
    far_thigh=-135, far_shin=-95, far_foot=-80,
    clearance=60,
    highlights=HL,
))

s.chevrons(500, 280)
# explosive jump up
s.arrow((595, 450), (622, 320), curve=-25)

s.save("legs_008")
