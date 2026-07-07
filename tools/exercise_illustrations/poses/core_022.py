# Knee Pull-In — seated, leaning back on hands; legs extended, then knees to chest.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3}

# Pose A: leaning back on hands, legs extended, heels hovering.
s.add(SideFigure(
    pelvis=(280, 500),
    torso=115, head=100,
    upper_arm=-135, forearm=-70,
    thigh=8, shin=-6, foot=10,
    highlights=HL,
))

# Pose B: knees pulled in toward the chest.
s.add(SideFigure(
    pelvis=(760, 500),
    torso=103, head=85,
    upper_arm=-135, forearm=-70,
    thigh=55, shin=-58, foot=-10,
    highlights=HL,
))

s.chevrons(520, 300)
# knees travel toward the chest
s.arrow((985, 470), (900, 380), curve=-25)

s.save("core_022")
