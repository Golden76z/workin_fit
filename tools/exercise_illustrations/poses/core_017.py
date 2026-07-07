# L-Sit — isometric hold: one centered pose, body held on hands, legs horizontal.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

f = SideFigure(
    pelvis=(470, 470),
    torso=84, head=76,
    upper_arm=-113, forearm=-104,
    thigh=8, shin=3, foot=-6,
    scale=1.25,
    highlights={"abs": 3, "triceps": 2},
)
s.add(f)

# effort hint: legs held up
s.arrow((760, 520), (760, 430))

s.save("core_017")
