
var terms = {
  'invalid_youtube' : 'Not a valid youtube link',
  'getting_song': 'Fetching the video...',
  'video_retrieved': 'Video retrieved, downloading audio and building waveform...',
  'download_failed': 'Audio extraction failed. Try a different video.',
  'success' : 'Huzzah!'
}


module.exports = {
  t : function(key) {
    return terms[key] || key;
  }
}