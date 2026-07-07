# Calf Raise — side view: standing flat, then risen up onto the toes.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"calves": 3}

# Pose A: standing flat on the whole foot.
s.add(SideFigure(
    pelvis=(300, 370),
    torso=90, upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=0,
    highlights=HL,
))

# Pose B: heels lifted, weight on the balls of the feet.
s.add(SideFigure(
    pelvis=(770, 370),
    torso=90, upper_arm=-78, forearm=-74,
    thigh=-90, shin=-90, foot=-58,
    highlights=HL,
))

s.chevrons(520, 260)
# body rises straight up
s.arrow((880, 360), (880, 280))
# heel lifts off the floor
s.arrow((722, 522), (737, 478), curve=-12)

s.save("legs_010")
