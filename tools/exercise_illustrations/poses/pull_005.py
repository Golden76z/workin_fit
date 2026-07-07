# Wall Angels — side view: back against a wall, arms slide from a bent "W"
# at shoulder height up to full extension overhead, staying on the wall.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"back": 3, "shoulders": 2}

# Pose A: elbows bent, upper arms back against the wall, forearms up.
s.wall(258)
f1 = SideFigure(
    pelvis=(300, 370),
    torso=90, head=88,
    upper_arm=225, forearm=85,
    thigh=-88, shin=-90, foot=0,
    highlights=HL,
)
s.add(f1)

# Pose B: arms extended overhead, hands sliding up the wall.
s.wall(748)
f2 = SideFigure(
    pelvis=(790, 370),
    torso=90, head=88,
    upper_arm=100, forearm=98,
    thigh=-88, shin=-90, foot=0,
    highlights=HL,
)
s.add(f2)
print("A elbow", f1.j["elbow"], "A hand", f1.j["hand"])
print("B elbow", f2.j["elbow"], "B hand", f2.j["hand"])

s.chevrons(535, 250)
# hands slide upward along the wall
s.arrow((700, 260), (700, 140))

s.save("pull_005")
