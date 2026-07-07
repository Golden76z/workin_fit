# Butt Kicks — side view running in place, heels kicked up toward the glutes.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"hamstrings": 3}

# Pose A: near heel kicked to glutes, far leg standing.
s.add(SideFigure(
    pelvis=(300, 380),
    torso=92, head=90,
    upper_arm=-125, forearm=-15,
    far_upper_arm=-55, far_forearm=35,
    thigh=-100, shin=120, foot=-155,    # heel folded up close to the glutes
    far_thigh=-90, far_shin=-90, far_foot=0,
    highlights=HL,
))

# Pose B: alternate — far heel to glutes, near leg standing.
s.add(SideFigure(
    pelvis=(770, 380),
    torso=92, head=90,
    upper_arm=-55, forearm=35,
    far_upper_arm=-125, far_forearm=-15,
    thigh=-90, shin=-90, foot=0,
    far_thigh=-100, far_shin=120, far_foot=-155,
    highlights=HL,
))

s.chevrons(520, 290)
# heel kicks up behind pose A
s.arrow((200, 520), (235, 400), curve=35)
# and behind pose B
s.arrow((670, 520), (705, 400), curve=35)

s.pulse_icon()
s.save("cardio_003")
