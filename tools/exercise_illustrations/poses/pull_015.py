# Doorway Row — grip the door frame, lean back with straight arms, pull chest to frame.
import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
from figure import Scene, SideFigure

s = Scene()

HL = {"back": 3, "biceps": 2}

# Pose A: leaning back, arms extended, hands on the frame.
s.wall(349)
fa = SideFigure(
    pelvis=(255, 380),
    torso=117, head=105,
    upper_arm=-18, forearm=-12,
    thigh=-63, shin=-63, foot=0,
    highlights=HL,
)
s.add(fa)

# Pose B: body pulled upright to the frame, elbows bent back.
s.wall(795)
fb = SideFigure(
    pelvis=(775, 380),
    torso=100, head=95,
    upper_arm=-128, forearm=2,
    thigh=-77, shin=-77, foot=0,
    highlights=HL,
)
s.add(fb)
print("A hand:", fa.j["hand"], " B hand:", fb.j["hand"])

s.chevrons(520, 200)
# pull toward the frame
s.arrow((600, 330), (680, 330))

s.save("pull_015")
