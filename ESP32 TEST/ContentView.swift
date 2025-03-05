import SwiftUI

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    
    var body: some View {
        VStack(spacing: 20) {
            if bleManager.isConnected {
                Text("Connected to \(bleManager.discoveredPeripheral?.name ?? "Device")")
                    .font(.headline)
            } else {
                Text("Scanning for BLE devices...")
                    .font(.headline)
            }
            
            Button(action: {
                bleManager.sendBlinkCommand()
            }) {
                Text("Blink LED")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
