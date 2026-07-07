# Bodyweight Squat — side view: standing, then deep squat with arms forward.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: standing tall, arms at sides (slightly forward so they read).
s.add(SideFigure(
    pelvis=(300, 370),
    torso=90, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
))

# Pose B: deep squat, hips back, arms extended forward.
s.add(SideFigure(
    pelvis=(720, 450),
    torso=55, head=70,
    upper_arm=0, forearm=0,
    thigh=-25, shin=-115, foot=0,
    highlights=HL,
))

s.chevrons(520, 280)
# hips sink down and back, cue drawn behind the figure
s.arrow((660, 290), (620, 390), curve=30)

s.save("legs_001")
