# Bird Dog — quadruped hold, opposite arm and leg extended in a line.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

f = SideFigure(
    pelvis=(500, 400),
    torso=22, head=10,
    upper_arm=-85, forearm=-85,          # support arm straight down
    far_upper_arm=27, far_forearm=27,    # opposite arm reaching forward
    thigh=-100, shin=175, foot=-140,     # support knee on the floor
    far_thigh=192, far_shin=190, far_foot=188,  # opposite leg extended back
    scale=1.2,
    highlights={"abs": 3, "lowerBack": 2, "glutes": 2},
)
s.add(f)
print("knee", f.j["knee"], "hand", f.j["hand"], "far_toe", f.j["far_toe"],
      "far_hand", f.j["far_hand"])

# hints: arm reaches forward, leg reaches back
s.arrow((850, 320), (920, 315))
s.arrow((190, 400), (120, 405))

s.save("core_008")
