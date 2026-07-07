# Fire Hydrants — quadruped: on hands and knees, then the bent (90/90) leg
# lifted out to the side as one folded unit. Side view compromise: the folded
# leg rises toward hip height staying folded and near-horizontal (foot never
# swings up toward the ceiling, unlike a donkey kick), arrow sweeps outward.
# Base pose tuned so hand, knee AND tucked toes all touch the ground.
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

# Pose B: bent leg lifted out — knee swung up/out to near hip height, shin
# still folded (pointing back, slightly down), foot stays low. Clearly
# different from the donkey-kick end pose where the shin points up.
b = SideFigure(
    pelvis=(750, 400),
    torso=22, head=30,
    upper_arm=-60, forearm=-114,
    thigh=190, shin=135, foot=-170,                # lifted folded leg, knee flexed

    far_thigh=-114, far_shin=175, far_foot=-155,   # supporting leg
    highlights=HL,
)
s.add(b)

if os.environ.get("POSE_DEBUG"):
    print("A knee", a.j["knee"], "hand", a.j["hand"], "toe", a.j["toe"])
    print("B far_knee", b.j["far_knee"], "far_toe", b.j["far_toe"],
          "lift knee", b.j["knee"], "lift ankle", b.j["ankle"],
          "lift toe", b.j["toe"])

s.chevrons(510, 250)
# knee sweeps up and out (wide lateral arc)
s.arrow((566, 535), (542, 428), curve=25)

s.save("legs_015")
