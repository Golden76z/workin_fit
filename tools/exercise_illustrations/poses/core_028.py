# Tuck Front Lever Hold — hang from bar, knees tucked, torso near horizontal.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
SUPINE = (0, -1)  # belly faces the ceiling in a front lever

s.bar(140, 320, 780)

f = SideFigure(
    pelvis=(710, 302),
    torso=182, head=195,
    upper_arm=95, forearm=95,
    thigh=126, shin=-18, foot=-70,
    snap=False, scale=1.25,
    front_hint=SUPINE,
    highlights={"abs": 3, "back": 2, "biceps": 2},
)
s.add(f)
print("hand:", f.j["hand"])

# effort cue: hips held up toward horizontal
s.arrow((730, 440), (730, 360))

s.save("core_028")
