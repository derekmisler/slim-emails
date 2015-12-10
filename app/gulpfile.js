/*eslint-env node */

var gulp = require('gulp');
var sass = require('gulp-sass');
var autoprefixer = require('gulp-autoprefixer');
var browserSync = require('browser-sync').create();
// var eslint = require('gulp-eslint');
var concat = require('gulp-concat');
var uglify = require('gulp-uglify');
var sourcemaps = require('gulp-sourcemaps');
var imagemin = require('gulp-imagemin');
var pngquant = require('imagemin-pngquant');
var coffee = require('gulp-coffee');

gulp.task('serve', ['copy-html', 'copy-images', 'scripts-dist', 'styles'], function() {
  gulp.watch('stylesheets/**/*.scss', ['styles']);
  // gulp.watch('js/**/*.js', ['lint']);
  // gulp.watch('js/**/*.coffee', ['scripts-dist']);
  gulp.watch('*.html', ['copy-html']);
  gulp.watch('./dist/**/*').on('change', browserSync.reload);
  
  browserSync.init({
    server: './dist'
  });
});

gulp.task('lint', function () {
  return gulp.src(['**/*.js','!node_modules/**'])
    .pipe(eslint())
    .pipe(eslint.format())
    .pipe(eslint.failAfterError());
});

gulp.task('dist', [
  'copy-html',
  'copy-images',
  'styles',
  'lint',
  'scripts-dist'
]);

gulp.task('scripts-dist', function() {
  gulp.src('js/**/*.coffee')
      .pipe(sourcemaps.init())
      .pipe(coffee())
      .pipe(concat('scripts.min.js'))
      .pipe(uglify())
      .pipe(sourcemaps.write())
      .pipe(gulp.dest('dist/js'));
});

gulp.task('copy-html', function() {
  gulp.src('./index.html')
      .pipe(gulp.dest('dist'));
});

gulp.task('copy-images', function() {
  return gulp.src('img/*')
      .pipe(imagemin({
        progressive: true,
        use: [pngquant()]
      }))
      .pipe(gulp.dest('dist/img'));
});

gulp.task('styles', function () {
  return gulp.src('stylesheets/main.scss')
      .pipe(sass().on('error', sass.logError))
      .pipe(autoprefixer({
        browsers: ['last 2 versions']
      }))
      .pipe(sass({outputStyle: 'compressed'}))
      .pipe(gulp.dest('dist/css'))
      .pipe(browserSync.stream());
});