# Spiderman Push-up — side view: plank top, then bottom with the far knee
# driven forward toward the elbow.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2, "abs": 2, "obliques": 2}

# Pose A: plank top.
s.add(SideFigure(
    pelvis=(290, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom — elbows bent, far knee pulled up toward the elbow
# (knee stays lifted, off the floor).
s.add(SideFigure(
    pelvis=(780, 468),
    torso=6, head=12,
    upper_arm=177, forearm=-83,
    thigh=188, shin=190, foot=-100,
    far_thigh=-5, far_shin=200, far_foot=200,
    highlights=HL,
))

s.chevrons(530, 280)
# knee drives forward toward the elbow
s.arrow((705, 540), (815, 520), curve=25)

s.save("push_011")
