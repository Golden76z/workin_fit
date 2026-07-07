# Leg Raises — supine: lying flat with legs extended, then legs raised straight up.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "quads": 2}
SUPINE = (0, -1)  # lying on the back: belly faces up

# Pose A: flat on the back, legs extended just above the floor, arms at sides.
s.add(SideFigure(
    pelvis=(280, 500),
    torso=181, head=178,
    upper_arm=35, forearm=15,
    thigh=3, shin=3, foot=80,
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

# Pose B: legs raised straight up to vertical, back stays on the floor.
s.add(SideFigure(
    pelvis=(790, 500),
    torso=181, head=178,
    upper_arm=35, forearm=15,
    thigh=88, shin=88, foot=145,
    facing=1, front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(545, 410)
# legs sweep up from horizontal to vertical
s.arrow((960, 470), (900, 300), curve=-45)

s.save("legs_017")
