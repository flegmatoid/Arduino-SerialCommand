#include <SPI.h>
#include <Ethernet.h>
byte mac[] = { 
  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress ip(192,168,1, 177);
IPAddress gateway(192,168,1, 1);
IPAddress subnet(255, 255, 0, 0);
EthernetServer EtherServer(23);
EthernetClient EtherClient;
#include <EtherCommand.h>

#define arduinoLED 13   // Arduino LED on board

EtherCommand eCmd;     // The demo EtherCommand object

void setup() {
  pinMode(arduinoLED, OUTPUT);      // Configure the onboard LED for output
  digitalWrite(arduinoLED, LOW);    // default to LED off

  Serial.begin(9600);
  Ethernet.begin(mac, ip, gateway, subnet);
  EtherServer.begin();

  // Setup callbacks for EtherCommand commands
  eCmd.addCommand("ON",    LED_on);          // Turns LED on
  eCmd.addCommand("OFF",   LED_off);         // Turns LED off
  eCmd.addCommand("HELLO", sayHello);        // Echos the string argument back
  eCmd.addCommand("P",     processCommand);  // Converts two arguments to integers and echos them back
  eCmd.setDefaultHandler(unrecognized);      // Handler for command that isn't matched  (says "What?")
  Serial.println("Ready");
}

void loop() {
  EtherClient = EtherServer.available();
  eCmd.readSerial(EtherClient);     // We don't do much, just process serial commands
}


void LED_on() {
  Serial.println("LED on");
  digitalWrite(arduinoLED, HIGH);
}

void LED_off() {
  Serial.println("LED off");
  digitalWrite(arduinoLED, LOW);
}

void sayHello() {
  char *arg;
  arg = eCmd.next();    // Get the next argument from the EtherCommand object buffer
  if (arg != NULL) {    // As long as it existed, take it
    Serial.print("Hello ");
    Serial.println(arg);
  }
  else {
    Serial.println("Hello, whoever you are");
  }
}


void processCommand() {
  int aNumber;
  char *arg;

  Serial.println("We're in processCommand");
  arg = eCmd.next();
  if (arg != NULL) {
    aNumber = atoi(arg);    // Converts a char string to an integer
    Serial.print("First argument was: ");
    Serial.println(aNumber);
  }
  else {
    Serial.println("No arguments");
  }

  arg = eCmd.next();
  if (arg != NULL) {
    aNumber = atol(arg);
    Serial.print("Second argument was: ");
    Serial.println(aNumber);
  }
  else {
    Serial.println("No second argument");
  }
}

// This gets set as the default handler, and gets called when no other command matches.
void unrecognized(const char *command) {
  Serial.println("What?");
  EtherClient.println("What?");
  
}