class StrategyPoint {
  int id;
  float x_mm, y_mm;
  String poiName = null; // nom du POI associé, ou null s'il n'y en a pas

  boolean useAlign = false;
  String compass = "";
  String orientation = ""; // ou "NORTH", "SOUTH", etc.
  int customAngle = 0;          // utilisé si CUSTOM


  StrategyPoint(int id, float x_mm, float y_mm) {
    this.id = id;
    this.x_mm = x_mm;
    this.y_mm = y_mm;

    // initialisation des champs d'alignement
    this.useAlign = false;
    this.compass = "A";
    this.orientation = "CUSTOM";
    this.customAngle = 0;
  }

  void draw(PGraphics pg, float scale) {
    float px = x_mm * scale;
    float py = y_mm * scale;

    if (this == selectedPoint) {
      pg.stroke(255, 0, 0);
      pg.strokeWeight(3);
      pg.fill(255, 200, 200);
    } else {
      pg.fill(255, 0, 0);
      pg.stroke(0);
      pg.strokeWeight(1);
    }

    pg.ellipse(px, py, 18, 18);

    pg.fill(255);
    pg.textAlign(CENTER, CENTER);
    pg.text("P" + id, px, py - 14);
  }



  boolean isHovered(float mouseX, float mouseY, float scale) {
    float px = x_mm * scale;
    float py = y_mm * scale;
    return dist(mouseX, mouseY, px, py) < 10;
  }
}
