import QtQuick 2.4
import Ubuntu.Components 1.3
import QtMultimedia 5.4

Item {
  id: matrixAudio

  function busy() {
    busyAudio.play();
  }

  function callEnd() {
    callendAudio.play()
  }

  function message() {
    messageAudio.play()
  }

  function ring() {
    ringAudio.play()
  }

  function stopRing() {
    ringAudio.stop()
  }

  function ringBack() {
    ringbackAudio.play()
  }

  function stopRingBack() {
    ringbackAudio.stop()
  }

  function stop() {
    ringbackAudio.stop()
    ringAudio.stop()
  }

  Audio {
      id: busyAudio
      source: "busy.ogg"
  }
  Audio {
      id: callendAudio
      source: "callend.ogg"
  }
  Audio {
      id: messageAudio
      source: "message.ogg"
  }
  Audio {
      id: ringAudio
      loops: Audio.Infinite
      source: "ring.ogg"
  }
  Audio {
      id: ringbackAudio
      loops: Audio.Infinite
      source: "ringback.ogg"
  }
}
