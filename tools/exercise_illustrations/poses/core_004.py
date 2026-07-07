# Bicycle Crunches — supine, torso crunched, opposite knee to chest, legs alternate.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
SUPINE = (0, -1)
HL = {"abs": 3, "obliques": 2}

# Pose 1: near leg extended low, far knee pulled toward the chest.
s.add(SideFigure(
    pelvis=(300, 505),
    torso=160, head=130,
    upper_arm=140, forearm=-125,   # hand behind the head
    thigh=15, shin=8, foot=45,
    far_thigh=110, far_shin=-5, far_foot=40,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose 2: legs switched — near knee in, far leg extended.
s.add(SideFigure(
    pelvis=(770, 505),
    torso=160, head=130,
    upper_arm=140, forearm=-125,
    thigh=110, shin=-5, foot=40,
    far_thigh=15, far_shin=8, far_foot=45,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(520, 330)
s.arrow((985, 495), (1015, 425), curve=-20)

s.save("core_004")
