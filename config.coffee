#config file for brunch, see http://brunch.io

exports.config =
  # See http://brunch.readthedocs.org/en/latest/config.html for documentation.
  files:
    javascripts:
      joinTo:
        'js/shadowpattern.js': /^app/
        'js/vendor.js': /^vendor/
        'test/javascripts/test.js': /^test(\/|\\)(?!vendor)/
        'test/javascripts/test-vendor.js': /^test(\/|\\)(?=vendor)/
      order:
        before: []

    stylesheets:
      joinTo:
        'stylesheets/app.css': /^(app|vendor)/
        'test/stylesheets/test.css': /^test/
      order:
        before: []
        after: []

    templates:
      joinTo: 'js/templates.js'
  
  plugins:
    uglify:
      mangle: false
      compress:
        global_defs:
          DEBUG: false


