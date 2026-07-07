# Wide Push-up — hands wider than shoulders, elbows flare out at the bottom.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2}

# Pose A: plank top with the two arms visibly splayed apart (wide grip).
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-78, forearm=-78,
    far_upper_arm=-102, far_forearm=-102,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom, elbows flared high above the shoulders, chest very low.
s.add(SideFigure(
    pelvis=(790, 475),
    torso=5, head=10,
    upper_arm=150, forearm=-82,
    thigh=180, shin=182, foot=-100,
    highlights=HL,
))

s.chevrons(540, 280)
s.arrow((1000, 380), (1000, 470))
s.arrow((1040, 470), (1040, 380))

s.save("push_005")
