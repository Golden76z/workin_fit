# Meditation & Deep Breathing — one centered seated cross-legged pose (hold).
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

# Seated cross-legged, upright torso, hands resting on knees.
f = SideFigure(
    pelvis=(520, 470),
    torso=90, head=90,
    upper_arm=-70, forearm=-15,
    thigh=24, shin=208, foot=185,
    far_thigh=30, far_shin=214, far_foot=190,
    scale=1.25,
)
s.add(f)

# Gentle breathing hint: small arrows in front of the chest (inhale up / exhale down).
s.arrow((415, 320), (415, 265), curve=-12)
s.arrow((380, 275), (380, 330), curve=12)

s.pulse_icon()
s.save("rest_001")
