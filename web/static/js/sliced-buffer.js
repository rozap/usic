var SlicedBufferSource = function(buf, position) {
  this.buffer = buf;
  this.position = position;
};

SlicedBufferSource.prototype = {
  extract: function(into, numFrames, sourcePosition) {
    // debugger;
    var numChannels = this.buffer.numberOfChannels,
      chan0 = this.buffer.getChannelData(0),
      chan1 = numChannels > 1 ? this.buffer.getChannelData(1) : chan0;
    for (var i = 0; i < numFrames; i++) {
      into[i * 2]     = chan0[i + sourcePosition + this.position];
      into[i * 2 + 1] = chan1[i + sourcePosition + this.position];
    }
    return Math.min(numFrames, chan0.length - sourcePosition);
  }
};

module.exports = SlicedBufferSource;