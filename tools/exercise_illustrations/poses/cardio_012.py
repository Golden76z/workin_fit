# Squat Jumps — side view: deep squat loaded, then explosive extension airborne.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2, "calves": 2}

# Pose A: deep squat, hips back, arms reaching forward for balance.
s.add(SideFigure(
    pelvis=(270, 450),
    torso=55, head=70,
    upper_arm=0, forearm=0,
    thigh=-25, shin=-115, foot=0,
    highlights=HL,
))

# Pose B: airborne, body extended, arms driving overhead.
s.add(SideFigure(
    pelvis=(760, 300),
    torso=92, head=90,
    upper_arm=118, forearm=105,
    thigh=-82, shin=-102, foot=-45,
    clearance=80,
    highlights=HL,
))

s.chevrons(510, 290)
# explode straight up
s.arrow((910, 380), (910, 200), curve=-25)

s.pulse_icon()
s.save("cardio_012")
