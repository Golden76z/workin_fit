# Plank — side view: single hold pose, centered, on forearms.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

# Forearm plank: upper arm vertical, forearm flat on the floor pointing forward.
f = SideFigure(
    pelvis=(480, 440),
    torso=7, head=12,
    upper_arm=-80, forearm=-2,
    thigh=187, shin=187, foot=-105,
    scale=1.25,
    highlights={"abs": 3, "lowerBack": 2},
)
s.add(f)
print("elbow", f.j["elbow"], "hand", f.j["hand"], "toe", f.j["toe"])

s.save("core_001")
