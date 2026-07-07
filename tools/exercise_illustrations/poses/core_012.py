# Reverse Crunches — side view: supine knees bent, then knees to chest hips up.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3}
SUPINE = (0, -1)

# Pose A: on the back, arms along the floor, knees over hips bent 90 deg.
s.add(SideFigure(
    pelvis=(310, 500),
    torso=178, head=175,
    upper_arm=-4, forearm=-4,
    thigh=82, shin=0, foot=-25,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose B: pelvis curled up off the floor, knees pulled toward the chest.
s.add(SideFigure(
    pelvis=(800, 440),
    torso=200, head=172,
    upper_arm=-4, forearm=-4,
    thigh=142, shin=5, foot=-30,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(545, 300)
# hips roll up and back toward the chest
s.arrow((960, 420), (900, 320), curve=35)

s.save("core_012")
