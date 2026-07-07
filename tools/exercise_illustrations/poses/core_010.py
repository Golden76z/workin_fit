# V-Ups — side view: lying flat with arms overhead, then folded into a V.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"abs": 3}
SUPINE = (0, -1)

# Pose A: flat on the back, arms extended overhead, legs straight.
s.add(SideFigure(
    pelvis=(310, 500),
    torso=176, head=173,
    upper_arm=170, forearm=173,
    thigh=4, shin=2, foot=55,
    front_hint=SUPINE,
    highlights=HL,
))

# Pose B: V position — torso and straight legs both up, hands reach the toes.
s.add(SideFigure(
    pelvis=(790, 500),
    torso=122, head=105,
    upper_arm=30, forearm=25,
    thigh=48, shin=46, foot=40,
    front_hint=(1, -0.4),
    highlights=HL,
))

s.chevrons(555, 300)
# torso swings up, legs swing up — they meet at the top
s.arrow((660, 420), (720, 300), curve=-30)
s.arrow((960, 430), (930, 320), curve=30)

s.save("core_010")
