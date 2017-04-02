#include <SPI.h>
#include <Ethernet.h>

// Enter a MAC address and IP address for your controller below.
byte mac[]={0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED};
//Enter the IP adress
IPAddress ip(10,0,0,20);

//Initializing the port you want to use
EthernetServer server(80);

#define SENDB A3 
#define BCKSP A2
#define ROWB A1
#define COLLUMNB A0
#define SENDLED 8
#define ROWLED 12
#define COLLUMNLED 13
#define BCKSPLED 11
#define TOLLERANCE 2000
// digital pin 2 has a pushbutton attached to it. Give it a name:
int pushButton[4] = {COLLUMNB,ROWB,BCKSP,SENDB};
int ledPin[4] = {COLLUMNLED,ROWLED,BCKSPLED, SENDLED};
int countPush[4] = {0,0,0,0}; // variable counting the times the button was pushed
int pressTime = 0; // this variable will get the millis() when the button was pressed
int newState[4] = {0,0,0,0};
int lastState[4] = {0,0,0,0};
char matrix[6][5] = {{'a','b','c','d','e'},{'f','g','h','i','j'},{'k','l','m','n','o'},{'p','q','r','s','t'},{'u','v','w','x','y'},{'z',' ','.',',','!'}};

/* * * * * * * * * * * * */
void HTML_OPEN(EthernetClient client){
  client.println("<!DOCTYPE html>");
  client.println("<html lang='en'>");
  }
  
void HTML_CLOSE(EthernetClient client){
  client.println("</html>");
  }

void HTML_HEAD(EthernetClient client){
    client.println("<head>");
    client.println("<meta charset='utf-8'>");
    client.println("<title>INF1805 - Trabalho 01 - Arduino</title>");
    client.println("<meta name='description' content='Fernando Homem da Costa e Felipe Vieira Cortes'>");
    client.println("<meta name='keywords' content='arduino, arduino webserver'>");
    client.println("<meta name='viewport' content='width=device-width, initial-scale=1'>");
    client.println("<link rel='stylesheet' href='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css' integrity='sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u' crossorigin='anonymous'>");
    //client.println("<script src='https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js' integrity='sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa' crossorigin='anonymous'></script>");
    client.println("</head>");
  }

void HTML_BODY_OPEN(EthernetClient client){
    client.println("<body>");
    client.println("<h1 class='text-center'>Hello World!</h1>");
  }

void HTML_BODY_CLOSE(EthernetClient client){
    client.println("</body>");
  }
void checkSend(EthernetClient client){
  
  int currentButton = pushButton[3];
  int currentLed = ledPin[3];
  int newS = newState[3];
  int lastS = lastState[3];
  
  newS = digitalRead(currentButton);
  
  if((newS == 1) && (lastS == 0)){
    lastS = newS;
    digitalWrite(currentLed, HIGH);
    sendMsg(client);
  }
  if((newS == 0) && (lastS == 1)){
    lastS = newS;
    digitalWrite(currentLed, LOW);
  }
  newState[3] = newS;
  lastState[3] = lastS;

}
void sendMsg(EthernetClient client){
    client.println(matrix[countPush[1]][countPush[0]]);
    client.println("<br />");
}
void stateChangeRoutine(int indx){
 
  int currentButton = pushButton[indx];
  int currentLed = ledPin[indx];
  int currentCount = countPush[indx];
  int newS = newState[indx];
  int lastS = lastState[indx];
  
  newS = digitalRead(currentButton);
  //Serial.println(newS);
  if((newS == 1) && (lastS == 0)){
    lastS = newS;
    if(currentCount < 4)
      currentCount++;
    else
      currentCount = 0;
    digitalWrite(currentLed, HIGH);
    pressTime = millis();
  }
  if((newS == 0) && (lastS == 1)){
    lastS = newS;
    digitalWrite(currentLed, LOW);
  }
  updateValues(indx,currentCount, newS, lastS);
}
void updateValues(int indx, int count, int news, int lasts){
  newState[indx] = news;
  lastState[indx] = lasts;
  countPush[indx] = count;
}
void setup() {
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }
  /* inicializa os pinos e leds como input/output respec. */
  for(int i = 0; i < 3; i++){
     pinMode(pushButton[i], INPUT);
     pinMode(ledPin[i], OUTPUT); 
  }
  // start the Ethernet connection and the server:
  Ethernet.begin(mac,ip);
  server.begin();
  Serial.print("server is at ");
  Serial.println(Ethernet.localIP());

}

void loop() {
  // listen for incoming clients
  EthernetClient client = server.available();
  if (client) {
    Serial.println("new client");
    // an http request ends with a blank line
    boolean currentLineIsBlank = true;
    while (client.connected()) {
      if (client.available()) {
        char c = client.read();
        Serial.write(c);
        // if you've gotten to the end of the line (received a newline
        // character) and the line is blank, the http request has ended,
        // so you can send a reply
        if (c == '\n' && currentLineIsBlank) {
            stateChangeRoutine(0);
            stateChangeRoutine(1);
          // send a standard http response header
          client.println("HTTP/1.1 200 OK");
          client.println("Content-Type: text/html");
          client.println("Connection: close");  // the connection will be closed after completion of the response
          client.println("Refresh: 5");  // refresh the page automatically every 5 sec
          client.println();
          HTML_OPEN(client);
          HTML_HEAD(client);
          HTML_BODY_OPEN(client);
          // output the value of each analog input pin
          /*for (int analogChannel = 0; analogChannel < 6; analogChannel++) {
            int sensorReading = analogRead(analogChannel);
            client.print("analog input ");
            client.print(analogChannel);
            client.print(" is ");
            client.print(sensorReading);
            client.println("<br />");
          }*/
         checkSend(client);
         HTML_BODY_CLOSE(client);
         HTML_CLOSE(client);
          break;
        }
        if (c == '\n') {
          // you're starting a new line
          currentLineIsBlank = true;
        } else if (c != '\r') {
          // you've gotten a character on the current line
          currentLineIsBlank = false;
        }
      }
    }
    // give the web browser time to receive the data
    delay(1);
    // close the connection:
    client.stop();
    Serial.println("client disconnected");
  }
}
