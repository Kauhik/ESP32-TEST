import Foundation
import CoreBluetooth
import SwiftUI

class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    @Published var discoveredPeripheral: CBPeripheral?
    @Published var isConnected = false
    var blinkCharacteristic: CBCharacteristic?
    
    let serviceUUID = CBUUID(string: "4fafc201-1fb5-459e-8fcc-c5c9c331914b")
    let characteristicUUID = CBUUID(string: "beb5483e-36e1-4688-b7f5-ea07361b26a8")
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScanning() {
        // Only start scanning if not already connected.
        if !isConnected {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            print("Scanning for peripherals...")
        }
    }
    
    // MARK: - CBCentralManagerDelegate Methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScanning()
        } else {
            print("Bluetooth not available or not authorized")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print("Discovered: \(peripheral.name ?? "Unknown")")
        // If not connected to any peripheral, take the first one.
        if discoveredPeripheral == nil {
            discoveredPeripheral = peripheral
            centralManager.stopScan()
            peripheral.delegate = self
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        isConnected = true
        print("Connected to peripheral: \(peripheral.name ?? "Unknown")")
        peripheral.discoverServices([serviceUUID])
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDisconnectPeripheral peripheral: CBPeripheral,
                        error: Error?) {
        print("Disconnected from peripheral: \(peripheral.name ?? "Unknown")")
        isConnected = false
        discoveredPeripheral = nil
        blinkCharacteristic = nil
        // Restart scanning so a new connection can be made.
        startScanning()
    }
    
    // MARK: - CBPeripheralDelegate Methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = peripheral.services {
            for service in services where service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == characteristicUUID {
                    blinkCharacteristic = characteristic
                    print("Blink characteristic discovered.")
                }
            }
        }
    }
    
    // MARK: - Send Command
    
    func sendBlinkCommand() {
        if let peripheral = discoveredPeripheral, let characteristic = blinkCharacteristic {
            let command = "blink"
            if let data = command.data(using: .utf8) {
                peripheral.writeValue(data, for: characteristic, type: .withResponse)
                print("Sent blink command.")
            }
        } else {
            print("Device not connected or characteristic not found.")
        }
    }
    
    // MARK: - Disconnect / Refresh Connection
    
    // Call this method to disconnect from the current peripheral and restart scanning.
    func disconnect() {
        if let peripheral = discoveredPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}
