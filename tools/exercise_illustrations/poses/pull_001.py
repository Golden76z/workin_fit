# Inverted Row — side view: hanging under a low bar/table edge with arms
# extended, then chest pulled up to the edge; hands stay on the bar, heels
# stay planted, body rises only to a modest incline.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "biceps": 2}
SUPINE = (0, -1)

# Pose A: arms straight up to the bar, body just off the floor, heels grounded.
f1 = SideFigure(
    pelvis=(280, 480),
    torso=12, head=12,
    upper_arm=90, forearm=90,
    thigh=192, shin=192, foot=95,
    front_hint=SUPINE,
    highlights=HL,
)
h1 = f1.j["hand"]
s.bar(h1[1], h1[0] - 70, h1[0] + 150)
s.add(f1)

# Pose B: hands still on the bar (same height), elbows bent behind the torso,
# chest raised to the edge, heels still the pivot on the ground.
f2 = SideFigure(
    pelvis=(760, 480),
    torso=29, head=31,
    upper_arm=-175, forearm=66,
    thigh=209, shin=209, foot=109,
    front_hint=SUPINE,
    highlights=HL,
)
h2 = f2.j["hand"]
s.bar(h1[1], h2[0] - 70, h2[0] + 150)
s.add(f2)

print("bar y", h1[1], "A hand", h1, "B hand", h2)
print("A ankle", f1.j["ankle"], "B ankle", f2.j["ankle"])

s.chevrons(535, 200)
# motion cue: chest rises toward the bar
s.arrow((1035, 430), (1035, 330))

s.save("pull_001")
