# Y-T-W Raises — side view, prone series: Y position (arms overhead) then
# W position (elbows bent and squeezed back), chest slightly lifted.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2}
PRONE = (0, 1)

# Pose A: Y — straight arms raised overhead-forward.
s.add(SideFigure(
    pelvis=(300, 505),
    torso=8, head=18,
    upper_arm=25, forearm=27,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

# Pose B: W — elbows bent, pulled back and lifted.
s.add(SideFigure(
    pelvis=(760, 505),
    torso=8, head=18,
    upper_arm=155, forearm=48,
    thigh=184, shin=182, foot=190,
    front_hint=PRONE,
    highlights=HL,
))

s.chevrons(545, 350)
# arms swing from overhead Y down/back into the bent W
s.arrow((1005, 430), (935, 425), curve=45)

s.save("pull_004")
