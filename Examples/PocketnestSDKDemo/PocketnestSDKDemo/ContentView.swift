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
                    PocketnestSDK.webViewUI(
                        url: "https://pocketnest-preprod.netlify.app",
                        accessToken: nil, //use token from you api to login user automatically
                        redirectUri: "pocketnestredirecturi",
                        onSuccess: {
                            resultText = "Success"
                        },
                        onExit: {
                            resultText = "User exited"
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
