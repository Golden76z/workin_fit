# Wall Push-up — standing, hands on the wall, lean in and press back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2}

# Pose A: arms extended against the wall, body straight with a slight lean.
fA = s.add(SideFigure(
    pelvis=(260, 370),
    torso=80, head=82,
    upper_arm=-8, forearm=-4,
    thigh=-99, shin=-97, foot=0,
    highlights=HL,
))
s.wall(422)

# Pose B: elbows bent, chest close to the wall.
fB = s.add(SideFigure(
    pelvis=(740, 370),
    torso=72, head=76,
    upper_arm=-130, forearm=8,
    thigh=-103, shin=-101, foot=0,
    highlights=HL,
))
s.wall(813)

s.chevrons(540, 280)
s.arrow((640, 300), (700, 300))   # lean toward the wall

s.save("push_007")
