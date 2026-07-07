# Seated Calf Raise — side view: sitting on a box, heels flat, then heels lifted.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"calves": 3}

# Pose A: seated, knees at 90 degrees, feet flat, hands resting on thighs.
fa = SideFigure(
    pelvis=(280, 400),
    torso=88, head=90,
    upper_arm=-60, forearm=-25,
    thigh=-3, shin=-90, foot=-15,
    highlights=HL,
)
s.add(fa)

# Pose B: same seat, heels raised — ball of the foot on the floor, knee higher.
fb = SideFigure(
    pelvis=(740, 400),
    torso=88, head=90,
    upper_arm=-60, forearm=-25,
    thigh=2, shin=-85, foot=-55,
    highlights=HL,
)
s.add(fb)

if os.environ.get("DEBUG"):
    print("A hip", fa.j["hip"], "knee", fa.j["knee"], "ankle", fa.j["ankle"])
    print("B hip", fb.j["hip"], "knee", fb.j["knee"], "ankle", fb.j["ankle"])

# Boxes under the hips (bench) — tops meet the glutes.
s.box(215, 462, 112, 86)
s.box(675, 452, 112, 96)

s.chevrons(510, 300)
# heels lift up
s.arrow((885, 525), (885, 455), curve=0)

s.save("legs_037")
