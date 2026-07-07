# Bodyweight Good Morning — standing with hands behind head, hinge at the hips, flat back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"hamstrings": 3, "lowerBack": 2, "glutes": 2}

# Pose A: standing tall, hands behind the head.
a = SideFigure(
    pelvis=(300, 370),
    torso=90, head=88,
    upper_arm=38, forearm=176,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
)
s.add(a)
print("A hand:", a.j["hand"], "head:", a.j.get("head", None))

# Pose B: hinged forward at the hips, back flat, knees soft, hips pushed back.
b = SideFigure(
    pelvis=(760, 380),
    torso=15, head=22,
    upper_arm=-35, forearm=90,
    thigh=-78, shin=-95, foot=0,
    highlights=HL,
)
s.add(b)
print("B hand:", b.j["hand"])

s.chevrons(520, 260)
# Torso hinges forward and down.
s.arrow((950, 260), (1000, 360), curve=-30)

s.save("pull_022")
