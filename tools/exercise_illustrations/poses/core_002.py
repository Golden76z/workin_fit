# Side Plank — hold: body straight diagonal on one forearm, top arm raised.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

f = SideFigure(
    pelvis=(480, 430),
    torso=13, head=18,
    upper_arm=-80, forearm=-2,          # support forearm flat on floor
    far_upper_arm=95, far_forearm=95,   # top arm reaching straight up
    thigh=193, shin=193, foot=188,      # legs straight, feet stacked, foot on its side
    scale=1.25,
    highlights={"obliques": 3, "abs": 2},
)
s.add(f)
print("elbow", f.j["elbow"], "hand", f.j["hand"], "toe", f.j["toe"])

# small arrow hinting the hips staying lifted
s.arrow((520, 330), (520, 270))

s.save("core_002")
