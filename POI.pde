class POI {
  String name;
  float x, y;

  POI(String name, float x, float y) {
    this.name = name;
    this.x = x;
    this.y = y;
  }

  void draw(PGraphics pg, float scale) {
    float px = x * scale;
    float py = y * scale;

    pg.fill(255, 200, 0);       // jaune
    pg.stroke(0);
    pg.strokeWeight(1);
    pg.ellipse(px, py, 22, 22); // ✅ un peu plus gros que les StrategyPoint

    pg.fill(255);               // ✅ texte en blanc
    pg.textAlign(CENTER, CENTER);
    pg.text(name, px, py - 16);
  }
}
