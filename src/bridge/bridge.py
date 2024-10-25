import asyncio
import bleak
import websockets
import json
import time

WSDM_PORT = 54817
SERVICE_UUID = "0f203ee2-153c-cfd3-0448-00a21d340a43"

async def main():
    print("scanning for device...", flush=True)
    devices = []
    while len(devices) == 0:
        devices = await bleak.BleakScanner.discover(service_uuids = [SERVICE_UUID])
    print("device found", flush=True)
    await connect_device(devices[0].address)

async def connect_device(address):
    while True:
        device = await bleak.BleakScanner.find_device_by_address(address)
        if not device:
            continue
        try:
            async with bleak.BleakClient(device) as client:
                print("device connected", flush=True)
                await run_device_loop(client)
        except:
            print("connection lost, reconnecting", flush=True)
            continue

async def run_device_loop(client):
    for service in client.services:
        if service.uuid == SERVICE_UUID:
            left = service.characteristics[0]
            right = service.characteristics[1]
            await asyncio.gather(
                listen_to_ws(client, left, "1234"),
                listen_to_ws(client, right, "4321")
            )

async def listen_to_ws(client, chara, address):
    uri = f"ws://127.0.0.1:{WSDM_PORT}"
    async with websockets.connect(uri, ping_interval=0.5) as ws:
        message = {"identifier": "SynchroDevice", "address": address, "version": 0}
        await ws.send(json.dumps(message))
        print("connected to WSDM", flush=True)
        while True:
            packet = await ws.recv()
            speed = 30 * (packet[2] & 0x0F) * (-1 if packet[2] & 0x80 != 0 else 1)
            await client.write_gatt_char(chara, str(speed).encode("ascii"), False)

asyncio.run(main())
