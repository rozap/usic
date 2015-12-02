
var terms = {
  'load_state_invalid_link': 'Invalid youtube URL',
  'load_state_loading': 'Loading the video',
  'load_state_error': 'Error loading the video',
  'load_state_success': 'Video loaded, building waveform for',
  'unknown_vid': 'Unknown Video',
  'upstream_timeout': 'Timed out while loading the video',


  'success' : 'Huzzah!',
  'api_channel_error': 'Failed to register with persistence layer. Changes will not be saved.',
  'socket_error': 'Encountered an error with the websocket connection. Changes will not be saved.',
  'minimize_error': 'Minimize this message.',
  'account_created': 'Your account has been created, and you have been logged in.',
  'account_create_failed': 'Failed to create your account! ;_;',
  'login_failed' : 'Login failed!',
  'unknown_email': 'that email is not registered',
  'invalid_password': 'that password is wrong',
  'login_success' : 'You have been logged in',
  'last_updated': 'last updated',
  'my_transcriptions': 'my transcriptions',
  'all_transcriptions': 'all transcriptions'
};

module.exports = {
  t : function(key) {
    return terms[key] || key;
  }
};