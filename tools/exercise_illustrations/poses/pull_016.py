# Australian Pull-up — horizontal row under a low bar, heels on the ground.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

SUPINE = (0, -1)
HL = {"back": 3, "biceps": 2}
BAR_Y = 352

# Pose A: straight-arm hang under the bar — body rigid on a shallow incline,
# only the heels touch the ground, hands gripping the bar (snap disabled so the
# figure hangs instead of being dropped to the floor).
fa = SideFigure(
    pelvis=(380, 503),
    torso=170, head=175,
    upper_arm=92, forearm=90,
    thigh=-13, shin=-13, foot=55,
    front_hint=SUPINE,
    snap=False,
    highlights=HL,
)
s.add(fa)

# Pose B: elbows bent, chest pulled up to the bar.
fb = SideFigure(
    pelvis=(770, 468),
    torso=137, head=155,
    upper_arm=-70, forearm=50,
    thigh=-50, shin=-50, foot=52,
    front_hint=SUPINE,
    highlights=HL,
)
s.add(fb)
print("A hand:", fa.j["hand"], " B hand:", fb.j["hand"])
print("B joints:", {k: (round(v[0]), round(v[1])) for k, v in fb.j.items()})

s.bar(BAR_Y, 120, 500, posts=True)
s.bar(BAR_Y, 620, 1000, posts=True)

s.chevrons(545, 200)
# chest pulls up toward the bar
s.arrow((945, 445), (945, 370))

s.save("pull_016")
