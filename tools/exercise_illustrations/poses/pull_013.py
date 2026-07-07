# Single Arm Row — one-arm bodyweight row on a towel/band anchor, other arm free.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

HL = {"back": 3, "biceps": 2}

# Pose A: leaning back, working arm extended on the strap, far arm hanging.
s.wall(403)
fa = SideFigure(
    pelvis=(245, 380),
    torso=117, head=105,
    upper_arm=-18, forearm=-12,
    far_upper_arm=-48, far_forearm=-38,
    thigh=-63, shin=-63, foot=0,
    highlights=HL,
)
s.add(fa)
s.line((403, 336), (fa.j["hand"][0] + 4, fa.j["hand"][1]))

# Pose B: pulled up, working elbow drawn back, far arm still hanging.
s.wall(827)
fb = SideFigure(
    pelvis=(740, 380),
    torso=100, head=95,
    upper_arm=-128, forearm=2,
    far_upper_arm=-55, far_forearm=-42,
    thigh=-77, shin=-77, foot=0,
    highlights=HL,
)
s.add(fb)
s.line((827, 330), (fb.j["hand"][0] + 4, fb.j["hand"][1]))
print("A hand:", fa.j["hand"], " B hand:", fb.j["hand"])

s.chevrons(520, 200)
# pull toward the anchor
s.arrow((590, 420), (670, 420))

s.save("pull_013")
