module.exports =
  config:
    theme:
      order: 1
      type: 'string'
      default: 'Light'
      enum: [
        'Light'
      ]

    themeAccentColor:
      order: 2
      type: 'color'
      default: '#0078D7'

    useSystemAccentColor:
      order: 3
      description: 'Theme accent color will automatically be determined based on your operating system'
      type: 'boolean'
      default: true

    icons:
      order: 4
      type: 'string'
      default: 'Octicons'
      enum: [
        'Octicons'
        'Windows 10'
      ]

    fontSize:
      order: 5
      description: 'Change the UI font size. (Between 10 and 20)'
      type: 'integer'
      minimum: 10
      maximum: 20
      default: 15

    displayMode:
      order: 6
      type: 'string'
      default: 'Spacious'
      enum: [
        'Spacious'
      ]

    showGutterStyling:
      order: 7
      description: 'Overrides syntax gutter styling for consistent styling'
      type: 'boolean'
      default: true

    hideTreeDisclosureArrows:
      order: 8
      description: 'Hides collapse/uncollapse icons from the tree view'
      type: 'boolean'
      default: true

    # NOTE: Remove 9 if Atom ever adds this configuration option to tree-view
    hideTreeVcsColoring:
      order: 9
      description: 'Hides version control status coloring from the tree view'
      type: 'boolean'
      default: false

    # NOTE: Remove 10-14 if Atom ever adds more configuration options to status-bar
    hideStatusBarFile:
      order: 10
      description: 'Hides file info from the status bar'
      type: 'boolean'
      default: false

    hideStatusBarCursor:
      order: 11
      description: 'Hides cursor position from the status bar'
      type: 'boolean'
      default: false

    hideStatusBarSelection:
      order: 12
      description: 'Hides line selection information from the status bar'
      type: 'boolean'
      default: false

    hideStatusBarLaunchMode:
      order: 13
      description: 'Hides the developer mode icon from the status bar'
      type: 'boolean'
      default: false

    fullscreenStatusBar:
      order: 14
      description: 'Stretches the status bar across the entire bottom much like Sublime, and Visual Studio Code'
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
