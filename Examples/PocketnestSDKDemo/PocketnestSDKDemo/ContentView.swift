import SwiftUI
import PocketnestSDK

struct ContentView: View {
    @State private var showingSDK = false
    @State private var resultText = "Ready"

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Button("Open Pocketnest SDK") {
                    showingSDK = true
                }
                .buttonStyle(.borderedProminent)

                Text(resultText)
                    .font(.footnote)
                    .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle("PocketnestSDK Demo")
            .sheet(isPresented: $showingSDK) {
                NavigationView {
                    PocketnestSDK.webView(
                        url: "https://pocketnest-preprod.netlify.app",
                        redirectUri: "pocketnestredirecturi",
                        onSuccess: { payload in
                            if let data = try? JSONSerialization.data(
                                withJSONObject: payload,
                                options: .prettyPrinted
                            ),
                               let string = String(data: data, encoding: .utf8) {
                                resultText = "Success:\n\(string)"
                            } else {
                                resultText = "Success: \(payload)"
                            }
                            showingSDK = false
                        },
                        onExit: {
                            resultText = "User exited"
                            showingSDK = false
                        }
                    )
                    .navigationBarTitle("Pocketnest", displayMode: .inline)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Close") {
                                showingSDK = false
                            }
                        }
                    }
                }
            }
        }
    }
}
