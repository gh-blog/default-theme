# Less = require 'less'
through2 = require 'through2'
File = require 'vinyl'
fs = require 'fs'
Path = require 'path'
recursive = require 'recursive-readdir'
async = require 'async'

module.exports = (options) ->
    # lessPath = "#{__dirname}/styles/main.less"
    cssPath = '../styles/main.css'

    css = (done) ->
        async.waterfall [
            (callback) -> fs.readFile "#{__dirname}/dist/main.css", callback
            (cssBuffer, callback) ->
                file = new File {
                    path: cssPath
                    contents: cssBuffer
                }
                callback null, file
        ], done

    fonts = (done) ->
        async.waterfall [
            (callback) ->
                recursive "#{__dirname}/dist", ['*.css'], callback
            (paths, done) ->
                async.map paths, (path, callback) ->
                    relative = Path.relative "#{__dirname}/dist", path
                    relative = Path.join '../styles', relative
                    callback null, new File {
                        path: relative
                        contents: fs.readFileSync path
                    }
                , done
        ], done

    processFile = (file, enc, done) ->
        if file.isPost
            file.styles.push cssPath
        done null, file

    through2.obj processFile, (done) ->
        async.parallel { css, fonts }, (err, results) =>
            @push results.css
            @push file for file in results.fonts
            done()