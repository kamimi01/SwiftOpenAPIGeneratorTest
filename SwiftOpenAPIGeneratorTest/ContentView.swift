//
//  ContentView.swift
//  SwiftOpenAPIGeneratorTest
//
//  Created by mikaurakawa on 2023/06/17.
//

import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct ContentView: View {
    @State private var emoji = "🫥"

    var body: some View {
        VStack {
            Text(emoji).font(.system(size: 100))
            Button("Get cat!") {
                Task {
                    try? await updateEmoji()
                }
            }
            Button("Get more cat!") {
                Task {
                    try? await updateEmoji(name: "kamimi")
                }
            }
        }
        .padding()
        .buttonStyle(.borderedProminent)
    }

    let client: Client

    init() {
        self.client = Client(
            serverURL: try! Servers.server1(),
            transport: URLSessionTransport()
        )
    }

    func updateEmoji(name: String = "mika") async throws {
        let response = try await client.getGreeting(Operations.getGreeting.Input(
            query: Operations.getGreeting.Input.Query(name: name)
        ))
        switch response {
        case let .ok(okResponse):
            switch okResponse.body {
            case .json(let json):
                emoji = json.message
            }
        case .undocumented(statusCode: let statusCode, _):
            print("cat-astrophe: \(statusCode)")
            emoji = "🙉"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
