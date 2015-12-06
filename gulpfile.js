var gulp = require('gulp');
var runSequence = require('run-sequence');
var argv = require('yargs').argv;
var p = require('./package.json');

var plugins = require('gulp-load-plugins')(
  {
    rename: {
      'gulp-minify-css': 'minifyCSS',
      'gulp-rev-replace': 'revReplace'
    }
  });

var apps = [
  {
    name: '',
    tasks: {
      scripts: {
        src: [
          'bower_components/jquery1x/dist/jquery.js',
          'bower_components/bootstrap-sass/assets/javascripts/bootstrap/transition.js',
          'bower_components/bootstrap-sass/assets/javascripts/bootstrap/collapse.js',
          'bower_components/social-likes/social-likes.min.js',
          'lib/assets/javascripts/**/*.+(coffee|js)',
          '_/app/assets/javascripts/**/*.+(coffee|js)'
        ],
        dest: 'public/assets'
      },
      styles: {
        src: ['_/app/assets/stylesheets/app.scss'],
        dest: 'public/assets'
      },
      html: {
        src: ['_/app/index.html'],
        dest: 'public'
      },
      fonts: {
        src: ['bower_components/font-awesome/fonts/fontawesome-webfont.*'],
        dest: 'public/assets'
      },
      cp: {
        src: ['_/cp/*'],
        dest: 'public'
      },
      images: {
        src: ['_/app/assets/images/**/*'],
        dest: 'public/assets'
      }
    },
    build: ['scripts:', 'styles:', ['html:', 'fonts:', 'cp:', 'images:']]
  },
  {
    name: 'about',
    tasks: {
      scripts: {
        src: [
          'bower_components/jquery1x/dist/jquery.js',
          'bower_components/bootstrap-sass/assets/javascripts/bootstrap/transition.js',
          'bower_components/bootstrap-sass/assets/javascripts/bootstrap/collapse.js',
          'lib/assets/javascripts/**/*.+(coffee|js)',
          '_about/app/assets/javascripts/**/*.+(coffee|js)'
        ],
        dest: 'public/about/assets'
      },
      styles: {
        src: ['_about/app/assets/stylesheets/app.scss'],
        dest: 'public/about/assets'
      },
      html: {
        src: ['_about/app/index.html'],
        dest: 'public/about'
      },
      fonts: {
        src: ['bower_components/font-awesome/fonts/fontawesome-webfont.*'],
        dest: 'public/about/assets'
      },
    },
    build: ['scripts:about', 'styles:about', ['html:about', 'fonts:about']]
  },
  {
    name: 'i',
    tasks: {
      scripts: {
        src: [
          'bower_components/fontfaceobserver/fontfaceobserver.js',

          'bower_components/jquery/dist/jquery.js',

          'bower_components/jquery-ui/ui/core.js',
          'bower_components/jquery-ui/ui/widget.js',
          'bower_components/jquery-ui/ui/mouse.js',
          'bower_components/jquery-ui/ui/position.js',
          'bower_components/jquery-ui/ui/draggable.js',
          'bower_components/jquery-ui/ui/droppable.js',
          'bower_components/jquery-ui/ui/sortable.js',

          'bower_components/lodash/lodash.min.js',
          'bower_components/backbone/backbone.js',
          'bower_components/backbone.marionette/lib/backbone.marionette.js',

          // TODO только нужные компоненты
          'bower_components/bootstrap-sass/assets/javascripts/bootstrap.js',

          'bower_components/routefilter/src/backbone.routefilter.js',
          'bower_components/backbone.mutators/backbone.mutators.js',
          '_i/vendor/assets/javascripts/plugin/backbone.chooser.coffee',

          'bower_components/jquery-validation/dist/jquery.validate.js',
          'bower_components/jquery-validation/src/localization/messages_ru.js',

          'bower_components/bootstrap-notify/js/bootstrap-notify.js',
          'bower_components/nprogress/nprogress.js',
          'bower_components/d3/d3.js',
          'bower_components/plupload/js/plupload.full.min.js',
          'bower_components/underscore.string/dist/underscore.string.js',

          'bower_components/select2/select2.js',
          'bower_components/select2/select2_locale_ru.js',

          'bower_components/bootstrap-datepicker/js/bootstrap-datepicker.js',
          'bower_components/bootstrap-datepicker/js/locales/bootstrap-datepicker.ru.js',

          'bower_components/moment/moment.js',
          'bower_components/moment/locale/ru.js',

          '_i/vendor/assets/javascripts/plugin/jquery.treetable.js',

          'lib/assets/javascripts/**/*.+(coffee|js)',

          '_i/app/assets/javascripts/config/**/*.+(coffee|js)',

          '_i/app/assets/javascripts/backbone/app.coffee',
          '_i/app/assets/javascripts/backbone/lib/entities/**/*.+(coffee|js)',
          '_i/app/assets/javascripts/backbone/lib/utilities/**/*.+(coffee|js)',
          '_i/app/assets/javascripts/backbone/lib/views/**/*.+(coffee|js)',
          '_i/app/assets/javascripts/backbone/lib/controllers/**/*.+(coffee|js)',
          '_i/app/assets/javascripts/backbone/lib/components/**/*.+(coffee|js|eco)',

          '_i/app/assets/javascripts/backbone/entities/**/*.coffee',
          '_i/app/assets/javascripts/backbone/apps/**/*.+(coffee|js|eco)',
          '_i/app/assets/javascripts/app.coffee'
        ],
        dest: 'public/i/assets'
      },
      styles: {
        src: ['_i/app/assets/stylesheets/app.scss'],
        dest: 'public/i/assets'
      },
      html: {
        src: ['_i/app/index.html'],
        dest: 'public/i'
      },
      fonts: {
        src: ['bower_components/font-awesome/fonts/fontawesome-webfont.*'],
        dest: 'public/i/assets'
      }
    },
    build: ['scripts:i', 'styles:i', ['html:i', 'fonts:i']]
  },
  {
    name: 'signin',
    tasks: {
      scripts: {
        src: [
          'bower_components/jquery1x/dist/jquery.js',
          'bower_components/jquery-validation/dist/jquery.validate.js',
          'bower_components/jquery-validation/src/localization/messages_ru.js',
          'lib/assets/javascripts/**/*.+(coffee|js)',
          '_signin/app/assets/javascripts/**/*.+(coffee|js)'
        ],
        dest: 'public/signin/assets'
      },
      styles: {
        src: ['_signin/app/assets/stylesheets/app.scss'],
        dest: 'public/signin/assets'
      },
      html: {
        src: ['_signin/app/index.html'],
        dest: 'public/signin'
      }
    },
    build: ['scripts:signin', 'styles:signin', 'html:signin']
  },
  {
    name: 'signup',
    tasks: {
      scripts: {
        src: [
          'bower_components/jquery1x/dist/jquery.js',
          'bower_components/jquery-validation/dist/jquery.validate.js',
          'bower_components/jquery-validation/src/localization/messages_ru.js',
          'bower_components/bootstrap-sass/assets/javascripts/bootstrap/modal.js',
          'lib/assets/javascripts/**/*.+(coffee|js)',
          '_signup/app/assets/javascripts/**/*.+(coffee|js)'
        ],
        dest: 'public/signup/assets'
      },
      styles: {
        src: ['_signup/app/assets/stylesheets/app.scss'],
        dest: 'public/signup/assets'
      },
      html: {
        src: ['_signup/app/index.html'],
        dest: 'public/signup'
      }
    },
    build: ['scripts:signup', 'styles:signup', 'html:signup']
  },
  {
    name: 'signup_confirm',
    tasks: {
      scripts: {
        src: [
          'bower_components/jquery1x/dist/jquery.js',
          'lib/assets/javascripts/**/*.+(coffee|js)',
          '_signup__confirm/app/assets/javascripts/**/*.+(coffee|js)'
        ],
        dest: 'public/signup/confirm/assets'
      },
      styles: {
        src: ['_signup__confirm/app/assets/stylesheets/app.scss'],
        dest: 'public/signup/confirm/assets'
      },
      html: {
        src: ['_signup__confirm/app/index.html'],
        dest: 'public/signup/confirm'
      }
    },
    build: ['scripts:signup_confirm', 'styles:signup_confirm', 'html:signup_confirm']
  },
  {
    name: 'password_recovery',
    tasks: {
      scripts: {
        src: [
          'bower_components/jquery1x/dist/jquery.js',
          'bower_components/jquery-validation/dist/jquery.validate.js',
          'bower_components/jquery-validation/src/localization/messages_ru.js',
          'lib/assets/javascripts/**/*.+(coffee|js)',
          '_password_recovery/app/assets/javascripts/**/*.+(coffee|js)'
        ],
        dest: 'public/password_recovery/assets'
      },
      styles: {
        src: ['_password_recovery/app/assets/stylesheets/app.scss'],
        dest: 'public/password_recovery/assets'
      },
      html: {
        src: ['_password_recovery/app/index.html'],
        dest: 'public/password_recovery'
      }
    },
    build: ['scripts:password_recovery', 'styles:password_recovery', 'html:password_recovery']
  },
  {
    name: 'password_recovery_confirm',
    tasks: {
      scripts: {
        src: [
          'bower_components/jquery1x/dist/jquery.js',
          'bower_components/jquery-validation/dist/jquery.validate.js',
          'bower_components/jquery-validation/src/localization/messages_ru.js',
          'lib/assets/javascripts/**/*.+(coffee|js)',
          '_password_recovery__confirm/app/assets/javascripts/**/*.+(coffee|js)'
        ],
        dest: 'public/password_recovery/confirm/assets'
      },
      styles: {
        src: ['_password_recovery__confirm/app/assets/stylesheets/app.scss'],
        dest: 'public/password_recovery/confirm/assets'
      },
      html: {
        src: ['_password_recovery__confirm//app/index.html'],
        dest: 'public/password_recovery/confirm'
      }
    },
    build: ['scripts:password_recovery_confirm', 'styles:password_recovery_confirm', 'html:password_recovery_confirm']
  }
];

var onError = function (err) {
  //plugins.util.beep();
  console.log(err);

  this.emit('end');
};

function construct_scripts(app) {
  gulp.task('scripts:' + app.name, function () {
    //(app.js.src).forEach(fs.statSync);
    return gulp.src(app.tasks.scripts.src)
      .pipe(plugins.cached('scripts:' + app.name))
      //.pipe(plugins.plumber({errorHandler: onError}))
      .pipe(plugins.plumber({
        errorHandler: plugins.notify.onError(
          {
            title: "<%= error.plugin %>",
            subtitle: "<%= error.filename.split('/').slice(-3).join('/') %>",
            message: " <%= error.location.first_line + ':'+ error.location.first_column + ' ' + error.message %>",
            //message: "<%= error.message %>",
            sound: 'Glass'
          }
        )
      }))

      .pipe(plugins.if(argv.production, plugins.replace('{server}', p.productionServer)))
      .pipe(plugins.if(!argv.production, plugins.replace('{server}', p.devServer)))

      .pipe(plugins.if(/[.]coffee$/, plugins.coffeelint({max_line_length: {value: 200}})))
      .pipe(plugins.if(/[.]coffee$/, plugins.coffeelint.reporter()))
      .pipe(plugins.if(/[.]coffee$/, plugins.coffee({bare: true})/*.on('error', plugins.util.log)*/))
      //.pipe(plugins.rename(function (path) {
      //  // Убираем .js из названия. Так исходный файл называется filename.js.coffee
      //  path.basename = path.basename.replace(/[.]js$/, '');
      //}))
      //.pipe(plugins.if(/[.]eco$/, plugins.rename(function (path) {
      //  // Убираем .jst из названия. Так исходный файл называется filename.jst.eco
      //  path.basename = path.basename.replace(/[.]jst$/, '');
      //})))
      .pipe(plugins.if(/[.]eco$/, plugins.eco({basePath: 'app/assets/javascripts'})))

      // бОльшая часть кода написана на CoffeeScript, поэтому JavaScript не будем проверять
      //.pipe(plugins.jshint({eqnull: true}))
      //.pipe(plugins.jshint.reporter())
      .pipe(plugins.remember('scripts:' + app.name))
      .pipe(plugins.plumber.stop())
      .pipe(plugins.if(!argv.production, plugins.sourcemaps.init()))
      .pipe(plugins.if(argv.production, plugins.uglify()))
      .pipe(plugins.concat('app.js'))
      //.pipe(plugins.concat({path: 'app.js', cwd: ''}))
      .pipe(plugins.if(argv.production, plugins.rev()))
      .pipe(plugins.if(!argv.production, plugins.sourcemaps.write('./')))
      .pipe(gulp.dest(app.tasks.scripts.dest))
      .pipe(plugins.if(argv.production, plugins.rev.manifest(app.tasks.scripts.dest + '/rev-manifest.json', {merge: true})))
      .pipe(plugins.if(argv.production, gulp.dest('')));
    //.pipe(plugins.gzip())
    //.pipe(gulp.dest(app.tasks.scripts.dest));

  });
}

function construct_styles(app) {
  gulp.task('styles:' + app.name, function () {
    return gulp.src(app.tasks.styles.src)
      .pipe(plugins.if(!argv.production, plugins.sourcemaps.init()))
      .pipe(plugins.sass().on('error', plugins.sass.logError))
      .pipe(plugins.minifyCSS({processImport: true, advanced: false}))
      .pipe(plugins.if(argv.production, plugins.rev()))
      .pipe(plugins.if(!argv.production, plugins.sourcemaps.write('./')))
      .pipe(gulp.dest(app.tasks.styles.dest))
      .pipe(plugins.if(argv.production, plugins.rev.manifest(app.tasks.styles.dest + '/rev-manifest.json', {merge: true})))
      .pipe(plugins.if(argv.production, gulp.dest('')));
  });
}

function construct_html(app) {
  gulp.task('html:' + app.name, function () {
    var manifest = gulp.src("./" + app.tasks.html.dest + "/assets/rev-manifest.json");
    return gulp.src(app.tasks.html.src)
      .pipe(plugins.if(argv.production, plugins.rigger()))
      .pipe(plugins.replace('{version}', p.version))
      .pipe(plugins.if(argv.production, plugins.revReplace({manifest: manifest})))
      .pipe(gulp.dest(app.tasks.html.dest));
  });
}

function construct_fonts(app) {
  if (!app.tasks.fonts) return;
  gulp.task('fonts:' + app.name, function () {
    return gulp.src(app.tasks.fonts.src)
      .pipe(gulp.dest(app.tasks.fonts.dest));
  });
}

// Простое копирование файлов
function construct_cp(app) {
  if (!app.tasks.cp) return;
  gulp.task('cp:' + app.name, function () {
    return gulp.src(app.tasks.cp.src)
      .pipe(gulp.dest(app.tasks.cp.dest));
  });
}

function construct_images(app) {
  if (!app.tasks.images) return;
  gulp.task('images:' + app.name, function () {
    return gulp.src(app.tasks.images.src)
      .pipe(gulp.dest(app.tasks.images.dest));
  });
}

function construct_build(app) {
  gulp.task('build:' + app.name, function () {

    callback = function () {
      console.log('build:' + app.name + ' done');
    };

    runSequence.apply(this, app.build.concat(callback));
  });
}

var builds = [];
for (var i = 0; i < apps.length; i++) {
  construct_scripts(apps[i]);
  construct_styles(apps[i]);
  construct_html(apps[i]);
  construct_fonts(apps[i]);
  construct_cp(apps[i]);
  construct_images(apps[i]);

  construct_build(apps[i]);

  builds.push('build:' + apps[i].name);
}

gulp.task('build', builds);

gulp.task('watch', ['build'], function () {
  for (var i = 0; i < apps.length; i++) {
    for (var key in apps[i].tasks) {
      if (apps[i].tasks.hasOwnProperty(key)) {
        gulp.watch(apps[i].tasks[key].src, [key + ':' + apps[i].name]);
      }
    }
  }
});

gulp.task('default', ['watch']);
