# Hindu Push-up — side view: downward-dog pike, swooping into upward-dog.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()
HL = {"chest": 3, "shoulders": 2, "triceps": 2, "back": 2}

# Pose A: pike / downward dog — hips high, hands and feet on the floor.
s.add(SideFigure(
    pelvis=(255, 330),
    torso=-38, head=-50,
    upper_arm=-49, forearm=-49,
    thigh=248, shin=244, foot=-18,
    highlights=HL,
))

# Pose B: upward dog — hips low, chest up, arms straight.
s.add(SideFigure(
    pelvis=(760, 510),
    torso=55, head=72,
    upper_arm=-108, forearm=-92,
    thigh=193, shin=197, foot=-172,
    highlights=HL,
))

s.chevrons(520, 250)
# swooping dive-forward motion
s.arrow((560, 380), (700, 460), curve=-45)

s.save("push_010")
