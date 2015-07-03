fs = require 'fs'
os = require 'os'
metro = require './metro-ui'
registry = require 'winreg'

WINDOWS_ACCENT_KEY       = '\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent'
WINDOWS_10_ACCENT_VALUE  = 'AccentColorMenu'
WINDOWS_10_PALETTE_VALUE = 'AccentColorPalette'
WINDOWS_8_ACCENT_VALUE   = 'AccentColor'

module.exports =
  apply: ->
    root = document.documentElement

    # Helpers
    set = (key, value) ->
      value = normalizeAttributeValue(value) if typeof value is 'string'
      root.setAttribute("metro-ui-#{key}", value)

    setTheme = ->
      theme = metro.get('theme')
      set('theme', theme)

    setIcons = ->
      icons = metro.get('icons')
      set('icons', icons)

    setFontSize = ->
      fontSize = metro.get('fontSize')
      root.style.fontSize = fontSize + 'px'

    setDisplayMode = ->
      displayMode = metro.get('displayMode')
      set('display-mode', displayMode)

    toggleGutterStyling = ->
      showGutterStyling = metro.get('showGutterStyling')
      set('gutter', showGutterStyling)

    toggleTreeDisclosureArrows = ->
      hideTreeDisclosureArrows = metro.get('hideTreeDisclosureArrows')
      set('tree-disclosure-arrows', hideTreeDisclosureArrows)

    normalizeAttributeValue = (value) ->
      value
        .toLowerCase()
        .replace(/\s+/, '-')

    writeConfig = ->
      theme = normalizeAttributeValue(metro.get('theme'))
      themeAccentColor = metro.get('themeAccentColor').toHexString()
      editorFontFamily = atom.config.get('editor.fontFamily')

      configData =
      """
        @editor-font-family: '#{editorFontFamily}';
        @theme-accent-color: #{themeAccentColor};
        @import 'themes/#{theme}';
      """

      # Save the file
      fs.writeFileSync metro.configPath, configData

    getSystemAccentColor = ->
      switch process.platform
        when 'win32', 'win64'
          getWindowsAccentColor()
        when 'darwin'
          getDarwinAccentColor()
        when 'linux'
          getLinuxAccentColor()

    getWindowsAccentColor = ->
      release = os.release()
      if release.match "10.0"
        value = WINDOWS_10_ACCENT_VALUE
      else if release.match "(6.3|6.2)"
        value = WINDOWS_8_ACCENT_VALUE
      else
        # Windows 7 and below つ ◕_◕ ༽つ
        metro.set('themeAccentColor', metro.config.themeAccentColor.default)
        return

      key = new registry(hive: registry.HKCU, key: WINDOWS_ACCENT_KEY)
      key.get(value, RegistryCallback)

    getDarwinAccentColor = -> metro.set('themeAccentColor', '#0763D8') # Yosemite
    getLinuxAccentColor  = -> metro.set('themeAccentColor', '#E97A43') # Ubuntu

    ABGRtoRGB = (abgr) ->
      color = parseInt(abgr, 16)

      a = ((color >> 24) & 0xff) / 255
      b = (color >> 16) & 0xff
      g = (color >> 8) & 0xff
      r = color & 0xff

      return RGBtoHexString(r, g, b)

    RGBtoHexString = (r, g, b) ->
      value = ((Math.round(r) << 16) + (Math.round(g) << 8) + Math.round(b)).toString(16)
      value = "0#{value}" while value.length < 6
      "##{value}"

    RegistryCallback = (error, item) ->
      if error # This should not happen under normal operation
        metro.get('useSystemAccentColor', false)
      else
        color = ABGRtoRGB(item.value)
        metro.set('themeAccentColor', color)

    # Initialization
    setTheme()
    setIcons()
    setDisplayMode()
    setFontSize()
    toggleGutterStyling()
    toggleTreeDisclosureArrows()

    if metro.get('useSystemAccentColor')
      getSystemAccentColor()

    # Events
    metro.onConfigChange 'theme', ->
      setTheme()

    metro.onConfigChange 'icons', ->
      setIcons()

    metro.onConfigChange 'fontSize', ->
      setFontSize()

    metro.onConfigChange 'displayMode', ->
      setDisplayMode()

    metro.onConfigChange 'themeAccentColor', ->
      writeConfig()

    metro.onConfigChange 'useSystemAccentColor', ->
      if metro.get('useSystemAccentColor')
        # If there is a color change this will trigger the `themeAccentColor` event
        getSystemAccentColor()

    metro.onConfigChange 'showGutterStyling', ->
      toggleGutterStyling()

    metro.onConfigChange 'hideTreeDisclosureArrows', ->
      toggleTreeDisclosureArrows()
