PGraphics terrainView;
StrategyEditorGUI gui;  // accès direct à l’objet GUI
PImage terrainImage;

int nextPointId = 0;
public static ArrayList<StrategyPoint> points = new ArrayList<StrategyPoint>();

public static float mmToPx = 0.4;

public static StrategyPoint selectedPoint = null;
boolean isDragging = false;

ArrayList<POI> pois = new ArrayList<POI>();




void settings() {
  size(1200, 800); // taille de la fenêtre principale
}

void setup() {
  surface.setTitle("StrategyEditor - Terrain View");

  // Lancement de la GUI dans une autre fenêtre
  gui = new StrategyEditorGUI();
  gui.setMainApp(this);
  PApplet.runSketch(new String[] { "GUI" }, gui);


  terrainView = createGraphics(1200, 800); // Surface pour dessiner le terrain
  terrainImage = loadImage("terrain.png");
  robotImg = loadImage("robot.png");
  loadOverlayResources();


  loadPOIs("poi.h");
  debugPrintPOIs();  //affiche les POIs en console
  loadPointsFromFile("strategy_temp.json");
}

void draw() {
  background(220);
  drawTerrain();
  if (isSimulating) updateSimulation();
  
  drawMouseCoordinates(); // affiche les points de la souris
  
}

void drawTerrain() {
  terrainView.beginDraw();
  terrainView.background(255);

  if (terrainImage != null) {
    // On adapte l'image à la taille de la fenêtre (ou de la surface graphique)
    terrainView.image(terrainImage, 0, 0, terrainView.width, terrainView.height);
  } else {
    terrainView.fill(0);
    terrainView.text("Image 'Terrain.png' introuvable", 20, 20);
  }

  drawRobot(terrainView, mmToPx);
  drawPOIs();
  drawPath();    // lignes reliant les points
  drawPoints();  // affichage des points
  
  
  if (showOverlay) {
    // Flou léger
    terrainView.filter(BLUR, 1);

    // Voile gris semi-transparent par-dessus
    terrainView.fill(0, 0, 0, 100);
    terrainView.noStroke();
    terrainView.rect(0, 0, terrainView.width, terrainView.height);
  }

  drawOverlay(terrainView, mmToPx);



  terrainView.endDraw();

  // Affichage sur la fenêtre principale
  image(terrainView, 0, 0);
}

void drawPoints() {
  for (StrategyPoint p : points) {
    p.draw(terrainView, mmToPx);
  }
}






void mousePressed() {
  StrategyPoint clicked = getPointUnderMouse();

  if (mouseButton == LEFT) {
    if (clicked != null) {
      selectedPoint = clicked;
      isDragging = true;
      println("Point sélectionné : P" + clicked.id);
      if (gui != null) gui.setSelectedPoint(selectedPoint);
    } else if (gui == null || gui.isAddPointEnabled()) {
      int insertIndex = getSegmentIndexUnderMouse();
      float x_mm = round(mouseX / mmToPx);
      float y_mm = round(mouseY / mmToPx);

      POI snap = getNearbyPOI(x_mm, y_mm, 50);
      if (snap != null) {
        x_mm = snap.x;
        y_mm = snap.y;
      }

      StrategyPoint newPoint = new StrategyPoint(nextPointId++, x_mm, y_mm);
      if (snap != null) {
        newPoint.poiName = snap.name;
      }

      if (insertIndex != -1) {
        points.add(insertIndex + 1, newPoint);
        renumerotePoints();
        println("Point inséré entre P" + insertIndex + " et P" + (insertIndex + 1));
      } else {
        points.add(newPoint);
      }
    }
  }

  if (mouseButton == RIGHT && clicked != null) {
    points.remove(clicked);
    renumerotePoints();
    println("Point supprimé !");
  }
}



void mouseDragged() {
  if (isDragging && selectedPoint != null) {
    float x_mm = round(constrain(mouseX / mmToPx, 0, 3000));
    float y_mm = round(constrain(mouseY / mmToPx, 0, 2000));

    POI snap = getNearbyPOI(x_mm, y_mm, 50);
    if (snap != null) {
      x_mm = snap.x;
      y_mm = snap.y;
      selectedPoint.poiName = snap.name;
    } else {
      selectedPoint.poiName = null;
    }

    selectedPoint.x_mm = x_mm;
    selectedPoint.y_mm = y_mm;

    if (gui != null) {
      gui.setSelectedPoint(selectedPoint);  // mise à jour dynamique
    }
  }
}



void mouseReleased() {
  isDragging = false;
}



void renumerotePoints() {
  nextPointId = 0;
  for (StrategyPoint p : points) {
    p.id = nextPointId++;
  }
}

StrategyPoint getPointUnderMouse() {
  for (StrategyPoint p : points) {
    if (p.isHovered(mouseX, mouseY, mmToPx)) {
      return p;
    }
  }
  return null;
}

void drawPath() {
  if (points.size() < 2) return;

  terrainView.stroke(0, 100, 255);
  terrainView.strokeWeight(2);

  for (int i = 0; i < points.size() - 1; i++) {
    StrategyPoint p1 = points.get(i);
    StrategyPoint p2 = points.get(i + 1);

    float x1 = p1.x_mm * mmToPx;
    float y1 = p1.y_mm * mmToPx;
    float x2 = p2.x_mm * mmToPx;
    float y2 = p2.y_mm * mmToPx;

    terrainView.line(x1, y1, x2, y2);
    // Dessin de la flèche
    drawArrow(terrainView, x1, y1, x2, y2);
  }
}

void drawArrow(PGraphics pg, float x1, float y1, float x2, float y2) {
  float mx = (x1 + x2) / 2.0;
  float my = (y1 + y2) / 2.0;

  float angle = atan2(y2 - y1, x2 - x1);

  pg.pushMatrix();
  pg.translate(mx, my);
  pg.rotate(angle);

  pg.pushStyle(); // ✅ on sauvegarde les styles actuels
  pg.fill(0, 100, 255);
  pg.noStroke();
  pg.triangle(-12, -6, -12, 6, 0, 0);  // flèche plus grande
  pg.popStyle();  // ✅ on restaure les styles
  pg.popMatrix();
}



int getSegmentIndexUnderMouse() {
  float threshold = 10; // distance max entre clic et ligne

  for (int i = 0; i < points.size() - 1; i++) {
    StrategyPoint p1 = points.get(i);
    StrategyPoint p2 = points.get(i + 1);

    float x1 = p1.x_mm * mmToPx;
    float y1 = p1.y_mm * mmToPx;
    float x2 = p2.x_mm * mmToPx;
    float y2 = p2.y_mm * mmToPx;

    float d = distToSegment(mouseX, mouseY, x1, y1, x2, y2);
    if (d < threshold) return i;
  }

  return -1;
}

float distToSegment(float px, float py, float x1, float y1, float x2, float y2) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  if (dx == 0 && dy == 0) return dist(px, py, x1, y1);
  float t = ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy);
  t = constrain(t, 0, 1);
  float projX = x1 + t * dx;
  float projY = y1 + t * dy;
  return dist(px, py, projX, projY);
}

void loadPointsFromFile(String filename) {
  File f = new File(dataPath(filename));
  if (!f.exists()) {
    println("[STRATEGY] File not found: " + filename);
    return;
  }

  JSONObject data = loadJSONObject(dataPath(filename));
  JSONArray list = data.getJSONArray("strategy");

  points.clear();
  for (int i = 0; i < list.size(); i++) {
    JSONObject entry = list.getJSONObject(i);
    int id = entry.getInt("id");
    float x = entry.getFloat("x_mm");
    float y = entry.getFloat("y_mm");
    points.add(new StrategyPoint(id, x, y));
  }

  renumerotePoints();
  println("[STRATEGY] Loaded " + points.size() + " points from " + filename);
}

public String getDataPath(String filename) {
  return sketchPath("data/" + filename);
}


void loadPOIs(String filename) {
  String[] lines = loadStrings(filename);
  if (lines == null) {
    println("[POI] File not found: " + filename);
    return;
  }

  for (String line : lines) {
    line = line.trim();

    if (line.startsWith("const Vec2")) {
      String[] parts = line.split("=");
      if (parts.length != 2) continue;

      String name = parts[0].replace("const Vec2", "").trim();
      String coord = parts[1].trim();

      // Extrait Vec2(x, y);
      coord = coord.replace("Vec2(", "")
        .replace(");", "")
        .split("//")[0]  // enlève le commentaire éventuel
        .trim();

      String[] coords = coord.split(",");

      if (coords.length == 2) {
        float x = float(trim(coords[0]));
        float y = float(trim(coords[1]));

        pois.add(new POI(name, x, y));
      }
    }
  }

  println("[POI] Loaded " + pois.size() + " POIs from " + filename);
}

void drawPOIs() {
  for (POI p : pois) {
    p.draw(terrainView, mmToPx);
  }
}

void debugPrintPOIs() {
  println("[POI] List of loaded points:");
  for (POI p : pois) {
    println("- " + p.name + " = (" + p.x + ", " + p.y + ")");
  }
}

POI getNearbyPOI(float x_mm, float y_mm, float tolerance_mm) {
  for (POI poi : pois) {
    if (dist(x_mm, y_mm, poi.x, poi.y) <= tolerance_mm) {
      return poi;
    }
  }
  return null;
}

void drawMouseCoordinates() {
  float x_mm = round(mouseX / mmToPx);
  float y_mm = round(mouseY / mmToPx);

  fill(255);
  stroke(0);
  strokeWeight(1);
  rect(10, height - 30, 190, 20);

  fill(0);
  textAlign(LEFT, CENTER);
  textFont(createFont("Arial", 12));
  text("X: " + int(x_mm) + " mm   Y: " + int(y_mm) + " mm", 15, height - 20);
}
