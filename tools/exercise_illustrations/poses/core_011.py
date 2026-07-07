# Toe Touches — side view: supine with legs vertical, crunch up reaching toes.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3}
SUPINE = (0, -1)

# Pose A: on the back, legs straight up, arms pointing up (not yet reaching).
s.add(SideFigure(
    pelvis=(300, 500),
    torso=178, head=175,
    upper_arm=82, forearm=82,
    thigh=88, shin=86, foot=70,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose B: shoulders curled off the floor, hands reaching toward the toes.
s.add(SideFigure(
    pelvis=(790, 500),
    torso=160, head=125,
    upper_arm=74, forearm=72,
    thigh=88, shin=86, foot=70,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(545, 300)
# hands travel up toward the toes
s.arrow((655, 385), (718, 300), curve=-22)

s.save("core_011")
