var gulp = require('gulp'),
    less = require('gulp-less'),
    uglify = require('gulp-uglify'),
    spawn = require('child_process').spawn,
    minifyCSS = require('gulp-minify-css'),
    browserify = require('browserify'),
    source = require('vinyl-source-stream'),
    sourcemaps = require('gulp-sourcemaps'),
    stringify = require('stringify'),
    buffer = require('vinyl-buffer');

var paths = {
    js: {
        app: {
            src: './web/static/js/app.js',
            dest: './priv/static/js/',
            watch: ['./web/static/js/*.js', './web/static/js/*/*.js', './web/static/js/*/*.html']
        },
        unmanaged: {
            src: './web/static/js/unmanaged/*',
            dest: './priv/static/js/'
        }
    },

    less: {
        src: './web/less/style.less',
        dest: './priv/static/css/',
        watch: ['./web/less/*.less'],
    },
    fonts: {
        src: './web/static/fonts/*',
        dest: './priv/static/fonts/',
    }

};

var create = function(src, name, dst) {
    var bundleStream = browserify(src);
    bundleStream.transform(stringify(['.html']));
    bundleStream.bundle()
        .pipe(source(name))
        .pipe(buffer())
        // .pipe(sourcemaps.init({
        //     loadMaps: true
        // }))
        // .pipe(uglify())
        // .pipe(sourcemaps.write('maps'))
        .pipe(gulp.dest(dst));
};


gulp.task('app', function() {
    create(paths.js.app.src, 'app.js', paths.js.app.dest);
    console.log(paths.js.unmanaged.src, paths.js.unmanaged.dest)
    gulp.src(paths.js.unmanaged.src)
        .pipe(gulp.dest(paths.js.unmanaged.dest));
});

gulp.task('less', function() {
    console.log("Rebuilding less files...");
    gulp.src(paths.less.src)
        .pipe(less({
            paths: ['style.less']
        }))
        .pipe(minifyCSS())
        .pipe(gulp.dest(paths.less.dest));
});

gulp.task('fonts', function() {
    console.log("Adding fonts...");
    gulp.src(paths.fonts.src)
        .pipe(gulp.dest(paths.fonts.dest))
});


gulp.task('rebuild', function() {

    gulp.watch(paths.js.app.watch, ['app']);
    gulp.watch(paths.less.watch, ['less']);
});


gulp.task('watch', ['app', 'less', 'fonts', 'rebuild']);
gulp.task('deploy', ['app', 'less', 'fonts']);