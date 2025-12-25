import Foundation

struct Greeting {
    static func greeting(for name: String) -> String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        let greeting: String
        switch hour {
        case 0..<12:
            greeting = "Good morning"
        case 12..<17:
            greeting = "Good afternoon"
        case 17..<24:
            greeting = "Good evening"
        default:
            greeting = "Hello"
        }
        
        return "\(greeting), \(name)"
    }
}

