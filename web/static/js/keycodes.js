module.exports = {
  'onConfirm': {
    name: 'enter',
    code: 13,
    type: 'keyup',
    t: 'confirm',
    important: true
  },
  'onTogglePlay': {
    name: 'space',
    character: 'space',
    code: 32,
    type: 'keydown',
    t: 'play_pause'
  },
  'onBeatCreated': {
    character: 'b',
    code: 66,
    type: 'keydown',
    t: 'create_beat'
  },
  'onMeasureCreated': {
    character: 'm',
    code: 77,
    type: 'keydown',
    t: 'create_measure'
  },
  'onSkipForward': {
    character: 'w',
    type: 'keyup',
    code: 87,
    t: 'skip_forward'
  },
  'onSkipBackward': {
    character: 's',
    type: 'keyup',
    code: 83,
    t: 'skip_backward'
  },

  'onEnableSnapping': {
    type: 'keyup',
    code: 16,
    t: 'enable_snapping'
  },

  'onDisableSnapping': {
    shift: true,
    type: 'keydown',
    code: 16,
    t: 'disable_snapping'
  },

  'onNudgeLeft': {
    character: 'a',
    type: 'keyup',
    code: 65,
    t: 'nudge_left'
  },
  'onNudgeRight': {
    character: 'd',
    type: 'keyup',
    code: 68,
    t: 'nudge_right'
  },
  'onEnableZoomTool': {
    character: 'ctrl',
    type: 'keydown',
    code: 17,
    ctrlKey: true,
    describe: 'ctrl_keydown',
    t: 'enable_zoom_selection'
  },
  'onDisableZoomTool': {
    character: 'ctrl',
    type: 'keyup',
    code: 17,
    describe: 'ctrl_keyup',
    t: 'disable_zoom_selection'
  }

  // 'onUndo': {
  //   character: 'z',
  //   type: 'keyup',
  //   code: 90,
  //   t: 'undo',
  //   ctrlKey: true
  // },
  // 'onRedo': {
  //   character: 'y',
  //   type: 'keyup',
  //   code: 89,
  //   t: 'redo',
  //   ctrlKey: true
  // },
};