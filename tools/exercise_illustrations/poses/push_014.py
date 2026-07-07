# Diamond Tricep Dips — same chair-dip silhouette as push_013 but with the
# hands stacked together (diamond grip): both arms drawn perfectly aligned,
# and a deeper bottom position. Tricep-dominant highlights.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"triceps": 3, "shoulders": 2}

# Pose A: top — arms straight down onto the chair edge, hands together
# (single aligned arm in side view), legs extended, heels down.
a = SideFigure(
    pelvis=(300, 420),
    torso=80, head=85,
    upper_arm=-102, forearm=-100,
    thigh=-42, shin=-55, foot=55,
    highlights=HL,
)
s.add(a)
ax, ay = a.j["hand"]
s.box(ax - 78, ay + 9, 100, 548 - (ay + 9))

# Pose B: bottom — hips dropped deep, elbows bent tight behind the body.
b = SideFigure(
    pelvis=(790, 505),
    torso=78, head=84,
    upper_arm=158, forearm=-80,
    thigh=-10, shin=-8, foot=55,
    highlights=HL,
)
s.add(b)
bx, by = b.j["hand"]
s.box(bx - 78, by + 9, 100, 548 - (by + 9))

s.chevrons(530, 250)
# lower, then press back up
s.arrow((1000, 330), (1000, 430))
s.arrow((1040, 430), (1040, 330))

s.save("push_014")
