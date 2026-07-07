# Jump Squat — side view: deep squat loaded, then airborne fully extended.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2}

# Pose A: deep squat, arms back ready to swing.
s.add(SideFigure(
    pelvis=(280, 450),
    torso=55, head=70,
    upper_arm=-115, forearm=-140,
    thigh=-25, shin=-115, foot=0,
    highlights=HL,
))

# Pose B: airborne, body extended, toes pointed, arms swung overhead.
s.add(SideFigure(
    pelvis=(770, 340),
    torso=90, head=90,
    upper_arm=105, forearm=98,
    thigh=-80, shin=-105, foot=-55,
    clearance=70,
    highlights=HL,
))

s.chevrons(520, 280)
# explosive drive upward
s.arrow((640, 430), (665, 300), curve=-25)

s.save("legs_002")
