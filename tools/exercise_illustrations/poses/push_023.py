# Close-Hand Push-up — hands narrow under the chest, elbows tucked along the body.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "triceps": 2}

# Pose A: top — hand planted under the chest (slightly back vs standard).
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-95, forearm=-95,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom — elbow hugging the torso, hand planted under the chest.
s.add(SideFigure(
    pelvis=(790, 470),
    torso=8, head=16,
    upper_arm=186, forearm=-75,
    thigh=190, shin=192, foot=-110,
    highlights=HL,
))

s.chevrons(540, 280)
s.arrow((1000, 380), (1000, 470))
s.arrow((1040, 470), (1040, 380))

s.save("push_023")
