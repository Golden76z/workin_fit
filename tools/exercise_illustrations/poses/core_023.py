# Sit-up — lying flat (left) then curled up to seated (right), knees bent.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3}
SUPINE = (0, -1)

# Pose A: flat on the back, knees bent, arms resting across the chest line.
s.add(SideFigure(
    pelvis=(310, 500),
    torso=181, head=168,
    upper_arm=50, forearm=-35,
    thigh=62, shin=-78, foot=-20,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose B: torso curled up toward the knees.
s.add(SideFigure(
    pelvis=(790, 500),
    torso=125, head=105,
    upper_arm=-25, forearm=-10,
    thigh=62, shin=-78, foot=-20,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(540, 320)
# torso curls up and forward
s.arrow((620, 470), (700, 350), curve=-40)

s.save("core_023")
