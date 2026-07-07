# Easy Jog / Brisk Walk — two stride poses of a relaxed jog, moving right.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

# Pose A: front foot planted, rear leg trailing with heel lifted.
s.add(SideFigure(
    pelvis=(280, 380),
    torso=83, head=85,
    upper_arm=-72, forearm=30,          # near arm swings forward, elbow bent
    far_upper_arm=-115, far_forearm=-165,  # far arm swings back
    thigh=-70, shin=-85, foot=-5,       # near leg striding forward
    far_thigh=-115, far_shin=165, far_foot=-150,  # rear leg bent, heel up
))

# Pose B: opposite stride — far leg planted flat, near leg trailing bent.
s.add(SideFigure(
    pelvis=(760, 370),
    torso=82, head=84,
    upper_arm=-118, forearm=-170,       # near arm now swinging back
    far_upper_arm=-58, far_forearm=28,  # far arm forward
    thigh=-118, shin=160, foot=-155,    # near leg trailing bent
    far_thigh=-62, far_shin=-100, far_foot=-15,   # far leg planted, support
))

s.chevrons(520, 300)
s.arrow((880, 260), (980, 260))   # motion direction: forward

s.pulse_icon()
s.save("rest_002")
