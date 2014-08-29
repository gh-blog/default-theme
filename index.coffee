# Less = require 'less'
through2 = require 'through2'
File = require 'vinyl'
fs = require 'fs'
Path = require 'path'
recursive = require 'recursive-readdir'
async = require 'async'

module.exports = (options) ->
    # lessPath = "#{__dirname}/styles/main.less"
    cssPath = 'styles/main.css'

    css = (done) ->
        async.waterfall [
            (callback) -> fs.readFile "#{__dirname}/dist/main.css", done
            (css, callback) ->
                console.log 'CSS', css
                callback null, new File {
                    path: cssPath
                    contents: new Buffer css
                }
        ], done

    fonts = (done) ->
        async.waterfall [
            (callback) ->
                recursive "#{__dirname}/dist/fonts", callback
            (paths, done) ->
                async.map paths, (path, callback) ->
                    callback null, new File {
                        path: path
                        contents: fs.readFileSync path
                    }
                , done
        ], done

    processFile = (file, enc, done) ->
        if file.isPost
            file.styles.push cssPath
        done null, file

    through2.obj processFile, (done) ->
        async.parallel { css, fonts }, (err, results) ->
            @push results.css
            @push file for file in results.fonts
            done()