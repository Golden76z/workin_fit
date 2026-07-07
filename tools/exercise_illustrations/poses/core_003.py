# Mountain Climbers — high plank, alternating knees driven to the chest.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "shoulders": 2}

# Pose 1: near leg extended back (toes grounded), far knee driven under the chest.
s.add(SideFigure(
    pelvis=(280, 420),
    torso=12, head=16,
    upper_arm=-85, forearm=-85,
    thigh=210, shin=210, foot=-95,
    far_thigh=-15, far_shin=-125, far_foot=-35,
    highlights=HL,
))

# Pose 2: near knee driven in, far leg extended back (toes grounded).
s.add(SideFigure(
    pelvis=(760, 420),
    torso=12, head=16,
    upper_arm=-85, forearm=-85,
    thigh=-15, shin=-125, foot=-35,
    far_thigh=210, far_shin=210, far_foot=-95,
    highlights=HL,
))

s.chevrons(520, 300)
s.arrow((700, 350), (815, 342), curve=-25)

s.save("core_003")
