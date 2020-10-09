//Main code by CodingTrain
//Edited for satellites by Christian Vedel Petersen & Lukas Mansa Kristensen

float angle = 0;

float r = 200;

PImage earth;
PShape globe;
JSONArray satellites;
int satId = 25544;

void setup() {
  size(600, 600, P3D);
  earth = loadImage("earth.jpg");
  satellites = new JSONArray();
  for(int i = 0; i<30; i++) {
  satellites.setJSONObject(i, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/" + satId + "/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ"));
  satId++;
  }
  satId=25544;
  satellites.setJSONObject(30, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/25635/41.702/-76.014/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ")); //Ørsted satellitten
  


  noStroke();
  globe = createShape(SPHERE, r);
  globe.setTexture(earth);
}

void draw() {
  if(millis()==300*1000) { //Every 300th second we need new satellite positions, as the request only spans up to 300 seconds
    satellites.setJSONObject(0, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/25544/0/0/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ"));
    satellites.setJSONObject(1, loadJSONObject("https://www.n2yo.com/rest/v1/satellite/positions/25635/41.702/-76.014/0/300/&apiKey=C62E2D-6QNCLN-TCZYTJ-4KGQ"));
  }
  background(51);
  translate(width*0.5, height*0.5); //translate to the middle to draw our globe in the middle of the screen
  rotateY(angle);

  lights();
  fill(200);
  noStroke();
  //sphere(r);
  shape(globe);
  for(int i = 0; i<satellites.size(); i++) {
  JSONObject satellite = satellites.getJSONObject(i); //get the satellite object from the array
  JSONArray positions = satellite.getJSONArray("positions"); //get the positions array
  JSONObject info = satellite.getJSONObject("info"); //get the info object

   
   JSONObject item = positions.getJSONObject(round(millis()/1000)%300); //we need the position according to how many seconds the program has run
   float lat = item.getFloat("satlatitude"); //latitude
   float lon = item.getFloat("satlongitude"); //longitude
   float alt = item.getFloat("sataltitude"); //altitude
   String name = info.getString("name"); //name of the satellite
   
   //this part converts our latitude and longitude from cartesian coordinates to spherical coordinates using the math formulas
    float theta = radians(lat);
    float phi = radians(lon) + PI;

    float x = r * cos(theta) * cos(phi);
    float y = -r * sin(theta);
    float z = -r * cos(theta) * sin(phi);

    PVector pos = new PVector(x, y, z);
    //now we have our coordinates
    
    //we need to find the ratio between the real earths radius and the radius we specified in our program 
    int earthR = 6371;
    float ratio = r/earthR;
    float h = alt*ratio;
    
//calculate the rotation needed to draw our satellite
    PVector xaxis = new PVector(1, 0, 0);
    float angleb = PVector.angleBetween(xaxis, pos);
    PVector raxis = xaxis.cross(pos);
    
//now we translate and rotate to the position our satellite is located at
    pushMatrix();
    translate(x+x/abs(x)*h, y, z);
    rotate(angleb, raxis.x, raxis.y, raxis.z);
    fill(255);
    //and we draw the satellite
    box(5, 5, 5);
    popMatrix();
  }


}
