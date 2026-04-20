(() => {
  const HAND_COUNT = 2;
  const LANDMARK_COUNT = 21;
  const EMPTY_HAND = Array.from({ length: LANDMARK_COUNT }, () => ({ x: null, y: null }));

  let latestHands = Array.from({ length: HAND_COUNT }, () => [...EMPTY_HAND]);
  let cameraVideoElement = null;
  let initialized = false;
  let initPromise = null;

  function cloneHands(hands) {
    return hands.map((hand) => hand.map((point) => ({ x: point.x, y: point.y })));
  }

  function normalizeHands(multiHandLandmarks) {
    const hands = Array.from({ length: HAND_COUNT }, () => [...EMPTY_HAND]);
    if (!Array.isArray(multiHandLandmarks)) {
      return hands;
    }

    for (let i = 0; i < Math.min(multiHandLandmarks.length, HAND_COUNT); i += 1) {
      const landmarks = multiHandLandmarks[i] || [];
      hands[i] = Array.from({ length: LANDMARK_COUNT }, (_, idx) => {
        const point = landmarks[idx];
        if (!point) {
          return { x: null, y: null };
        }
        return { x: point.x, y: point.y };
      });
    }

    return hands;
  }

  async function ensureInitialized() {
    if (initialized) {
      return;
    }
    if (initPromise) {
      return initPromise;
    }

    initPromise = (async () => {
      if (!window.Hands || !window.Camera) {
        throw new Error("MediaPipe scripts are missing. Check index.html script includes.");
      }

      const existingVideo = document.getElementById("mediapipe-hands-video");
      const videoElement = existingVideo || document.createElement("video");
      videoElement.id = "mediapipe-hands-video";
      videoElement.style.cssText = "width:100%;height:100%;object-fit:cover;transform:scaleX(-1);";
      videoElement.autoplay = true;
      videoElement.playsInline = true;
      if (!existingVideo) {
        document.body.appendChild(videoElement);
      }
      cameraVideoElement = videoElement;

      const hands = new window.Hands({
        locateFile: (file) => `https://cdn.jsdelivr.net/npm/@mediapipe/hands/${file}`,
      });

      hands.setOptions({
        maxNumHands: HAND_COUNT,
        modelComplexity: 1,
        minDetectionConfidence: 0.5,
        minTrackingConfidence: 0.5,
      });

      hands.onResults((results) => {
        latestHands = normalizeHands(results.multiHandLandmarks);
      });

      const camera = new window.Camera(videoElement, {
        onFrame: async () => {
          await hands.send({ image: videoElement });
        },
        width: 640,
        height: 480,
      });

      await camera.start();
      initialized = true;
    })();

    try {
      await initPromise;
    } catch (error) {
      initPromise = null;
      throw error;
    }
  }

  window.initializeHandTracking = async function initializeHandTracking() {
    await ensureInitialized();
    return true;
  };

  window.getHandLandmarks = function getHandLandmarks() {
    if (!initialized) {
      ensureInitialized().catch((error) => {
        console.error("Hand tracking initialization failed:", error);
      });
    }
    return cloneHands(latestHands);
  };

  window.getHandVideoElement = function getHandVideoElement() {
    return cameraVideoElement || document.getElementById("mediapipe-hands-video");
  };

  window.addEventListener("load", () => {
    ensureInitialized().catch((error) => {
      console.error("Failed to auto-start hand tracking:", error);
    });
  });
})();
