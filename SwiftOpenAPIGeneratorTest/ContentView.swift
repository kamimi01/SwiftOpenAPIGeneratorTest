//
//  ContentView.swift
//  SwiftOpenAPIGeneratorTest
//
//  Created by mikaurakawa on 2023/06/17.
//

import SwiftUI
import OpenAPIRuntime
import OpenAPIURLSession

struct ContentView<C: APIProtocol>: View {
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

    let client: C

    init(client: C) {
        self.client = client
    }

    init() where C == Client {
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
        ContentView(client: MockClient())
    }
}

struct MockClient: APIProtocol {
    func getGreeting(_ input: Operations.getGreeting.Input) async throws -> Operations.getGreeting.Output {
        let name = input.query.name ?? "mika"
        let emojis = String(repeating: "🤖", count: 2)
        return .ok(Operations.getGreeting.Output.Ok(
            body: .json(Components.Schemas.Greeting(message: name))
        ))
    }
}
