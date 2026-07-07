# Standing Glute Kickback — side view: standing tall, then one leg driven straight back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"glutes": 3, "hamstrings": 2}

# Pose A: standing tall, arms slightly forward.
s.add(SideFigure(
    pelvis=(300, 370),
    torso=90, head=90,
    upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
))

# Pose B: leaning slightly forward on the support leg, far leg kicked straight back.
s.add(SideFigure(
    pelvis=(760, 370),
    torso=75, head=80,
    upper_arm=-20, forearm=-10,
    thigh=-88, shin=-90, foot=0,
    far_thigh=192, far_shin=192, far_foot=-115,
    highlights=HL,
))

s.chevrons(520, 290)
# heel drives back and up (kicked leg is behind, on the left of pose B)
s.arrow((640, 505), (585, 425), curve=25)

s.save("legs_036")
