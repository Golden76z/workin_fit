# Wide Grip Inverted Row — hang under a low bar with straight arms, pull chest to bar.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2}
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
BAR_A = a.j["hand"]
s.bar(int(BAR_A[1]), int(BAR_A[0]) - 90, int(BAR_A[0]) + 90)

# Pose B: top — chest at the bar, elbows flared wide (appear behind the shoulder).
b = SideFigure(
    pelvis=(760, 430),
    torso=43, head=49,
    upper_arm=177, forearm=50,
    thigh=223, shin=219, foot=66,
    front_hint=SUPINE, scale=0.95,
    highlights=HL,
)
s.add(b)
print("B hand:", b.j["hand"])
BAR_B = b.j["hand"]
s.bar(int(BAR_B[1]), int(BAR_B[0]) - 90, int(BAR_B[0]) + 90)

s.chevrons(520, 250)
# Pull direction: chest moves up toward the bar.
s.arrow((980, 400), (960, 290), curve=-25)

s.save("pull_019")
