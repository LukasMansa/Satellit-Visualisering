//Main code by CodingTrain
//Edited for satellites by Christian Vedel Petersen & Lukas Mansa Kristensen

float angle = 0;
float r = 200;
float angleb = 0;
PVector raxis = new PVector(0, 0, 0);
PImage earth;
PShape globe;
JSONArray satellites;

void setup() {
  size(600, 600, P3D);
  earth = loadImage("earth.jpg");
  satellites = new JSONArray();
  loadSats();

  noStroke();
  globe = createShape(SPHERE, r);
  globe.setTexture(earth);
}

void draw() {
  if (millis()==300*1000) { //Every 300th second we need new satellite positions, as the request only spans up to 300 seconds
    loadSats();
  }
  background(51);
  translate(width*0.5, height*0.5); //translate to the middle to draw our globe in the middle of the screen
  rotateY(angle);
  lights();
  fill(200);
  noStroke();
  shape(globe);
  //this part converts our latitude and longitude from cartesian coordinates to spherical coordinates using the math formulas
  for (int i = 0; i<satellites.size(); i++) { //we do the following code for every satellite
    JSONObject satellite = satellites.getJSONObject(i); //get the satellite object from the array
    JSONArray positions = satellite.getJSONArray("positions"); //get the positions array
    JSONObject item = positions.getJSONObject(round(millis()/1000)%300); //we need the position according to how many seconds the program has run
    float lat = item.getFloat("satlatitude"); //latitude
    float lon = item.getFloat("satlongitude"); //longitude
    float alt = item.getFloat("sataltitude"); //altitude
    
    PVector pos = cartesian(lat, lon); //the coordinates of the satellite
    rotation(pos);
    
    //we need to find the ratio between the real earths radius and the radius we specified in our program
    int earthR = 6371;
    float ratio = r/earthR;
    float h = alt*ratio;
    
    render(pos, h, angleb, raxis);
  }
}

PVector cartesian(float lat, float lon) {
  //this part converts our latitude and longitude from spherical coordinates to cartesian coordinates using the math formulas
  float theta = radians(lat);
  float phi = radians(lon) + PI;

  float x = r * cos(theta) * cos(phi);
  float y = -r * sin(theta);
  float z = -r * cos(theta) * sin(phi);

  PVector pos = new PVector(x, y, z);
  return pos;
  //now we have our coordinates
}

void rotation(PVector pos) {
  //calculate the rotation needed to draw our satellite
  PVector xaxis = new PVector(1, 0, 0);
  angleb = PVector.angleBetween(xaxis, pos);
  raxis = xaxis.cross(pos);
}

void render(PVector pos, float h, float angleb, PVector raxis) {
  //now we translate and rotate to the position our satellite is located at
  pushMatrix();
  translate(pos.x+pos.x/abs(pos.x)*h, pos.y, pos.z);
  rotate(angleb, raxis.x, raxis.y, raxis.z);
  fill(255);
  //and we draw the satellite
  box(5, 5, 5);
  popMatrix();
}

void loadSats() { //makes requests to n2yo.com for the position of 11 satellites
  satellites.setJSONObject(0, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/25544/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //ISS
  satellites.setJSONObject(1, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/43689/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //USA 276
  satellites.setJSONObject(2, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/42061/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //TK-1
  satellites.setJSONObject(3, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/41941/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //H-2A R/B
  satellites.setJSONObject(4, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/41470/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //PSLV R/B
  satellites.setJSONObject(5, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/39574/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //GPM
  satellites.setJSONObject(6, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/39227/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //KOMPSAT 5
  satellites.setJSONObject(7, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/39211/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //CZ-4C R/B
  satellites.setJSONObject(8, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/38770/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //ATLAS CENTAUR R/B
  satellites.setJSONObject(9, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/31797/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //SAR LUPE 2
  satellites.setJSONObject(10, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/25635/41.702/-76.014/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //Ørsted
}

void mousePressed() { //when the mouse is pressed the earth rotates one quarter. We do not rotate every frame as that would make it difficult to see the movement of the satellites
  angle += PI/2;
}
