class KeyCodes {
  static const soh = 1;
  static const stx = 2;
  static const etx = 3;
  static const eof = 4;
  static const endOfLine = 5;
  static const forward = 6;
  static const newLine = 10;
  static const killToEnd = 11;
  static const clear = 12;
  static const carriageReturn = 13;
  static const killToStart = 21;
  static const yank = 25; //  End of medium
  static const escape = 27;
  static const capitalA = 65; // arrowUp [ 27 91 65 ]
  static const capitalB = 66; // arrowDown [ 27 91 66 ]
  static const capitalC = 67; // arrowRight [ 27 91 67 ]
  static const capitalD = 68; // arrowLeft [ 27 91 68 ]
  static const capitalF = 70; // end [ 27 91 70 ]
  static const capitalH = 72; // home [ 27 91 72 ]
  static const leftBracket = 91;
  static const backspace = 127;
}

enum ShellCommand {
  clear, reset, exit,
}
