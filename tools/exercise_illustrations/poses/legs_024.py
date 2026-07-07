# Jump Squat to Tuck — side view: loaded deep squat, then airborne with both
# knees tucked up to the chest.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2, "abs": 2}

# Pose A: deep squat loading the jump, arms swung back.
s.add(SideFigure(
    pelvis=(280, 450),
    torso=55, head=70,
    upper_arm=-140, forearm=-160,
    thigh=-25, shin=-115, foot=0,
    highlights=HL,
))

# Pose B: airborne, knees tucked to the chest, arms reaching forward.
s.add(SideFigure(
    pelvis=(780, 330),
    torso=80, head=85,
    upper_arm=-30, forearm=-15,
    thigh=25, shin=-80, foot=-30,
    clearance=110,
    highlights=HL,
))

s.chevrons(520, 260)
# explode upward off the floor
s.arrow((640, 480), (665, 330), curve=-30)

s.save("legs_024")
