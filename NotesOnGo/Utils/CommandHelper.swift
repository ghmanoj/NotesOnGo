import Foundation

final class ActionCommandHelper {
  private let utilityApiService = ObjectUtils.utilityApiService

  static func parse(_ text: String) -> CommandMessage? {
    let words = text.lowercased().components(separatedBy: CharacterSet.alphanumerics.inverted)
      .filter { !$0.isEmpty }
    let phrase = words.joined(separator: " ")
    switch phrase {
    case "system status": return CommandMessage(command: "system", modifier: "status")
    case "system update": return CommandMessage(command: "system", modifier: "update")
    case "utility lock": return CommandMessage(command: "utility", modifier: "lock")
    case "utility logout", "utility log out": return CommandMessage(command: "utility", modifier: "logout")
    case "utility mailbox", "utility mail box": return CommandMessage(command: "utility", modifier: "mailbox")
    default: return nil
    }
  }

  static func canRunAutomatically(_ text: String) -> Bool {
    guard let command = parse(text) else { return false }
    return (command.command == "system" && command.modifier == "status") ||
      (command.command == "utility" && command.modifier == "mailbox")
  }

  func perform(msg: String, on endPoints: [ApiEndPointData], callback: @escaping (CommandResponse) -> Void) {
    guard let command = Self.parse(msg) else {
      callback(CommandResponse(type: "Unknown", message: "Command not recognized", status: false))
      return
    }
    guard !endPoints.isEmpty else {
      callback(CommandResponse(type: "Unknown", message: "Add a backend address in Settings", status: false))
      return
    }
    // URLSession starts all endpoints concurrently; no extra dispatch hop is needed.
    for endpoint in endPoints {
      utilityApiService.performAction(endpoint.ip, cmdMessage: command) { result in
        switch result {
        case .success(let data):
          do { callback(try JSONDecoder().decode(CommandResponse.self, from: data)) }
          catch { callback(CommandResponse(type: "Unknown", message: "Invalid backend response", status: false)) }
        case .failure:
          callback(CommandResponse(type: "Unknown", message: "Could not reach \(endpoint.ip)", status: false))
        }
      }
    }
  }
}
