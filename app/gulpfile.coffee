###eslint-env node ###

gulp = require('gulp')
sass = require('gulp-sass')
autoprefixer = require('gulp-autoprefixer')
browserSync = require('browser-sync').create()
eslint = require('gulp-eslint')
concat = require('gulp-concat')
uglify = require('gulp-uglify')
sourcemaps = require('gulp-sourcemaps')
imagemin = require('gulp-imagemin')
pngquant = require('imagemin-pngquant')
coffee = require('gulp-coffee')
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
gulp.task 'lint', ->
  gulp.src([
    '**/*.js'
    '!node_modules/**'
  ]).pipe(eslint()).pipe(eslint.format()).pipe eslint.failAfterError()
gulp.task 'build', [
  'copy-html'
  'copy-images'
  'styles'
  'scripts-dist'
]
gulp.task 'scripts-dist', ->
  gulp.src('js/**/*.coffee').pipe(sourcemaps.init()).pipe(coffee()).pipe(concat('scripts.min.js')).pipe(uglify()).pipe(sourcemaps.write()).pipe gulp.dest('dist/js')
  return
gulp.task 'copy-html', ->
  gulp.src('./index.html').pipe gulp.dest('dist')
  return
gulp.task 'copy-images', ->
  gulp.src('img/*').pipe(imagemin(
    progressive: true
    use: [ pngquant() ])).pipe gulp.dest('dist/img')
gulp.task 'styles', ->
  gulp.src('stylesheets/main.scss').pipe(sass().on('error', sass.logError)).pipe(autoprefixer(browsers: [ 'last 2 versions' ])).pipe(sass(outputStyle: 'compressed')).pipe(gulp.dest('dist/css')).pipe browserSync.stream()
