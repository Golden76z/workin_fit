# Heel Taps — supine, knees bent, slight crunch; hand reaches down to tap the heel.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "obliques": 2}
SUPINE = (0, -1)

# Pose A: lying on the back, knees bent, arms along the sides, shoulders curled a touch.
s.add(SideFigure(
    pelvis=(310, 500),
    torso=178, head=148,
    upper_arm=-10, forearm=-3,
    thigh=62, shin=-78, foot=-20,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose B: crunched a bit higher, hand extended to tap the heel.
s.add(SideFigure(
    pelvis=(790, 500),
    torso=166, head=130,
    upper_arm=-14, forearm=-5,
    thigh=62, shin=-78, foot=-20,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(540, 330)
# hand slides toward the heel
s.arrow((920, 430), (975, 480), curve=12)

s.save("core_021")
