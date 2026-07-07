# Diamond Push-up — hands together under the chest, elbows tucked along the body.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "triceps": 2}

# Pose A: plank top, both hands stacked under the sternum (far hand visible).
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-82, forearm=-82,
    far_upper_arm=-86, far_forearm=-86,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom, elbows hugging the ribs (tucked straight back).
s.add(SideFigure(
    pelvis=(790, 470),
    torso=6, head=12,
    upper_arm=178, forearm=-82,
    thigh=186, shin=188, foot=-100,
    highlights=HL,
))

s.chevrons(540, 280)
s.arrow((1000, 380), (1000, 470))
s.arrow((1040, 470), (1040, 380))

s.save("push_004")
