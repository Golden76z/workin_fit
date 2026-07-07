# Reverse Plank Walk — reverse plank, hands step backward (toward the head).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

SUPINE = (0, -1)
HL = {"back": 3, "shoulders": 2, "glutes": 2, "hamstrings": 2}

# Pose A: steady reverse plank, both hands planted.
s.add(SideFigure(
    pelvis=(300, 440),
    torso=157, head=172,
    upper_arm=-100, forearm=-100,
    thigh=-33, shin=-33, foot=50,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose B: far hand lifted, swinging back (walking toward the head side).
s.add(SideFigure(
    pelvis=(790, 440),
    torso=157, head=172,
    upper_arm=-100, forearm=-100,
    far_upper_arm=-128, far_forearm=-118,
    thigh=-33, shin=-33, foot=50,
    far_thigh=-33, far_shin=-33, far_foot=50,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(520, 300)
# hands walk backward (to the left)
s.arrow((610, 520), (520, 520))

s.save("pull_012")
