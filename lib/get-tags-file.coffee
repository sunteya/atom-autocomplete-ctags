path = require 'path'
fs = require 'fs'
glob = require 'glob'

isFileAsync = (filePath) ->
  new Promise((resolve, reject) ->
    fs.stat(filePath, (err, stats) ->
      if err
        resolve(false)
      else
        resolve(stats.isFile())
    )
  )

module.exports = (directoryPath) ->
  return Promise.reject() unless directoryPath?

  new Promise (resolve) ->
    globFilePaths = ['tags', 'TAGS', '.tags', '.TAGS', '.git/tags', '.git/TAGS', '*.tags'].map((fileName) ->
      glob.sync(path.join(directoryPath, fileName))
    )
    filePaths = [].concat.apply([], globFilePaths)

    promises = filePaths.map((filePath) ->
      isFileAsync(filePath)
    )

    Promise.all(promises).then((results) ->
      for result, idx in results
        return resolve(filePaths[idx]) if result

      resolve(false)
    )
