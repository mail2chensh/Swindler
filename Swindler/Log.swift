import ASLLog

/// Internal logger.
internal private(set) var log = Log()

private var xcodeColorsEnabled = (String.fromCString(getenv("XcodeColors")) == "YES")

/// Internal logging methods. Uses ASL to log to system console at correct log levels.
struct Log {
  static var token: dispatch_once_t = 0
  init() {
    dispatch_once(&Log.token) {
      asl_add_log_file(nil, STDERR_FILENO)
      asl_set_filter(nil, aslFilterMaskUpTo(ASL_LEVEL_DEBUG))
    }
  }

  // TODO: filter out logs depending on build settings.

  /// Log that something has failed.
  func error(@autoclosure out: () -> (String)) {
    log(out(), level: ASL_LEVEL_ERR, withColor: Color.red)
  }

  /// Log that something is amiss which might result in a failure.
  func warn(@autoclosure out: () -> (String)) {
    log(out(), level: ASL_LEVEL_WARNING, withColor: Color.yellow)
  }

  /// Log something of moderate interest to the user or administrator.
  func notice(@autoclosure out: () -> (String)) {
    log(out(), level: ASL_LEVEL_NOTICE, withColor: Color.purple)
  }

  /// Log something purely informational (not visible in production).
  func info(@autoclosure out: () -> (String)) {
    log(out(), level: ASL_LEVEL_INFO, withColor: Color.cyan)
  }

  /// Log debug info (not visible in production).
  func debug(@autoclosure out: () -> (String)) {
    log(out(), level: ASL_LEVEL_DEBUG, withColor: Color.blue)
  }

  /// Log more verbose debug info (usually not visible in production or development).
  func trace(@autoclosure out: () -> (String)) {
    log(out(), level: ASL_LEVEL_DEBUG, withColor: Color.gray)
  }

  struct Color {
    let red: UInt8
    let green: UInt8
    let blue: UInt8

    static let red    = Color(red: 255, green: 0, blue: 0)
    static let green  = Color(red: 0, green: 255, blue: 0)
    static let blue   = Color(red: 80, green: 80, blue: 230)
    static let yellow = Color(red: 255, green: 255, blue: 0)
    static let purple = Color(red: 200, green: 50, blue: 200)
    static let cyan   = Color(red: 50, green: 200, blue: 200)
    static let gray   = Color(red: 120, green: 120, blue: 120)
  }

  // Log on the given log level, using the given color if XcodeColors is enabled.
  private func log(string: String, level: Int32, withColor: Color? = nil) {
    var output = ""
    if let color = withColor where xcodeColorsEnabled {
      let escape = "\u{001b}["
      let reset  = "\(escape);"
      output = "\(escape)fg\(color.red),\(color.green),\(color.blue);\(string)\(reset)"
    } else {
      output = string
    }
    aslLog(output, level)
  }

}

/*
#define	ASL_FILTER_MASK(level) (1 << (level))
#define	ASL_FILTER_MASK_UPTO(level) ((1 << ((level) + 1)) - 1)
*/

private func aslFilterMaskUpTo(level: Int32) -> Int32 {
  return ((1 << ((level) + 1)) - 1)
}
