# Shadow Boxing — side view: guard stance, then jab extended forward.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"shoulders": 3, "triceps": 2}

# Pose A: boxing guard — knees soft, fists up by the chin.
s.add(SideFigure(
    pelvis=(280, 380),
    torso=82, head=80,
    upper_arm=-55, forearm=62,
    far_upper_arm=-48, far_forearm=55,
    thigh=-80, shin=-95, foot=5,
    far_thigh=-102, far_shin=-85, far_foot=-5,
    highlights=HL,
))

# Pose B: jab — near arm fully extended, rear fist stays in guard.
s.add(SideFigure(
    pelvis=(720, 385),
    torso=75, head=72,
    upper_arm=8, forearm=6,
    far_upper_arm=-50, far_forearm=58,
    thigh=-72, shin=-98, foot=5,
    far_thigh=-108, far_shin=-82, far_foot=-5,
    highlights=HL,
))

s.chevrons(505, 290)
# punch shoots straight forward from the fist
s.arrow((905, 262), (1015, 260), curve=0)

s.pulse_icon()
s.save("cardio_009")
