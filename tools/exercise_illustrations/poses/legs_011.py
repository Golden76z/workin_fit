# Single Leg Calf Raise — side view: one leg flat, then risen onto the toes;
# the other leg is bent with the foot lifted behind.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"calves": 3}

# Pose A: standing on one flat foot, free leg bent behind.
s.add(SideFigure(
    pelvis=(300, 370),
    torso=90, upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,
    far_thigh=-88, far_shin=-170, far_foot=-95,
    highlights=HL,
))

# Pose B: risen onto the toes of the standing leg.
s.add(SideFigure(
    pelvis=(770, 370),
    torso=90, upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=-58,
    far_thigh=-88, far_shin=-170, far_foot=-95,
    highlights=HL,
))

s.chevrons(520, 260)
s.arrow((880, 360), (880, 280))
s.arrow((722, 522), (737, 478), curve=-12)

s.save("legs_011")
