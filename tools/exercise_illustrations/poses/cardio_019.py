# Boxer Shuffle — front view: hands in guard, rapid weight shifts side to side
# on the balls of the feet.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, FrontFigure

s = Scene()
HL = {"calves": 3, "shoulders": 2}

# Pose A: weight shifted onto the viewer-left leg, other foot light on the toe.
s.add(FrontFigure(
    pelvis=(300, 375),
    torso=98,
    l_upper_arm=-115, l_forearm=100,
    r_upper_arm=-65, r_forearm=80,
    l_thigh=-97, l_shin=-93,
    r_thigh=-66, r_shin=-80,
    highlights=HL,
))

# Pose B: weight shifted onto the viewer-right leg (mirror).
s.add(FrontFigure(
    pelvis=(770, 375),
    torso=82,
    l_upper_arm=-115, l_forearm=100,
    r_upper_arm=-65, r_forearm=80,
    l_thigh=-114, l_shin=-100,
    r_thigh=-83, r_shin=-87,
    highlights=HL,
))

s.chevrons(520, 300)
# side-to-side weight shift
s.arrow((205, 440), (135, 440))
s.arrow((865, 440), (935, 440))

s.pulse_icon()
s.save("cardio_019")
