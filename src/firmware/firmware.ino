#include <ESP32Servo.h> 
#include <BLEDevice.h>
#include <BLEUtils.h>
#include <BLEServer.h>

#define SERVICE_UUID "0f203ee2-153c-cfd3-0448-00a21d340a43"
#define LEFT_UUID "ca88902b-6d8a-79de-cde5-8f30b102cac9"
#define RIGHT_UUID "732995fc-cdbe-9aa2-d000-6e6ead12e651"

const int leftPin = 25;
const int rightPin = 26;

Servo leftWheel;
Servo rightWheel;

BLEServer *server;
BLEService *service;
BLECharacteristic *leftChara;
BLECharacteristic *rightChara;
BLEAdvertising *advertising;

class ServerCallbacks : public BLEServerCallbacks {
  void onDisconnect(BLEServer *pServer, esp_ble_gatts_cb_param_t *param) {
    server->getAdvertising()->start();
  }
};


class LeftCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *chara, esp_ble_gatts_cb_param_t *param) {
    int value = chara->getValue().toInt();
    leftWheel.write(90 + value);
  }
};

class RightCallbacks : public BLECharacteristicCallbacks {
  void onWrite(BLECharacteristic *chara, esp_ble_gatts_cb_param_t *param) {
    int value = chara->getValue().toInt();
    rightWheel.write(90 - value);
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
  BLEDevice::init("Wheels");
  server = BLEDevice::createServer();
  server->setCallbacks(new ServerCallbacks());
  service = server->createService(SERVICE_UUID);
  leftChara = service->createCharacteristic(LEFT_UUID, BLECharacteristic::PROPERTY_WRITE);
  rightChara = service->createCharacteristic(RIGHT_UUID, BLECharacteristic::PROPERTY_WRITE);
  leftChara->setCallbacks(new LeftCallbacks());
  rightChara->setCallbacks(new RightCallbacks());
  service->start();
  server->getAdvertising()->addServiceUUID(SERVICE_UUID);
  server->getAdvertising()->start();
}

void loop() {
  delay(10000);
}