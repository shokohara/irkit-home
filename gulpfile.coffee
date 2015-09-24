gulp = require('gulp')
plugins = require('gulp-load-plugins')()
mainBowerFiles = require('main-bower-files')
runSequence = require('run-sequence')
merge2 = require('merge2')
del = require('del')
proxy = require('proxy-middleware')
connectModrewrite = require('connect-modrewrite')
browserSync = require('browser-sync').create()
notifier = require('node-notifier')

gulp.task 'clean', (cb)-> del(['cache', 'build'], cb)

gulp.task 'js-cache', ->
  gulp.src mainBowerFiles(checkExistence: true, filter: "**/*.js")
  .pipe plugins.concat('libs.js')
  .pipe gulp.dest('cache')

gulp.task 'js', ->
  bower = -> gulp.src 'cache/libs.js'
  handler =
    errorHandler: plugins.notify.onError('<%= error.message %>')
  coffee = ->
    gulp.src 'src/coffee/**/*.coffee'
#    .pipe plugins.plumber(handler)
    .pipe plugins.coffee()
  merge2(bower(), coffee())
  .pipe plugins.concat('main.js')
  .pipe gulp.dest('build/js')

gulp.task 'less', ->
  gulp.src 'src/less/main.less'
  .pipe plugins.rename('main.less')
  .pipe plugins.less(mainBowerFiles(checkExistence: true, filter: "**/*.less"))
  .pipe gulp.dest('build/css')

gulp.task 'jade', ->
  handler =
    errorHandler: plugins.notify.onError('<%= error.message %>')
  gulp.src('src/**/*.jade')
  .pipe plugins.plumber(handler)
  .pipe plugins.jade()
  .pipe gulp.dest('build')

gulp.task 'images', ->
  gulp.src 'src/image/**/*'
  .pipe gulp.dest('build/assets/images')
  .pipe gulp.dest('build/images')

gulp.task 'fonts', ->
  gulp.src ['bower_components/bootstrap/fonts/*', 'bower_components/components-font-awesome/fonts/*']
  .pipe gulp.dest('build/fonts')

gulp.task 'misc', ->
  gulp.src 'src/misc/*'
  .pipe gulp.dest('build')

gulp.task 'browser-sync', ->
  browserSync.init
    server:
      baseDir: "./build"
      middleware: [connectModrewrite(['^[^\\.]*$ /index.html [L]'])]
    ghostMode:
      forms: false

gulp.task 'js-reload', ['js'], -> browserSync.reload()
gulp.task 'less-reload', ['less'], -> browserSync.reload()
gulp.task 'jade-reload', ['jade'], -> browserSync.reload()

gulp.task 'reload', -> browserSync.reload()

gulp.task 'default', ->
  runSequence('clean', 'js-cache', 'js', 'less', 'jade', 'images', 'fonts', 'misc', 'browser-sync')
  gulp.watch 'src/**/*.coffee', ['js-reload']
  gulp.watch 'src/**/*.less', ['less-reload']
  gulp.watch 'src/**/*.jade', ['jade-reload']

gulp.task 'dist-clean', (cb)-> del('dist', cb)

gulp.task 'dist-js', ->
  bower = -> gulp.src mainBowerFiles(checkExistence: true, filter: "**/*.js")
  coffee = ->
    gulp.src 'src/coffee/**/*.coffee'
    .pipe plugins.coffee()
  merge2(bower(), coffee())
  .pipe plugins.concat('main.js')
  .pipe plugins.uglify()
  .pipe gulp.dest('dist/js')

gulp.task 'dist-less', ->
  gulp.src 'src/less/main.less'
  .pipe plugins.rename('main.less')
  .pipe plugins.less(mainBowerFiles(checkExistence: true, filter: "**/*.less"))
  .pipe plugins.minifyCss()
  .pipe gulp.dest('dist/css')

gulp.task 'dist-images', ->
  gulp.src 'src/image/**/*'
  .pipe gulp.dest('dist/assets/images')
  .pipe gulp.dest('dist/images')

gulp.task 'dist-fonts', ->
  gulp.src ['bower_components/bootstrap/fonts/*', 'bower_components/components-font-awesome/fonts/*']
  .pipe gulp.dest('dist/fonts')

gulp.task 'dist-jade', ->
  gulp.src('src/**/*.jade')
  .pipe plugins.jade()
  .pipe plugins.htmlmin()
  .pipe gulp.dest('dist')

gulp.task 'dist-misc', ->
  gulp.src 'src/misc/*'
  .pipe gulp.dest('dist')

gulp.task 'dist-gzip', ->
  gulp.src 'dist/**/*'
  .pipe plugins.gzip()
  .pipe gulp.dest('build')

gulp.task 'build', ->
  runSequence('dist-clean', 'dist-js', 'dist-less', 'dist-images', 'dist-fonts', 'dist-jade', 'dist-misc', 'dist-gzip')
