# Cross-Body Mountain Climber — high plank, drive knee toward opposite elbow.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"obliques": 3, "abs": 2, "shoulders": 2}

# Pose A: high plank start.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: far knee driven forward across the body toward the opposite elbow.
s.add(SideFigure(
    pelvis=(790, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    far_thigh=-5, far_shin=-150, far_foot=-100,
    highlights=HL,
))

s.chevrons(540, 300)
# knee drives forward under the chest toward the opposite elbow
s.arrow((725, 530), (788, 502), curve=-30)
s.pulse_icon()

s.save("core_026")
