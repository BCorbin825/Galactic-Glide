// Galactic Glide
// Authors: Brandon Corbin, Caden Trca, Francisco Sanchez, and John Gionti
// File: GalacticGlide.pde
// Description: GalacticGlide.pde is the central component of the "Galactic Glide"
//              game, as it contains all the code necessary to run the 
//              game. It acts as a bridge between the user interface and 
//              the game logic, and handles various tasks such as initializing 
//              the game world, loading game assets, and managing game events.
//
// NOTE: This game requires the below libraries to run. All of them can be downloaded
// from the default library browser (Sketch > Import Library > Manage Libraries...).
//  - ControlP5
//  - Sound
//  - Sprites

final boolean DEBUG = false; // Set in code, displays extra info
boolean ready = false;       // Whether the game is ready
boolean isHardDiff = false;  // Which difficulty the game is set to; false = normal

Game game;
SoundManager sound;
ImageManager images;
MenuScreen menu;

ControlP5 cp5;
String screen;

void setup() {
  size(1000, 800);
  background(loadImage("Sprites/menu_background.png"));
  textFont(createFont("Goudy Stout", 55));
  textAlign(CENTER);
  text("LOADING...", width/2, height/2);
  screen = "main";
  
  cp5 = new ControlP5(this);
  cp5.setUpdate(false);
  cp5.setAutoDraw(false);
  thread("init");
  
  frameRate(60);
}

void draw() {
  if (ready) { // Allow thread init to finish before starting game
    if (screen == "main") {
      menu.display();
    } 
    else if (screen == "settings") {
      menu.displaySettings();
    }
      
    if (game.active) {
      menu.hide();
      game.update();
      game.display();   
    }
  }
}

/**
 * Uses threading to load all assets
 */
void init() {
  images = new ImageManager();
  images.Load("menu_backgrd", "menu_background.png");
  images.Load("game_backgrd", "gameplay_background.png");
  
  game = new Game(this);
  sound = new SoundManager(this);
  menu = new MenuScreen();
  sound.loop("Theme");
  sound.sounds.get("Theme").amp(0.2 * menu.music.getValue()/100);
  
  ready = true;
  cp5.setUpdate(true);
  cp5.setAutoDraw(true);
}

void keyPressed() {
  game.handleKeyPress();
}

void keyReleased() {
  game.handleKeyRelease();
}

/**
 * Handles all cp5 button clicks
 */
void controlEvent(ControlEvent theEvent) {
  if (!ready)
    return;
  
  String eventType = theEvent.getController().getName();
  
  switch (eventType) {
    case("START"): // Start game
      game.startGame();
      sound.playSFX("Button");
      break;
    case("SCORES"): // Show scores
      menu.hide();
      menu.displayScores();
      screen = "scores";
      sound.playSFX("Button");
      break;
    case("EXIT"): // Exit game
      exit();
      sound.playSFX("Button");
      break;
    case("back"): // Go Back
      menu.hideScores();
      menu.hideSettings();
      menu.hideHelp();
      screen = "main";
      sound.playSFX("Button");
      break;
    case("settings"): // Show settings
      menu.hide();
      menu.displaySettings();
      screen = "settings";
      sound.playSFX("Button");
      break;
    case("help"): // Show help
      menu.hide();
      menu.displayHelp();
      screen = "help";
      sound.playSFX("Button");
      break;
    case("resume"): // Close pause menu
      menu.hidePause();
      game.sw.reset();
      game.gameClock.start();
      sound.playSFX("Button");
      break;
    case("restart"): // Restart game
      game.quitGame();
      game = null;
      game = new Game(this);
      game.startGame();
      menu.hidePause();
      sound.playSFX("Button");
      break;
    case("quit"): // Quit game
      game.quitGame();
      game = null;
      game = new Game(this);
      menu.hidePause();
      screen = "main";
      sound.playSFX("Button");
      break;
  }
}
