# Squat Pulse — side view: bottom of squat, pulsing a few inches up and down.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"quads": 3, "glutes": 2}

# Pose A: deep squat bottom, arms forward.
s.add(SideFigure(
    pelvis=(280, 455),
    torso=55, head=70,
    upper_arm=0, forearm=0,
    thigh=-25, shin=-115, foot=0,
    highlights=HL,
))

# Pose B: pulsed slightly up — still deep in the squat.
s.add(SideFigure(
    pelvis=(750, 425),
    torso=62, head=75,
    upper_arm=5, forearm=5,
    thigh=-42, shin=-108, foot=0,
    highlights=HL,
))

s.chevrons(520, 270)
# small pulse arrows near the hips: up then down
s.arrow((635, 420), (635, 360))
s.arrow((668, 360), (668, 420))

s.save("legs_026")
