# Plank Up-Downs — high plank on hands (left) to forearm plank (right).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "shoulders": 2, "triceps": 2}

# Pose A: high plank, arms extended.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: forearm plank, elbow under the shoulder.
s.add(SideFigure(
    pelvis=(780, 440),
    torso=10, head=15,
    upper_arm=-88, forearm=-5,
    thigh=190, shin=190, foot=-120,
    highlights=HL,
))

s.chevrons(540, 300)
# shoulders drop then push back up
s.arrow((1010, 360), (1010, 450))
s.arrow((1045, 450), (1045, 360))

s.save("core_020")
