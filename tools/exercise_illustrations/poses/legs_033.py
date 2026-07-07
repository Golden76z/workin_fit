# Frog Pump — supine with soles together and knees splayed open,
# hips driven up by the glutes.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"glutes": 3, "hamstrings": 2}
SUPINE = (0, -1)

# Pose A: lying flat on the back, heels close to the pelvis, knees dropped
# open (near knee low, far knee high = the splay), toes up so the soles stay
# level with the back line and the torso rests on the floor.
a = SideFigure(
    pelvis=(300, 520),
    torso=182, head=179,
    upper_arm=40, forearm=20,
    thigh=48, shin=-112, foot=45,
    far_thigh=68, far_shin=-96, far_foot=45,
    facing=1, front_hint=SUPINE,
    highlights=HL,
)
s.add(a)

# Pose B: hips squeezed up; shoulders/head and feet keep floor contact.
b = SideFigure(
    pelvis=(770, 486),
    torso=204, head=170,
    upper_arm=28, forearm=14,
    thigh=22, shin=-105, foot=40,
    far_thigh=45, far_shin=-90, far_foot=40,
    facing=1, front_hint=SUPINE,
    highlights=HL,
)
s.add(b)

s.chevrons(540, 255)
# hips drive straight up
s.arrow((730, 455), (740, 365), curve=-12)

s.save("legs_033")
