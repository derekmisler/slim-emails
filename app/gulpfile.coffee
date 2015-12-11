###eslint-env node ###

gulp = require('gulp')
sass = require('gulp-sass')
autoprefixer = require('gulp-autoprefixer')
browserSync = require('browser-sync').create()
coffee = require('gulp-coffee')
coffeelint = require('gulp-coffeelint')
concat = require('gulp-concat')
uglify = require('gulp-uglify')
sourcemaps = require('gulp-sourcemaps')
imagemin = require('gulp-imagemin')
pngquant = require('imagemin-pngquant')

gulp.task 'serve', [
  'copy-html'
  'copy-images'
  'scripts-dist'
  'styles'
], ->
  gulp.watch 'stylesheets/**/*.scss', [ 'styles' ]
  gulp.watch '*.html', [ 'copy-html' ]
  gulp.watch('./dist/**/*').on 'change', browserSync.reload
  browserSync.init server: './dist'
  return

# regular build task if I don't want to watch anything
gulp.task 'build', [
  'copy-html'
  'copy-images'
  'styles'
  'scripts-dist'
]

# Convert coffee to js, minify and move to dist
gulp.task 'scripts-dist', ->
  gulp.src('js/**/*.coffee')
    .pipe(sourcemaps.init())
    .pipe(coffee())
    .pipe(concat('scripts.min.js'))
    .pipe(uglify())
    .pipe(sourcemaps.write())
    .pipe gulp.dest('dist/js')

# lint coffeescript
gulp.task 'lint', ->
  gulp.src([
    '**/*.coffee'
    '!node_modules/**'
  ])
    .pipe(coffeelint())
    .pipe(coffeelint.reporter())

# Copy html to dist
gulp.task 'copy-html', ->
  gulp.src('./index.html')
    .pipe gulp.dest('dist')

# Minify pngs and copy images to dist folder
gulp.task 'copy-images', ->
  gulp.src('img/*').pipe(imagemin(
    progressive: true
    use: [ pngquant() ])).pipe gulp.dest('dist/img')

# Create the CSS from Sass, autoprefix and minify
gulp.task 'styles', ->
  gulp.src('stylesheets/main.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(autoprefixer(browsers: [ 'last 2 versions' ]))
    .pipe(sass(outputStyle: 'compressed'))
    .pipe(gulp.dest('dist/css'))
    .pipe browserSync.stream()
