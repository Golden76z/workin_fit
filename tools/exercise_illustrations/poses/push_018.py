# One-Arm Push-up — top, then bottom; free arm tucked behind the back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2, "abs": 2, "obliques": 2}

# Pose A: plank top on a single extended arm, other arm behind the back.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    far_upper_arm=205, far_forearm=168,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom, single working elbow bent back, hand planted on the floor.
s.add(SideFigure(
    pelvis=(790, 470),
    torso=8, head=16,
    upper_arm=185, forearm=-76,
    far_upper_arm=196, far_forearm=160,
    thigh=190, shin=192, foot=-110,
    highlights=HL,
))

s.chevrons(540, 280)
s.arrow((1000, 380), (1000, 470))
s.arrow((1040, 470), (1040, 380))

s.save("push_018")
