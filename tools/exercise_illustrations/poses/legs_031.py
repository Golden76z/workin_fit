# Nordic Curl Negative — kneeling with ankles anchored (couch edge as a box),
# torso lowers slowly forward, arms ready to catch.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"hamstrings": 3, "glutes": 2}

# Pose A: tall kneeling, ankles anchored, arms along the body.
a = SideFigure(
    pelvis=(300, 440),
    torso=88, head=88,
    upper_arm=-75, forearm=-70,
    thigh=-92, shin=178, foot=178,
    highlights=HL,
)
s.add(a)
ax, ay = a.j["ankle"]
s.box(ax - 15, ay - 38, 75, 42)

# Pose B: torso lowered forward, knee-hip-shoulder line at ~40 deg,
# arms extended down-forward to catch the fall.
b = SideFigure(
    pelvis=(720, 425),
    torso=42, head=48,
    upper_arm=-35, forearm=-45,
    thigh=-138, shin=178, foot=178,
    highlights=HL,
)
s.add(b)
bx, by = b.j["ankle"]
s.box(bx - 15, by - 38, 75, 42)

s.chevrons(520, 250)
# torso descends forward in an arc around the knees
s.arrow((830, 260), (900, 360), curve=35)

s.save("legs_031")
