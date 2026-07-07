# Donkey Kicks — quadruped: on hands and knees, then one leg kicked back
# and up with the knee kept bent, sole toward the ceiling.
# Base pose tuned so hand, knee AND tucked toes all touch the ground
# (torso tilted up ~22 deg, elbow slightly bent).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"glutes": 3}

# Pose A: all fours — hands under shoulders, knee and toes grounded.
a = SideFigure(
    pelvis=(280, 400),
    torso=22, head=30,
    upper_arm=-60, forearm=-114,
    thigh=-114, shin=175, foot=-155,
    highlights=HL,
)
s.add(a)

# Pose B: near leg kicked back-up, knee bent, supporting far leg stays down.
b = SideFigure(
    pelvis=(750, 400),
    torso=22, head=30,
    upper_arm=-60, forearm=-114,
    thigh=150, shin=85, foot=170,                  # kicking leg
    far_thigh=-114, far_shin=175, far_foot=-155,   # supporting leg
    highlights=HL,
)
s.add(b)

if os.environ.get("POSE_DEBUG"):
    print("A knee", a.j["knee"], "hand", a.j["hand"], "toe", a.j["toe"])
    print("B far_knee", b.j["far_knee"], "hand", b.j["hand"],
          "far_toe", b.j["far_toe"], "kick ankle", b.j["ankle"])

s.chevrons(510, 250)
# heel drives toward the ceiling
s.arrow((600, 480), (592, 335), curve=-35)

s.save("legs_014")
