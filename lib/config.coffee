fs = require 'fs'
metro = require './metro-ui'

# 10.0.xx > 10 (Problem: Node still detects as 6.3)
# 6.3.xx  > 8.1
# 6.2.xx  > 8, 8.1
# 6.1.xx  > 7
# 6.0.xx  > Vista

WINDOWS_ACCENT_KEY       = 'HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent'
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

    setTheme()
    setIcons()
    setDisplayMode()
    setFontSize()
    toggleGutterStyling()
    toggleTreeDisclosureArrows()

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

    # metro.onConfigChange 'useSystemAccentColor', ->

    metro.onConfigChange 'showGutterStyling', ->
      toggleGutterStyling()

    metro.onConfigChange 'hideTreeDisclosureArrows', ->
      toggleTreeDisclosureArrows()
