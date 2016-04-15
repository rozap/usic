
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
  'all_transcriptions': 'all transcriptions',
  'no_transcriptions': 'no transcriptions',
  'logged_in': 'logged in',
  'display_name': 'display name',
  'unknown_user': 'That user does not exist',
  'user_id': 'User',
  'song_update_not_allowed': 'You can change this, but since it is not your song, your changes won\'t be saved',


  'play_pause' : 'Play or pause audio',
  'd_play_pause' : 'Pauses the current audio track when it is playing. Plays the track when it is paused.',

  'create_measure' : 'Create measure',
  'd_create_measure': 'Create a beat measure. By default, regions that you create by clicking and dragging on the audio track will snap to these measures.',

  'create_beat' : 'Create beat',
  'd_create_beat': 'Create a beat marker. By default, regions that you create by clicking and dragging on the audio track will snap to these beats.',

  'skip_forward': 'Skip forward',
  'd_skip_forward': 'Skip the audio position forward by a constant amount.',

  'skip_backward': 'Skip backward',
  'd_skip_backward': 'Skip the audio position back by a constant amount.',

  'disable_snapping': 'Disable snapping',
  'd_disable_snapping': 'Disable the default behavior of region bounds snapping to beat markers.',

  'nudge_left': 'Nudge left',
  'd_nudge_left': 'Nudge the currently selected region to the left by a small amount.',

  'nudge_right': 'Nudge right',
  'd_nudge_right': 'Nudge the currently selected region to the right by a small amount.',

  'undo': 'Undo',
  'd_undo': 'Undo the last action performed',

  'redo': 'Redo',
  'd_redo': 'Redo the last action undone',

  'create_region': 'Create a region',
  'd_create_region': 'Create a region by clicking and '+
    'dragging on the waveform. <br>Edit the text in a region by clicking '+
    'on the text box that shows under the waveform. ' +
    '<br>Move the region by clicking and dragging in the middle. '+
    '<br>Resize it by clicking and dragging the edges. <br>By default, '+
    'it will snap its size to beats near it, but you may disable '+
    'this by holding the "shift" key while moving and resizing '+
    'the region.',

  'clone_region': 'Clone a region',
  'd_clone_region': 'Clone a region to the right by clicking the '+
    'right arrow button on the region. This makes working measure by '+
    'measure or phrase by phrase very easy.',

  'loop_region': 'Loop a region',
  'd_loop_region': 'Toggle looping on a region by clicking the circular arrow on the region.',


  'zoom': 'Zoom',
  'd_zoom': 'Zoom in by holding shift and scrolling on the waveform.',

  'pan': 'Pan',
  'd_pan': 'Pan left and right by scrolling on the waveform.',

  'follow': 'Follow',
  'd_follow': 'Click the target button to make the waveform scroll along with the audio cursor.',

  'del_beat': 'Delete Beat or Measure',
  'd_del_beat': 'ctrl+click on a beat or measure to remove it',


  'shortcuts': 'Shortcuts',
  'help': 'Help',
  'hide_help': 'Close Help',


};

module.exports = {
  t : function(key) {
    return terms[key] || key;
  }
};