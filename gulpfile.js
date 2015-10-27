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
            watch: ['./web/static/js/*.js']
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


gulp.task('watch', function() {

    gulp.watch(paths.js.app.watch, ['app']);
    gulp.watch(paths.less.watch, ['less']);
});


gulp.task('default', ['app', 'less', 'watch']);
gulp.task('deploy', ['app', 'less']);