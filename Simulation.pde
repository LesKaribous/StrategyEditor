public static PVector robotPos;
public static int currentSegment = 0;
public static float t = 0.0;
public static float speed = 0.02;
public static boolean isSimulating = false;

public static float robotWidth_mm = 287;
public static float robotHeight_mm = 284;
public static float robotHitbox_mm = 400;



PImage robotImg;


void updateSimulation() {
  if (!isSimulating || StrategyEditor.points.size() < 2) return;

  if (currentSegment >= StrategyEditor.points.size() - 1) {
    isSimulating = false;
    println("[SIM] End of path");
    return;
  }

  StrategyPoint p1 = StrategyEditor.points.get(currentSegment);
  StrategyPoint p2 = StrategyEditor.points.get(currentSegment + 1);

  float easedT = easeInOut(t);
  float x = lerp(p1.x_mm, p2.x_mm, easedT);
  float y = lerp(p1.y_mm, p2.y_mm, easedT);

  robotPos.set(x, y);

  t += speed;
  if (t >= 1.0) {
    t = 0.0;
    currentSegment++;
  }
}

void drawRobot(PGraphics pg, float scale) {
  if (!isSimulating || robotPos == null) return;

  float robotWidth_px = robotWidth_mm * StrategyEditor.mmToPx;
  float robotHeight_px = robotHeight_mm * StrategyEditor.mmToPx;
  float hitbox_px = robotHitbox_mm * StrategyEditor.mmToPx;

  float px = robotPos.x * scale;
  float py = robotPos.y * scale;

  pg.pushMatrix();
  pg.pushStyle();
  pg.translate(px, py);
  pg.imageMode(CENTER);

  pg.fill(255, 0, 0, 127);
  pg.stroke(255, 0, 0);
  pg.ellipse(0, 0, hitbox_px, hitbox_px);

  pg.image(robotImg, 0, 0, robotWidth_px, robotHeight_px);

  pg.popStyle();
  pg.popMatrix();
}



float easeInOut(float t) {
  return t * t * (3 - 2 * t);  // interpolation douce entre 0 et 1
}
