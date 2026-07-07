# Archer Inverted Row — side view under a low bar: hang with straight arms,
# then row up toward one hand while the other arm stays extended along the bar.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "biceps": 2, "forearms": 2}
SUPINE = (0, -1)

# Pose A: hanging under the bar, arms straight, body in a rigid incline,
# heels on the ground.
fa = SideFigure(
    pelvis=(300, 470),
    torso=22, head=25,
    upper_arm=95, forearm=92,
    thigh=195, shin=188, foot=115,
    front_hint=SUPINE,
    highlights=HL,
)
BAR_Y = fa.j["hand"][1]
s.bar(BAR_Y, 190, 430)
s.add(fa)

# Pose B: rowed up — chest pulled to the bar, near arm bent (hand still on
# the bar), far arm extended reaching along the bar.
fb = SideFigure(
    pelvis=(770, 440),
    torso=50, head=53,
    upper_arm=-150, forearm=88,
    far_upper_arm=15, far_forearm=12,
    thigh=222, shin=214, foot=100,
    front_hint=SUPINE,
    highlights=HL,
)
s.bar(BAR_Y, 690, 1010)
s.add(fb)

if os.environ.get("POSE_DEBUG"):
    print("A hand:", fa.j["hand"], "B hand:", fb.j["hand"], "B far:", fb.j["far_hand"])

s.chevrons(540, 300)
# pull cue: chest drawn up toward the bar
s.arrow((640, 470), (680, 380), curve=-25)

s.save("pull_030")
