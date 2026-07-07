# Renegade Row — side view: high plank, then one hand rowed to the hip while
# balancing on the other arm.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "biceps": 2, "abs": 2, "shoulders": 2}

# Pose A: high plank, both arms extended under the shoulders.
s.add(SideFigure(
    pelvis=(300, 435),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: near arm rowed — elbow driven up-back, hand at the ribs/hip;
# far arm stays straight on the floor supporting the plank.
s.add(SideFigure(
    pelvis=(790, 435),
    torso=18, head=24,
    upper_arm=140, forearm=-155,
    far_upper_arm=-85, far_forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

s.chevrons(540, 290)
# row path: hand pulled up toward the hip
s.arrow((640, 460), (700, 350), curve=-35)

s.save("pull_029")
