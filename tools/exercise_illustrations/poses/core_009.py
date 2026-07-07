# Hollow Body Hold — side view: single supine hold, shoulders + legs lifted.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
SUPINE = (0, -1)

# Lying on the back, head to the left; lower back pressed down (pelvis lowest),
# shoulders curled up, legs straight and lifted ~20 deg, arms overhead by the ears.
s.add(SideFigure(
    pelvis=(500, 500),
    torso=168, head=135,
    upper_arm=160, forearm=163,
    thigh=17, shin=15, foot=8,
    front_hint=SUPINE,
    scale=1.25,
    highlights={"abs": 3},
))

# Effort hints: legs and shoulders both held up.
s.arrow((820, 470), (835, 400), curve=-14)
s.arrow((215, 430), (240, 365), curve=16)

s.save("core_009")
