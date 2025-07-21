import Foundation

class Logger {
    
    enum LogLevel: String, CaseIterable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        
        var emoji: String {
            switch self {
            case .debug: return "🐛"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }
    
    static let shared = Logger()
    
    private let dateFormatter: DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    }
    
    private func log(level: LogLevel, message: String, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = URL(fileURLWithPath: file).lastPathComponent
        let timestamp = dateFormatter.string(from: Date())
        
        let logMessage = "\(level.emoji) [\(timestamp)] [\(level.rawValue)] \(fileName):\(line) \(function) - \(message)"
        
        print(logMessage)
        
        // In a production app, you might want to save logs to a file
        // or send them to a logging service
    }
    
    func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        log(level: .debug, message: message, file: file, function: function, line: line)
        #endif
    }
    
    func info(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, file: file, function: function, line: line)
    }
    
    func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, file: file, function: function, line: line)
    }
    
    func error(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, file: file, function: function, line: line)
    }
}

// MARK: - Extensions for easier logging

extension NSObject {
    func logDebug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.debug("\(type(of: self)): \(message)", file: file, function: function, line: line)
    }
    
    func logInfo(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.info("\(type(of: self)): \(message)", file: file, function: function, line: line)
    }
    
    func logWarning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.warning("\(type(of: self)): \(message)", file: file, function: function, line: line)
    }
    
    func logError(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        Logger.shared.error("\(type(of: self)): \(message)", file: file, function: function, line: line)
    }
}
