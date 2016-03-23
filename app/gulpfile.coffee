###eslint-env node ###

gulp = require 'gulp'
sass = require 'gulp-sass'
autoprefixer = require 'gulp-autoprefixer'
browserSync = require('browser-sync').create()
uglify = require 'gulp-uglify'
coffee = require 'gulp-coffee'
imagemin = require 'gulp-imagemin'
pngquant = require 'imagemin-pngquant'
inlineCss = require 'gulp-inline-css'
slim = require 'gulp-slim'

gulp.task 'serve', [
  'slim'
  'copy-images'
  'styles'
], ->
  gulp.watch 'stylesheets/**/*.scss', [ 'styles' ]
  gulp.watch '*.slim', [ 'slim' ]
  gulp.watch('./dist/**/*').on 'change', browserSync.reload
  browserSync.init server: './dist'
  return

# regular build task if I don't want to watch anything
gulp.task 'build', [
  'slim'
  'copy-images'
  'styles'
  'inlineCss'
]

# Convert slim to html and move to dist
gulp.task 'slim', ->
  return gulp.src('*.slim')
    .pipe slim pretty: true
    .pipe gulp.dest 'dist'

# Minify pngs and copy images to dist folder
gulp.task 'copy-images', ->
  gulp.src('img/*').pipe(imagemin(
    progressive: true
    use: [ pngquant() ])).pipe gulp.dest('dist/img')

# Create the CSS from Sass, autoprefix and minify
gulp.task 'styles', ['slim'], ->
  return gulp.src('stylesheets/main.scss')
    .pipe(sass().on('error', sass.logError))
    .pipe(autoprefixer(browsers: [ 'last 2 versions' ]))
    .pipe(sass(outputStyle: 'compressed'))
    .pipe(gulp.dest('dist/css'))
    .pipe browserSync.stream()

# inline css
gulp.task 'inlineCss', ['styles'], ->
  return gulp.src('dist/*.html')
    .pipe(inlineCss(
      applyLinkTags: true,
      applyStyleTags: false,
      removeStyleTags: false,
      removeLinkTags: false))
    .pipe gulp.dest 'dist'

