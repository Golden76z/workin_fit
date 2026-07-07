# Dead Bug — supine 90/90 tabletop, then opposite arm & leg extend away.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
SUPINE = (0, -1)
HL = {"abs": 3, "lowerBack": 2}

# Pose 1: start — both arms vertical, hips and knees at 90/90.
s.add(SideFigure(
    pelvis=(300, 505),
    torso=182, head=178,
    upper_arm=92, forearm=92,
    far_upper_arm=98, far_forearm=98,
    thigh=82, shin=-5, foot=30,
    far_thigh=75, far_shin=-10, far_foot=30,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose 2: near arm reaches overhead, far leg extends long; others stay.
s.add(SideFigure(
    pelvis=(770, 505),
    torso=182, head=178,
    upper_arm=168, forearm=168,          # reaching overhead toward the head
    far_upper_arm=95, far_forearm=95,    # other arm stays vertical
    thigh=82, shin=-5, foot=30,          # near leg stays tucked 90/90
    far_thigh=8, far_shin=5, far_foot=35,    # far leg extends low
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(520, 330)
s.arrow((960, 510), (1035, 495), curve=15)
s.arrow((640, 400), (580, 420), curve=-20)

s.save("core_007")
