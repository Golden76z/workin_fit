# Pull-up Negative — step up to the top (chin over bar), then lower slowly to a hang.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "biceps": 2}
BAR_Y = 140

s.bar(BAR_Y, 120, 960)

# Pose A: top position, chin over the bar, elbows bent down.
a = SideFigure(
    pelvis=(300, 250),
    torso=88, head=80,
    upper_arm=-35, forearm=52,
    thigh=-100, shin=-150, foot=-60,
    snap=False, scale=0.95,
    highlights=HL,
)
s.add(a)
print("A hand:", a.j["hand"], "A toe:", a.j["toe"])

# Chair used to step up to the top position.
s.box(215, 440, 120, 108)

# Pose B: lowered slowly into a full dead hang.
b = SideFigure(
    pelvis=(770, 356),
    torso=88, head=78,
    upper_arm=104, forearm=97,
    thigh=-95, shin=-120, foot=-60,
    snap=False, scale=0.95,
    highlights=HL,
)
s.add(b)
print("B hand:", b.j["hand"])

s.chevrons(540, 300)
# Slow lowering cue: downward arrow beside pose B.
s.arrow((930, 250), (930, 420))

s.save("pull_017")
