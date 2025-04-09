import controlP5.*;

ControlP5 cp5;

StrategyPoint selected = null;

Textlabel labelInfo;

Textfield fieldX, fieldY;
boolean updatingFromGUI = false;

Toggle toggleAddEnabled;
boolean addPointEnabled = true;

Toggle toggleShowOverlay;

int lastAutoSave = 0;
int autoSaveInterval = 60 * 1000; // xx seconds

public class StrategyEditorGUI extends PApplet {

  StrategyEditor mainApp;

  public void settings() {
    size(400, 600);
  }

  public void setup() {
    surface.setTitle("StrategyEditor - GUI");
    cp5 = new ControlP5(this);

    labelInfo = cp5.addTextlabel("labelInfo")
      .setText("No point selected")
      .setPosition(20, 40)
      .setSize(360, 100)
      .setColorValue(color(0, 102, 153));

    fieldX = cp5.addTextfield("x_mm")
      .setPosition(20, 160)
      .setSize(100, 30)
      .setAutoClear(false)
      .setLabel("X (mm)")
      .setText("0.0");
    fieldX.getCaptionLabel().setColor(color(0, 102, 153));

    fieldY = cp5.addTextfield("y_mm")
      .setPosition(140, 160)
      .setSize(100, 30)
      .setAutoClear(false)
      .setLabel("Y (mm)")
      .setText("0.0");
    fieldY.getCaptionLabel().setColor(color(0, 102, 153));

    toggleAddEnabled = cp5.addToggle("addPointEnabled")
      .setPosition(20, 220)
      .setSize(20, 20)
      .setLabel("Add points enabled")
      .setValue(true);
    toggleAddEnabled.getCaptionLabel().setColor(color(0, 102, 153));

    cp5.addButton("saveStrategy")
      .setLabel("Save strategy")
      .setPosition(20, 280)
      .setSize(120, 30);
    cp5.addButton("loadStrategy")
      .setLabel("Load strategy")
      .setPosition(160, 280)
      .setSize(120, 30);

    cp5.addButton("resetStrategy")
      .setLabel("Reset strategy")
      .setPosition(20, 330)
      .setSize(120, 30);

    cp5.addButton("selectPrevPoint")
      .setLabel("Previous point")
      .setPosition(20, 380)
      .setSize(120, 30);

    cp5.addButton("selectNextPoint")
      .setLabel("Next point")
      .setPosition(160, 380)
      .setSize(120, 30);
    cp5.addButton("startSimulation")
      .setLabel("Start simulation")
      .setPosition(20, 430)
      .setSize(120, 30);
    toggleShowOverlay = cp5.addToggle("showOverlay")
      .setPosition(20, 530)
      .setSize(20, 20)
      .setValue(false)
      .setLabel("Show table overlay");
    toggleShowOverlay.getCaptionLabel().setColor(color(0, 102, 153));
  }

  public void draw() {
    background(220);

    if (millis() - lastAutoSave > autoSaveInterval) {
      println("auto-save triggered");
      savePointsToFile("strategy_temp.json");
      lastAutoSave = millis();
    }
  }

  public void setSelectedPoint(StrategyPoint p) {
    selected = p;

    if (selected != null) {
      updatingFromGUI = true;

      labelInfo.setText(
        "Point P" + selected.id +
        "\nX: " + nf(selected.x_mm, 0, 1) + " mm" +
        "\nY: " + nf(selected.y_mm, 0, 1) + " mm"
        );

      fieldX.setText(nf(selected.x_mm, 0, 1));
      fieldY.setText(nf(selected.y_mm, 0, 1));

      updatingFromGUI = false;
    } else {
      labelInfo.setText("No point selected");
      fieldX.setText("");
      fieldY.setText("");
    }
  }

  public void controlEvent(ControlEvent e) {
    if (updatingFromGUI) return;

    if (e.getName().equals("addPointEnabled")) {
      addPointEnabled = e.getValue() == 1;
      println("[GUI] Add point: " + (addPointEnabled ? "enabled" : "disabled"));
      toggleAddEnabled.setLabel(addPointEnabled ? "Add points enabled" : "Add points disabled");
    }

    if (selected != null) {
      if (e.getName().equals("x_mm")) {
        try {
          float newX = Float.parseFloat(e.getStringValue());
          selected.x_mm = constrain(newX, 0, 3000);
        }
        catch (Exception ex) {
          println("[GUI] Invalid X value");
        }
      }

      if (e.getName().equals("y_mm")) {
        try {
          float newY = Float.parseFloat(e.getStringValue());
          selected.y_mm = constrain(newY, 0, 2000);
        }
        catch (Exception ex) {
          println("[GUI] Invalid Y value");
        }
      }
      setSelectedPoint(selected);
    }
  }

  public boolean isAddPointEnabled() {
    return addPointEnabled;
  }


  public void saveStrategy() {
    // 1. Save temp file
    savePointsToFile("strategy_temp.json");

    // 2. Prompt for custom location
    selectOutput("Save strategy to...", "saveStrategyToFile");
  }

  public void saveStrategyToFile(File selection) {
    if (selection == null) {
      println("[GUI] Save cancelled.");
      return;
    }

    String path = selection.getAbsolutePath();
    if (!path.toLowerCase().endsWith(".json")) {
      path += ".json";
    }

    savePointsToFile(path);
    println("[GUI] Strategy saved to: " + path);
  }


  public void savePointsToFile(String path) {
    JSONObject data = exportPointsToJSON();

    // Si c'est un chemin absolu (ex: vient de selectOutput), on le garde tel quel
    if (path.startsWith("/") || path.contains(":")) {
      saveJSONObject(data, path);
    } else {
      // Sinon, on utilise le chemin relatif depuis le sketch
      saveJSONObject(data, mainApp.getDataPath(path));
    }
  }



  public JSONObject exportPointsToJSON() {
    JSONObject data = new JSONObject();
    JSONArray list = new JSONArray();

    for (StrategyPoint p : StrategyEditor.points) {  // <- accès statique à la liste
      JSONObject entry = new JSONObject();
      entry.setInt("id", p.id);
      entry.setFloat("x_mm", p.x_mm);
      entry.setFloat("y_mm", p.y_mm);
      list.append(entry);
    }

    data.setJSONArray("strategy", list);
    return data;
  }

  public void setMainApp(StrategyEditor app) {
    this.mainApp = app;
  }

  public void loadStrategy() {
    selectInput("Select a strategy file to load...", "loadStrategyFromFile");
  }

  public void loadStrategyFromFile(File selection) {
    if (selection == null) {
      println("[GUI] Load cancelled.");
      return;
    }

    String path = selection.getAbsolutePath();

    JSONObject data = loadJSONObject(path);
    JSONArray list = data.getJSONArray("strategy");

    StrategyEditor.points.clear();

    for (int i = 0; i < list.size(); i++) {
      JSONObject entry = list.getJSONObject(i);
      int id = entry.getInt("id");
      float x = entry.getFloat("x_mm");
      float y = entry.getFloat("y_mm");
      StrategyEditor.points.add(new StrategyPoint(id, x, y));
    }

    mainApp.renumerotePoints();
    println("[GUI] Loaded " + StrategyEditor.points.size() + " points from: " + path);
  }

  public void resetStrategy() {
    int confirm = javax.swing.JOptionPane.showConfirmDialog(null,
      "Are you sure you want to delete all points?",
      "Confirm Reset",
      javax.swing.JOptionPane.YES_NO_OPTION);

    if (confirm == javax.swing.JOptionPane.YES_OPTION) {
      StrategyEditor.points.clear();
      mainApp.renumerotePoints();
      setSelectedPoint(null);
      println("[GUI] Strategy reset.");
    } else {
      println("[GUI] Reset cancelled.");
    }
  }

  public void selectPrevPoint() {
    if (StrategyEditor.points.size() == 0) return;

    if (selected == null) {
      selected = StrategyEditor.points.get(0);
    } else {
      int index = StrategyEditor.points.indexOf(selected);
      if (index > 0) {
        selected = StrategyEditor.points.get(index - 1);
      }
    }

    setSelectedPoint(selected);
    StrategyEditor.selectedPoint = selected;
  }


  public void selectNextPoint() {
    if (StrategyEditor.points.size() == 0) return;
    if (selected == null) {
      selected = StrategyEditor.points.get(0);
    } else {
      int index = StrategyEditor.points.indexOf(selected);
      if (index < StrategyEditor.points.size() - 1) {
        selected = StrategyEditor.points.get(index + 1);
      }
    }
    setSelectedPoint(selected);
    StrategyEditor.selectedPoint = selected;
  }

  public void startSimulation() {
    if (StrategyEditor.points.size() >= 2) {
      StrategyEditor.currentSegment = 0;
      StrategyEditor.t = 0.0;
      StrategyEditor.robotPos = new PVector(
        StrategyEditor.points.get(0).x_mm,
        StrategyEditor.points.get(0).y_mm
        );
      StrategyEditor.isSimulating = true;
      println("[GUI] Simulation started.");
    } else {
      println("[GUI] Not enough points to simulate.");
    }
  }

  public void showOverlay(boolean val) {
    showOverlay = val;
  }
}
