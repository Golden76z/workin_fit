# Jumping Jacks — front view: feet together arms down, then star position.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"shoulders": 3, "calves": 2}

# Pose A: standing, feet together, arms at sides.
s.add(FrontFigure(
    pelvis=(300, 370),
    l_upper_arm=-108, l_forearm=-100,
    r_upper_arm=-72, r_forearm=-80,
    l_thigh=-92, l_shin=-90,
    r_thigh=-88, r_shin=-90,
    highlights=HL,
))

# Pose B: arms overhead, legs apart.
s.add(FrontFigure(
    pelvis=(770, 370),
    l_upper_arm=125, l_forearm=105,
    r_upper_arm=55, r_forearm=75,
    l_thigh=-115, l_shin=-108,
    r_thigh=-65, r_shin=-72,
    highlights=HL,
))

s.chevrons(535, 300)
# arms swing up on both sides of pose B
s.arrow((640, 330), (690, 160), curve=-45)
s.arrow((900, 330), (850, 160), curve=45)

s.pulse_icon()
s.save("cardio_001")
