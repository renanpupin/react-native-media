import AudioManager from './module/audio/';
import DeviceManager from './module/device/';
import DirectoryManager from './module/directory/';

// currentTime in mili-seconds
// current time is int
AudioManager.setTimeTrackerCallback((currentTime) => {
    console.log("Current time position of the audio: " + currentTime);
});

// When playback is finished
AudioManager.setAudioFinishedCallback(() => {
    alert("Audio finished!");
});

// Only in IOS, when silent switch changed.
// status is a string
// ON = silent switch is on (sound enable).
// OFF = silent switch is off (sound disable).
DeviceManager.setOnSilentSwitchStateChanged((status) => {
    alert("status: " + status);
});

/**
 * Load the audio file by path.
 * Return false if the file not exist or if the file is not a valid audio file.
 *
 * @async
 * @param {string} path - absolute path of the audio file.
 * @param {int} audioOutputRoute - 0 or 1. 0 to the audio output is default. 1 to the audio output is in the speaker (ear).
 * @returns {boolean} true or false. true if was a sucess to load the file, else return false.
 */
var sucess = await AudioManager.load(path, AudioOutputRoute.DEFAULTSPEAKER);
var sucess = await AudioManager.load(path, AudioOutputRoute.EARSPEAKER);

/**
 * Play the audio only if the audio is loadded with sucess.
 * @async
 * @param {boolean} loop - true or false. true to play in loop, else play only once.
 * @returns {boolean} true or false. true if was a sucess to play the file, else return false.
 */
var sucess = await AudioManager.play(true);

/**
 * Pause the audio if it is playing.
 *
 * @async
 * @returns {boolean} true or false. true if was a sucess to pause the audio, else return false if not exist a audio playing.
 */
var sucess = await AudioManager.pause();

/**
 * Resume the audio if it is paused.
 *
 * @async
 * @returns {boolean} true or false. true if was a sucess to resume the audio, else return false if not exist a audio paused.
 */
var sucess = await AudioManager.resume();

/**
 * Stop the audio if it is playing or paused.
 *
 * @async
 * @returns {boolean} true or false. true if was a sucess to stop the audio, else return false if not exist a audio playing or paused.
 */
var sucess = await AudioManager.stop();

/**
 * Load and Play the audio.
 * Return false if the file not exist or if the file is not a valid audio file.
 *
 * @async
 * @param {string} path - absolute path of the audio file.
 * @param {int} audioOutputRoute - 0 or 1. 0 to the audio output is default. 1 to the audio output is in the speaker (ear).
 * @param {boolean} loop - true or false. true to play in loop, else play only once.
 * @returns {boolean} true or false. true if was a sucess to play the file, else return false.
 */
var sucess = await AudioManager.loadPlay(path of the audio, AudioOutputRoute.DEFAULTSPEAKER, false);
var sucess = await AudioManager.loadPlay(path of the audio, AudioOutputRoute.EARSPEAKER, true);

/**
 * Set the time inteval in mili-seconds for each response of the time tracker callback.
 * System default value is 200 mili seconds.
 * If the value is lower or equal 100, the return is false.
 *
 * @async
 * @param {int} milisec - the time in mili-seconds.
 * @returns {boolean} true or false. true if was a sucess to set the new time interval, else return false.
 */
// can be used like this:
await AudioManager.setTimeInterval(2000);
// or
if ( await AudioManager.setTimeInterval(2000) ) {
    console.log("Sucess");
} else {
    console.log("Value is so much low or invalid");
}

/**
 * Return the device current volume.
 *
 * @async
 * @returns {boolean | int} return the current volume in int or return false if it was not possible get the current device volume.
 */
await AudioManager.getVolume();
if ( await AudioManager.getVolume() == false ) {
    console.log("Error to get volume");
} else {
    console.log("Get volume");
}

/**
 * This function return the system path.
 * @async
 * @return {string} return the path of the system directory. Return empty if not exist.
 */
await DirectoryManager.getDocumentDirectoryPath();   // document system path
await DirectoryManager.getImageDirectoryPath();      // image system path
await DirectoryManager.getMainBundleDirectoryPath(); // main bundle system path
await DirectoryManager.getCacheDirectoryPath();      // cache system path
await DirectoryManager.getLibraryDirectoryPath();    // library system path
await DirectoryManager.getAudioDirectoryPath();      // audio system path
await DirectoryManager.getDownloadDirectoryPath();   // download system path

/**
 * Set the audio output route.
 *
 * @async
 * @param {int} audioOutputRoute - 0 or 1. 0 to the audio output is default. 1 to the audio output is in the speaker (ear).
 * @returns {boolean} true or false. true if the was a sucess to set the new type, else return false.
 */
// see this enum:
 const AudioOutputRoute = {
     DEFAULTSPEAKER: 0, // the audio output is default
     EARSPEAKER: 1      // audio output is in the speaker (ear)
 }
// To simplfy the usage:
await AudioManager.setAudioOutputRoute(AudioOutputRoute.DEFAULTSPEAKER); // the audio output is default
await AudioManager.setAudioOutputRoute(AudioOutputRoute.EARSPEAKER);     // audio output is in the speaker (ear)

/**
 * Just in Android.
 * Mute or unmute device volume.
 *
 * @async
 * @param {boolean} enable - true to mute. false to unmute.
 * @returns {boolean} true or false. true if was a sucess, else return false.
 */
await DeviceManager.mute(true)  // mute android device.
await DeviceManager.mute(false) // unmute android device.

/**
 * Set for callback when wired head set is plugged/unplugged.
 * The callback receive true/false when a wired headset is plugged/unplugged.
 * plugged is a boolean
 * true: plugged
 * false: unplugged
 * @callback
 * @param {Callback}
 */
DeviceManager.setWiredHeadsetPluggedCallback((plugged) => {
    if ( plugged ) {
        console.log();("WiredhaedSet is plugged");
    } else {
        console.log();("WiredhaedSet is unplugged");
    }
});

/**
 * Turn on or turn off the sleep mode.
 * The time to sleep is defined in the systen settings. Not by code.
 *
 * @async
 * @param {boolean} enable - true to turn on and false to turn off.
 * @returns {boolean} true or false. true if was a sucess, else return false.
 */
var sucess = await DeviceManager.setIdleTimerEnable(false); // turn off the sleep mode.
var sucess = await DeviceManager.setIdleTimerEnable(true);  // turn on the sleep mode.

/**
 * Turn on or turn off the screen when proximity is detected.
 *
 * @async
 * @param {boolean} enable - true to turn on and false to turn off.
 * @returns {boolean} true or false. true if was a sucess, else return false.
 */
var sucess = await DeviceManager.setProximityEnable(false); // turn off the screen when proximity is detected.
var sucess = await DeviceManager.setIdleTimerEnable(true);  // turn on the screen when proximity is detected.

/**
 * Get current audio name or path that already loaded.
 * Return empty if something got wrong or not exist audio file loaded.
 *
 * @async
 * @param {boolean} fullPath - default value false to get only the name. true to get the file payj.
 * @returns {string} return name or path of the audio file. Return empty if something got wrong or not exist audio file loaded.
 */
await NativeModules.AudioManagerModule.getCurrentAudioName();
await NativeModules.AudioManagerModule.getCurrentAudioName(true);
