# Full Body Mobility Flow — overhead reach stretch flowing into a forward fold.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

# Pose A: standing overhead reach, slight extension back through the spine.
s.add(SideFigure(
    pelvis=(290, 380),
    torso=95, head=100,
    upper_arm=105, forearm=110,
    thigh=-90, shin=-90, foot=0,
))

# Pose B: crescent lunge — front leg bent, rear leg extended back with the
# ball of the foot planted (heel up), arms reaching up.
s.add(SideFigure(
    pelvis=(790, 440),
    torso=92, head=95,
    upper_arm=100, forearm=105,
    thigh=-15, shin=-80, foot=0,
    far_thigh=-135, far_shin=-163, far_foot=-52,
))

s.chevrons(520, 280)
s.arrow((620, 200), (690, 330), curve=45)

s.pulse_icon()
s.save("rest_003")
