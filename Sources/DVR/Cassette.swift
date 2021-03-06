import Foundation

struct Cassette {

    // MARK: - Properties

    let interactions: [Interaction]


    // MARK: - Initializers

    init(interactions: [Interaction]) {
        self.interactions = interactions
    }


    // MARK: - Functions

    func interactionForRequest(_ request: URLRequest) -> Interaction? {
        for interaction in interactions {
            let interactionRequest = interaction.request

            // Note: We don't check headers right now
            if interactionRequest.httpMethod == request.httpMethod && interactionRequest.url == request.url && interactionRequest.hasHTTPBodyEqualToThatOfRequest(request)  {
                return interaction
            }
        }
        return nil
    }
}


extension Cassette {
    var dictionary: [String: Any] {
        return [
            "interactions": interactions.map { $0.dictionary }
        ]
    }

    init?(dictionary: [String: Any]) {
        if let array = dictionary["interactions"] as? [[String: Any]] {
            interactions = array.compactMap { Interaction(dictionary: $0) }
        } else {
            interactions = []
        }
    }
}

private extension URLRequest {
    func hasHTTPBodyEqualToThatOfRequest(_ request: URLRequest) -> Bool {
        guard let body1 = self.httpBody,
            let body2 = request.httpBody,
            let encoded1 = Interaction.encodeBody(body1, headers: self.allHTTPHeaderFields),
            let encoded2 = Interaction.encodeBody(body2, headers: request.allHTTPHeaderFields)
        else {
            return self.httpBody == request.httpBody
        }

        return encoded1.isEqual(encoded2)
    }
}
