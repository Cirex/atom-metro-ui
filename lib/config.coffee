fs = require 'fs'
metro = require './metro-ui'
registry = require 'winreg'

WINDOWS_ACCENT_KEY      = '\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Accent'
WINDOWS_10_ACCENT_VALUE = 'AccentColorMenu' # AccentColor is used by legacy 8.x apps
WINDOWS_8_ACCENT_VALUE  = 'AccentColor'

WINDOWS_RELEASE_KEY   = '\\SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion'
WINDOWS_RELEASE_VALUE = 'ProductName'

module.exports =
  apply: ->
    root = document.documentElement

    set = (key, value) ->
      value = metro.get(key)   if typeof value is 'undefined'
      value = normalize(value) if typeof value is 'string'
      key   = normalize(key)

      root.setAttribute("metro-ui-#{key}", value)

    setFontSize = ->
      fontSize = metro.get('fontSize')
      root.style.fontSize = fontSize + 'px'

    normalize = (value) ->
      value
        .replace(/([a-z])([A-Z])/g, '$1-$2') # camelCase => camel-Case
        .replace(/\s+/g, '-') # spaced word => spaced-word
        .toLowerCase()

    getSystemAccentColor = ->
      switch process.platform
        when 'win32'
          getWindowsAccentColor()
        when 'darwin'
          getDarwinAccentColor()
        when 'linux'
          getLinuxAccentColor()

    getDarwinAccentColor = -> metro.set('themeAccentColor', '#0763D8') # Yosemite
    getLinuxAccentColor  = -> metro.set('themeAccentColor', '#E97A43') # Ubuntu

    getWindowsAccentColor = ->
      reg = new registry(hive: registry.HKLM, key: WINDOWS_RELEASE_KEY)
      reg.get(WINDOWS_RELEASE_VALUE, releaseCallback)

    releaseCallback = (error, item) ->
      if error # This should never happen
        metro.set('useSystemAccentColor', false)
      else
        release = item.value
        if release.match 'Windows 10'
          value = WINDOWS_10_ACCENT_VALUE
        else if release.match 'Windows 8'
          value = WINDOWS_8_ACCENT_VALUE
        else
          # Windows 7 and below, default to Windows blue
          metro.set('themeAccentColor', metro.config.themeAccentColor.default)
          return

        reg = new registry(hive: registry.HKCU, key: WINDOWS_ACCENT_KEY)
        reg.get(value, accentCallback)

    accentCallback = (error, item) ->
      if error # This should never happen
        metro.set('useSystemAccentColor', false)
      else
        color = ABGRtoRGB(item.value)
        metro.set('themeAccentColor', color)

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

    writeConfig = ->
      theme = normalize(metro.get('theme'))
      themeAccentColor = metro.get('themeAccentColor').toHexString()
      editorFontFamily = atom.config.get('editor.fontFamily')

      configData =
      """
        @editor-font-family: '#{editorFontFamily}';
        @theme-accent-color: #{themeAccentColor};
        @import 'themes/#{theme}';
      """

      # Save the file
      fs.writeFileSync(metro.configPath, configData)

    # Initialization
    initialize = (option) ->
      metro.onConfigChange option, -> set(option)
      set(option)

    requiresReload = (option) ->
      metro.onConfigChange option, ->
        writeConfig()

    initialize('theme')
    initialize('icons')
    initialize('displayMode')
    initialize('showGutterStyling')
    initialize('hideTreeDisclosureArrows')
    initialize('hideTreeVcsColoring')
    initialize('hideStatusBarFile')
    initialize('hideStatusBarCursor')
    initialize('hideStatusBarSelection')
    initialize('hideStatusBarLaunchMode')
    initialize('fullscreenStatusBar')

    requiresReload('theme')
    requiresReload('themeAccentColor')

    setFontSize()
    getSystemAccentColor() if metro.get('useSystemAccentColor')

    # Events
    metro.onConfigChange 'fontSize', -> setFontSize()
    metro.onConfigChange 'useSystemAccentColor', ->
      if metro.get('useSystemAccentColor')
        getSystemAccentColor()
