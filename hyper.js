module.exports = {
  config: {
    // default font size in pixels for all tabs
    fontSize: 22,

    // font family with optional fallbacks
    fontFamily: "PowerlineSymbols, Operator Mono",

    // terminal cursor background color and opacity (hex, rgb, hsl, hsv, hwb or cmyk)
    cursorColor: "#61afef",

    // `BEAM` for |, `UNDERLINE` for _, `BLOCK` for █
    cursorShape: "BLOCK",

    // color of the text
    foregroundColor: "#d0d0d0",

    // terminal background color
    backgroundColor: "#282c34",

    // border color (window, tabs)
    borderColor: "#282c34",

    // custom css to embed in the main window
    css: "",

    // custom css to embed in the terminal window
    termCSS: "",

    // set to `true` if you're using a Linux set up
    // that doesn't shows native menus
    // default: `false` on Linux, `true` on Windows (ignored on macOS)
    showHamburgerMenu: "",

    // set to `false` if you want to hide the minimize, maximize and close buttons
    // additionally, set to `'left'` if you want them on the left, like in Ubuntu
    // default: `true` on windows and Linux (ignored on macOS)
    showWindowControls: "",

    padding: "12px 14px",

    colors: {
      black: "#282c34",
      lightBlack: "#808080",
      red: "#e06c75",
      lightRed: "#e06c75",
      green: "#98c379",
      lightGreen: "#98c379",
      yellow: "#e5c07b",
      lightYellow: "#e5c07b",
      blue: "#61afef",
      lightBlue: "#61afef",
      magenta: "#d19a66",
      lightMagenta: "#d19a66",
      cyan: "#56b6c2",
      lightCyan: "#56b6c2",
      white: "#d0d0d0",
      lightWhite: "#f5f5f5"
    },

    // the shell to run when spawning a new session (i.e. /usr/local/bin/fish)
    // if left empty, your system's login shell will be used by default
    shell: "C:\\Program Files\\Git\\bin\\bash.exe",

    // for setting shell arguments (i.e. for using interactive shellArgs: ['-i'])
    // by default ['--login'] will be used
    shellArgs: [],

    // for environment variables
    env: {},

    // set to false for no bell
    bell: false,

    // if true, selected text will automatically be copied to the clipboard
    copyOnSelect: true
  },

  // a list of plugins to fetch and install from npm
  // format: [@org/]project[#version]
  // examples:
  //   `hyperpower`
  //   `@company/project`
  //   `project#1.0.1`
  plugins: [
    "hyper-blink",
    "hyperterm-cursor",
    "hypercwd",
    "hyperlinks",
    "hyperclean"
  ],

  hyperclean: {
    hideTabs: true
  },

  // in development, you can create a directory under
  // `~/.hyper_plugins/local/` and include it here
  // to load it and avoid it being `npm install`ed
  localPlugins: []
};
