# Hollow Rock — hollow body position, rocking forward and back.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3, "lowerBack": 2}
SUPINE = (0, -1)

# Pose A: rocked back — shoulders low, legs high.
s.add(SideFigure(
    pelvis=(300, 500),
    torso=176, head=150,
    upper_arm=168, forearm=170,
    thigh=22, shin=20, foot=12,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose B: rocked forward — shoulders higher, legs lower.
s.add(SideFigure(
    pelvis=(760, 500),
    torso=160, head=132,
    upper_arm=152, forearm=155,
    thigh=8, shin=6, foot=-2,
    front_hint=SUPINE,
    highlights=HL,
))

s.chevrons(540, 330)
# rocking motion: feet end oscillates down and back up
s.arrow((995, 400), (995, 470))
s.arrow((1040, 470), (1040, 400))

s.save("core_027")
