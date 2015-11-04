module.exports = {
  'onConfirm': {
    name: 'enter',
    code: 13,
    type: 'keyup',
    t: 'confirm'
  },
  'onTogglePlay': {
    name: 'space',
    character: ' ',
    code: 32,
    type: 'keyup',
    t: 'play_pause'
  },
  'onBeatCreated': {
    character: 'b',
    code: 66,
    type: 'keyup',
    t: 'create_beat'
  },
  'onSkipForward': {
    character: 'e',
    type: 'keydown',
    code: 69,
    t: 'skip_forward'
  },
  'onSkipBackward': {
    character: 'r',
    type: 'keydown',
    code: 82,
    t: 'skip_backward'
  },

  'onEnableSnapping': {
    character: 'shift',
    type: 'keyup',
    code: 16,
    t: 'enable_snapping'
  },

  'onDisableSnapping': {
    character: 'shift',
    shift: true,
    type: 'keydown',
    code: 16,
    t: 'disable_snapping'
  },

  'onNudgeLeft': {
    character: 'n',
    type: 'keyup',
    code: 78,
    t: 'nudge_left'
  },
  'onNudgeRight': {
    character: 'm',
    type: 'keyup',
    code: 77,
    t: 'nudge_right'
  },

};