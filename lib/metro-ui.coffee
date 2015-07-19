module.exports =
  config:
    theme:
      order: 1
      type: 'string'
      default: 'Light'
      enum: [
        'Light'
      ]

    icons:
      order: 2
      type: 'string'
      default: 'Octicons'
      enum: [
        'Octicons'
        'Windows 10'
      ]

    fontSize:
      order: 3
      description: 'Change the UI font size. (Between 10 and 20)'
      type: 'integer'
      minimum: 10
      maximum: 20
      default: 15

    displayMode:
      order: 4
      type: 'string'
      default: 'Spacious'
      enum: [
        'Spacious'
      ]

    useSystemAccentColor:
      order: 5
      type: 'boolean'
      default: true

    themeAccentColor:
      order: 6
      description: 'Accent color'
      type: 'color'
      default: '#0078D7'

    showGutterStyling:
      order: 7
      type: 'boolean'
      default: true

    hideTreeDisclosureArrows:
      order: 8
      type: 'boolean'
      default: true

    # FIXME: Remove 9-13 if Atom ever adds more configuration options to status-bar
    hideStatusBarFile:
      order: 9
      type: 'boolean'
      default: false

    hideStatusBarCursor:
      order: 10
      type: 'boolean'
      default: false

    hideStatusBarSelection:
      order: 11
      type: 'boolean'
      default: false

    hideStatusBarLaunchMode:
      order: 12
      type: 'boolean'
      default: false

    fullscreenStatusBar:
      order: 13
      type: 'boolean'
      default: false


  # Constants
  configPath: "#{__dirname}/../styles/config.less"

  # Configuration helpers
  get: (key) -> atom.config.get("metro-ui.#{key}")
  set: (key, value) -> atom.config.set("metro-ui.#{key}", value)

  # Events
  onConfigChange: (key, callback) ->
    atom.config.onDidChange("metro-ui.#{key}", callback)

  activate: (state) ->
    atom.themes.onDidChangeActiveThemes ->
      Config = require './config'
      Config.apply()
