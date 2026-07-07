# Chin-Up Negative — top of chin-up (elbows tight, chin over bar), lower slowly to a hang.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"biceps": 3, "back": 2, "forearms": 2}
BAR_Y = 140

s.bar(BAR_Y, 120, 960)

# Pose A: top position, elbows tucked close to the ribs (underhand grip).
a = SideFigure(
    pelvis=(300, 245),
    torso=88, head=80,
    upper_arm=-40, forearm=50,
    thigh=-98, shin=-145, foot=-60,
    snap=False, scale=0.95,
    highlights=HL,
)
s.add(a)
print("A hand:", a.j["hand"])

# Pose B: lowered slowly under control into a straight-arm hang.
b = SideFigure(
    pelvis=(770, 356),
    torso=88, head=78,
    upper_arm=104, forearm=97,
    thigh=-92, shin=-110, foot=-60,
    snap=False, scale=0.95,
    highlights=HL,
)
s.add(b)
print("B hand:", b.j["hand"])

s.chevrons(540, 300)
# Slow lowering cue: downward arrow beside pose B.
s.arrow((930, 250), (930, 420))

s.save("pull_024")
