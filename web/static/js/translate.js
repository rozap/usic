
var terms = {
  'invalid_youtube' : 'Not a valid youtube link',
  'getting_song': 'Fetching the video...',
  'video_retrieved': 'Video retrieved, downloading audio and building waveform...',
  'download_failed': 'Audio extraction failed. Try a different video.',
  'success' : 'Huzzah!',
  'api_channel_error': 'Failed to register with persistence layer. Changes will not be saved.',
  'socket_error': 'Encountered an error with the websocket connection. Changes will not be saved.',
  'dismiss_error': 'Dismiss',
  'account_created': 'Your account has been created. You can now log in.',
  'account_create_failed': 'Failed to create your account!'
};

module.exports = {
  t : function(key) {
    return terms[key] || key;
  }
};