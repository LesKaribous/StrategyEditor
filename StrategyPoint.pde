class StrategyPoint {
  int id;
  float x_mm, y_mm;

  StrategyPoint(int id, float x_mm, float y_mm) {
    this.id = id;
    this.x_mm = x_mm;
    this.y_mm = y_mm;
  }

  void draw(PGraphics pg, float scale) {
    float px = x_mm * scale;
    float py = y_mm * scale;

    if (this == selectedPoint) {
      pg.stroke(255, 0, 0);       // contour rouge
      pg.strokeWeight(3);
      pg.fill(255, 200, 200);
    } else {
      pg.fill(255, 0, 0);
      pg.stroke(0);
      pg.strokeWeight(1);
    }

    pg.ellipse(px, py, 18, 18);   // ✅ plus grand qu'avant

    pg.fill(255);                 // ✅ texte en blanc
    pg.textAlign(CENTER, CENTER);
    pg.text("P" + id, px, py - 14);
  }



  boolean isHovered(float mouseX, float mouseY, float scale) {
    float px = x_mm * scale;
    float py = y_mm * scale;
    return dist(mouseX, mouseY, px, py) < 10;
  }
}
