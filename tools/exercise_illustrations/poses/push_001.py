# Push-up — side view: top position, then bottom position.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2}

# Pose A: plank top, arms extended under shoulders.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom, elbows bent back, chest near floor, hands grounded.
s.add(SideFigure(
    pelvis=(790, 470),
    torso=6, head=12,
    upper_arm=170, forearm=-80,
    thigh=186, shin=188, foot=-100,
    highlights=HL,
))

s.chevrons(540, 280)
# down-then-up motion cue near pose B
s.arrow((1000, 380), (1000, 470))
s.arrow((1040, 470), (1040, 380))

s.save("push_001")
