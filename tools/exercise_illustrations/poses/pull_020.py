# Close Grip Inverted Row — hang under a low bar, pull up with elbows tucked to the ribs.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "biceps": 2}
SUPINE = (0, -1)

# Pose A: start — body straight incline, arms extended straight up to the bar.
a = SideFigure(
    pelvis=(300, 470),
    torso=24, head=30,
    upper_arm=95, forearm=92,
    thigh=207, shin=203, foot=52,
    front_hint=SUPINE, scale=0.95,
    highlights=HL,
)
s.add(a)
print("A hand:", a.j["hand"])
s.bar(int(a.j["hand"][1]), int(a.j["hand"][0]) - 90, int(a.j["hand"][0]) + 90)

# Pose B: top — chest at the bar, elbows tucked low along the ribs (close grip).
b = SideFigure(
    pelvis=(760, 430),
    torso=48, head=54,
    upper_arm=198, forearm=58,
    thigh=228, shin=224, foot=70,
    front_hint=SUPINE, scale=0.95,
    highlights=HL,
)
s.add(b)
print("B hand:", b.j["hand"])
s.bar(int(b.j["hand"][1]), int(b.j["hand"][0]) - 90, int(b.j["hand"][0]) + 90)

s.chevrons(520, 250)
# Pull direction: chest moves up toward the bar.
s.arrow((980, 400), (960, 290), curve=-25)

s.save("pull_020")
