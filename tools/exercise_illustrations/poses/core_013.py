# Plank Jacks — side view: straight-arm plank, feet together then jumped apart.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "shoulders": 2}

# Pose A: high plank, feet together.
s.add(SideFigure(
    pelvis=(320, 430),
    torso=16, head=22,
    upper_arm=-86, forearm=-86,
    thigh=206, shin=209, foot=-105,
    highlights=HL,
))

# Pose B: feet jumped wide (far leg visibly split, both toes grounded).
s.add(SideFigure(
    pelvis=(800, 430),
    torso=16, head=22,
    upper_arm=-86, forearm=-86,
    thigh=196, shin=217, foot=-95,
    far_thigh=213, far_shin=199, far_foot=-105,
    highlights=HL,
))

s.chevrons(545, 300)
# feet snap outward
s.arrow((640, 495), (588, 462), curve=-12)
s.arrow((668, 525), (722, 548), curve=-12)

s.save("core_013")
