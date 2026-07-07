# Tempo Push-up — slow 3s lowering (segmented arrows), explosive press up.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "triceps": 2, "shoulders": 2}

# Pose A: plank top.
s.add(SideFigure(
    pelvis=(300, 430),
    torso=18, head=24,
    upper_arm=-85, forearm=-85,
    thigh=206, shin=206, foot=-105,
    highlights=HL,
))

# Pose B: bottom of the slow descent — hand planted on the floor.
s.add(SideFigure(
    pelvis=(790, 470),
    torso=8, head=16,
    upper_arm=185, forearm=-76,
    thigh=190, shin=192, foot=-110,
    highlights=HL,
))

s.chevrons(540, 280)
# slow descent: three short stacked arrows
s.arrow((1000, 350), (1000, 385))
s.arrow((1000, 400), (1000, 435))
s.arrow((1000, 450), (1000, 485))
# explosive press: one long arrow up
s.arrow((1045, 485), (1045, 350))

s.save("push_022")
