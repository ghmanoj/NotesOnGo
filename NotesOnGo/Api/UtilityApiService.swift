import Foundation

final class UtilityApiService {
  private let session: URLSession

  init(session: URLSession? = nil) {
    if let session = session {
      self.session = session
    } else {
      let configuration = URLSessionConfiguration.ephemeral
      configuration.waitsForConnectivity = false
      configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
      configuration.timeoutIntervalForRequest = 12
      configuration.timeoutIntervalForResource = 130
      let callbacks = OperationQueue()
      callbacks.qualityOfService = .userInitiated
      self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: callbacks)
    }
  }

  func performAction(_ endpointIP: String, cmdMessage: CommandMessage,
                     completion: @escaping (Result<Data, NetworkError>) -> Void) {
    guard let url = URL(string: "http://\(endpointIP):8081/utilities_local") else {
      completion(.failure(.badURL))
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    // USPS browser fetches have a longer server-side deadline than local commands.
    request.timeoutInterval = cmdMessage.modifier == "mailbox" ? 130 : 12
    do { request.httpBody = try JSONEncoder().encode(cmdMessage) }
    catch {
      completion(.failure(.messageError))
      return
    }
    session.dataTask(with: request) { data, response, error in
      guard error == nil, let response = response as? HTTPURLResponse,
            (200..<300).contains(response.statusCode), let data = data else {
        completion(.failure(.requestFailed))
        return
      }
      completion(.success(data))
    }.resume()
  }
}
