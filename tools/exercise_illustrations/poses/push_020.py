# Dive Bomber Push-up — downward dog pike, swooping into upward dog.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2, "back": 2}

# Pose A: downward dog — hips high, hands AND feet on the ground.
s.add(SideFigure(
    pelvis=(290, 280),
    torso=-33, head=-43,
    upper_arm=-54, forearm=-54,
    thigh=-112, shin=-106, foot=-10,
    highlights=HL,
))

# Pose B: upward dog — hips low, chest up, arms extended.
s.add(SideFigure(
    pelvis=(760, 500),
    torso=65, head=60,
    upper_arm=-70, forearm=-70,
    thigh=192, shin=196, foot=175,
    highlights=HL,
))

s.chevrons(520, 200)
# swooping dive path near pose B
s.arrow((580, 320), (700, 460), curve=55)

s.save("push_020")
