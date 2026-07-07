# Tricep Dips — side view, hands on a chair behind the body:
# arms straight at the top, then hips lowered with elbows bending back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"triceps": 3, "shoulders": 2, "chest": 2}

# Pose A: top — arms straight down onto the chair edge, legs extended, heels down.
a = SideFigure(
    pelvis=(300, 420),
    torso=80, head=85,
    upper_arm=-106, forearm=-102,
    far_upper_arm=-94, far_forearm=-92,
    thigh=-42, shin=-55, foot=55,
    highlights=HL,
)
s.add(a)
ax, ay = a.j["hand"]
s.box(ax - 78, ay + 9, 100, 548 - (ay + 9))

# Pose B: bottom — hips dropped, elbows bent pointing back.
b = SideFigure(
    pelvis=(790, 500),
    torso=80, head=85,
    upper_arm=163, forearm=-78,
    far_upper_arm=150, far_forearm=-70,
    thigh=-12, shin=-10, foot=55,
    highlights=HL,
)
s.add(b)
bx, by = b.j["hand"]
s.box(bx - 78, by + 9, 100, 548 - (by + 9))

s.chevrons(530, 250)
# lower, then press back up
s.arrow((1000, 330), (1000, 430))
s.arrow((1040, 430), (1040, 330))

s.save("push_013")
