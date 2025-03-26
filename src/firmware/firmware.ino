#include <ESP32Servo.h> 
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID "40ee1111-63ec-4b7f-8ce7-712efd55b90e"
#define TX_UUID "40ee2222-63ec-4b7f-8ce7-712efd55b90e"

const int leftPin = 25;
const int rightPin = 26;

Servo leftWheel;
Servo rightWheel;

BLEServer *server;
BLEService *service;
BLECharacteristic *txChara;
BLEAdvertising *advertising;

class ServerCallbacks : public BLEServerCallbacks {
  void onDisconnect(BLEServer *pServer, esp_ble_gatts_cb_param_t *param) {
    server->getAdvertising()->start();
  }
};

class TxCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *chara, esp_ble_gatts_cb_param_t *param) {
    String msg = chara->getValue();
    int data_left = (unsigned char)msg.charAt(1);
    int data_right = (unsigned char)msg.charAt(2);
    int dir_left = data_left > 127 ? 1 : -1;
    int dir_right = data_right > 127 ? -1 : 1;
    int speed_left = min(data_left & 127, 90);
    int speed_right = min(data_right & 127, 90);
    leftWheel.write(90 + speed_left * dir_left);
    rightWheel.write(90 + speed_right * dir_right);
  }
};

void setup() {
  ESP32PWM::allocateTimer(0);
  ESP32PWM::allocateTimer(1);
  ESP32PWM::allocateTimer(2);
  ESP32PWM::allocateTimer(3);
  leftWheel.setPeriodHertz(50);
  leftWheel.attach(leftPin, 500, 2500);
  rightWheel.setPeriodHertz(50);
  rightWheel.attach(rightPin, 500, 2500);
  initServer();
}

void initServer() {
  BLEDevice::init("UFO-TW");
  server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());
  service = server->createService(SERVICE_UUID);
  txChara = service->createCharacteristic(TX_UUID, BLECharacteristic::PROPERTY_WRITE);
  txChara->setCallbacks(new TxCallbacks());
  service->start();
  server->getAdvertising()->addServiceUUID(SERVICE_UUID);
  server->getAdvertising()->start();
}

void loop() {
  delay(10000);
}