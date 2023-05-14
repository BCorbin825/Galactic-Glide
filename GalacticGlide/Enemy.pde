// Galactic Glide
// Authors: Brandon Corbin, Caden Trca, Francisco Sanchez, and John Gionti
// File: Enemy.pde
// Description: Enemy.pde extends the Entity class and defines how enemy
//              ships spawn and behave.

class Enemy extends Entity {
  boolean patrol;     // Used to tell boss's when to patrol
  int timeSinceShoot; // Tracks the last time the enemy has shot
  Clock exhaustClock; // Used for exhaust animation
  int frame;
  
  //-------------------------------- Function: Constructor ---------------------------------//
  /**
   * Creates class object and intializes relevant variables
   */
  Enemy(PApplet app, String imgFilename, int cols, int rows, int zOrder) {
    super(app, imgFilename, cols, rows, zOrder);
    setXY(app.width+width, random((float)height/2, (float)(app.height-height/2)));
    patrol = false;
    exhaustClock = new Clock();
    exhaustClock.start();
    frame = 0;
  }
  //---------------------------------- Constructor End ------------------------------------//
  
  
  //------------------------------ Function: HandleCollision ------------------------------//
  /**
   * Handles collision when one happens.
   */
  void handleCollision(Entity e) {
    if (e instanceof Obstacle) {
      Obstacle o = (Obstacle) e;
      if (!o.isEnemy) {
        takeDamage(game.p.power);
        if (game.p.doLimitedShots && (game.p.shots < game.p.MAX_SHOTS))
          game.p.shots++;
      }
    }
  }
  //--------------------------------- HandleCollision End -------0-------------------------//
  
  
  //------------------------------ Function: SpawnProjectile ------------------------------//
  /**
   * Spawns an enemy laser at the specified speed
   */
  void spawnProjectile(int velocity) {
    Obstacle o = new Obstacle(app, "Sprites/Shots/shot" + type + ".png", 1, 1, 500, true, true);
    o.setXY(getX()+width/4, getY());
    o.setVelX(velocity);
    o.type = this.type;
    game.entities.add(o);
  }
  //--------------------------------- SpawnProjectile End --------------------------------//
  
  
  //---------------------------------- Function: OnDeath ---------------------------------//
  /**
   * Called when object is set to dead after taking damage.
   * Useful for score adjusting and death sprite spawning!
   */
  void onDeath() {
    game.queueAnimation("ship" + type + "_exp", (float)getX(), (float)getY(), false);
    sound.playSFX("Enemy_Death");
    if (type > 3) {
      game.updateScale(game.currScale+1);
      game.bossClock.start();
    }
    score();
    powerUp();
  }
  //------------------------------------- OnDeath End ------------------------------------//
  
  
  //---------------------------------- Function: Powerup ---------------------------------//
  /**
   * Defines likelihood for each ship to drop a powerup
   */
  void powerUp() {
     
    // Random powerup chance
    float rand = random(1);
    
    // Boss always drops a powerup, 50-50 between HP/score and common
    if (type > 3) {
      if (rand < 0.5) {
        if (rand < 0.25 && game.p.playerHealth < game.p.MAX_HP && game.currScale != game.MAX_SCALE_TIMES)
          game.queuePowerup(PowerupType.HP, this);
        else if (game.p.scoreMult < game.p.MAX_SCORE_MULT)
          game.queuePowerup(PowerupType.SCORE, this);
      }
      else {
        PowerupType randPower = powerUpHelper();
        if (randPower != PowerupType.NULL) 
          game.queuePowerup(randPower, this);
        return;
      }
    }
    else {
      PowerupType randPower = powerUpHelper();
      if (randPower != PowerupType.NULL) {
        switch(type) {
         case 1: 
           if (rand < .1) game.queuePowerup(randPower, this);
           break;
         case 2: 
           if (rand < .2) game.queuePowerup(randPower, this);  
           break;
         case 3: 
           if (rand < .3) game.queuePowerup(randPower, this);  
           break;
        }
      }
    } 
  }
  //------------------------------------- Powerup End ------------------------------------//
  
  
  //------------------------------- Function: powerUpHelper ------------------------------//
  /**
   * Handles spawning the correct power ups when one or more are maxed out
   */
   PowerupType powerUpHelper() {
     PowerupType randPower = commonPowerups[(int)random(commonPowerups.length)];
     boolean fr = game.p.fireRate == game.p.MAX_FIRE_RATE_UPS;
     boolean su = game.p.speedUps == game.p.MAX_SPEED_UPS;
     boolean pu = game.p.powerUps == game.p.MAX_POWER_UPS;
     if (!fr || !su || !pu) { // If all are max, skip and return null
       if (fr || su || pu) {  // If any are max
         while (true) {       // generate until one that is not max is generated
           if (fr && randPower == PowerupType.FIRERATE || su && randPower == PowerupType.SPEED || pu && randPower == PowerupType.POWER) 
             randPower = commonPowerups[(int)random(commonPowerups.length)];
           else 
             break;
         }
       }
       return randPower;
     }
     return PowerupType.NULL;
   }
  //---------------------------------- powerUpHelper End ---------------------------------//
  
  
  //----------------------------------- Function: score ----------------------------------//
  /**
   * Adjust score based on enemy type
   */
   void score() {
     switch(type) {
       case 1: game.addScore(25);  break;
       case 2: game.addScore(50);  break;
       case 3: game.addScore(100); break;
       case 4: game.addScore(500); break;
       case 5: game.addScore(700); break;
       case 6: game.addScore(900); break;
     }
   }
  //-------------------------------------- score End -------------------------------------//
}
