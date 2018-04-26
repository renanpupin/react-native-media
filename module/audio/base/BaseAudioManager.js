/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0.0
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires DeviceEventEmitter from react-native
 * @requires NativeModules from react-native
 */
import { DeviceEventEmitter, NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc This class is responsible to provide the basic functionalities to manage an audio file in the IOS and Android.
 * - MP3 suport.
 * - ACC suport.
 */
class BaseAudioManager {

    //==========================================================================
    // GLOBAL VARIABLES

    OutputRoute = {}

    /**
     * Send the current time position of the audio.
     * @callback
     * @param {int} - current time position in mili-seconds
     */
    _timeTrackerCallback = null;

    /**
     * Send signal that the audio finished.
     * @callback
     */
    _audioFinishedCallback = null;

    //==========================================================================
    // CONSTRUCTOR

    /**
     * Creates a instance of BaseAudioManager.
     *
     * - Add listener for event time position of an audio when playing.
     * - Add listener for event when a audio playback is finished.
     */
    constructor() {

        this.OutputRoute = {
            DEFAULT_SPEAKER: 0,
            EAR_SPEAKER: 1
        };
        // cannot alter the object values of the AudioOutputRoute
        Object.freeze(this.OutputRoute);

        this._duration = 0;

        this.load = this.load.bind(this);
        this.play = this.play.bind(this);
        this.getDuration = this.getDuration.bind(this);
        this.setTimeTrackerCallback = this.setTimeTrackerCallback.bind(this);
        this.setAudioFinishedCallback = this.setAudioFinishedCallback.bind(this);
        this.hasWiredheadsetPlugged = this.hasWiredheadsetPlugged.bind(this);

        this.loadPlay = this.loadPlay.bind(this);
        this.pause = this.pause.bind(this);
        this.resume = this.resume.bind(this);
        this.stop = this.stop.bind(this);
        this.seekTime = this.seekTime.bind(this);
        this.setTimeInterval = this.setTimeInterval.bind(this);
        this.getVolume = this.getVolume.bind(this);
        this.setAudioOutputRoute = this.setAudioOutputRoute.bind(this);
        this.getCurrentAudioName = this.getCurrentAudioName.bind(this);
        this.getDuration = this.getDuration.bind(this);

        DeviceEventEmitter.addListener('onTimeChanged', (time) => {
            if ( this._timeTrackerCallback != null ) {
                this._timeTrackerCallback(time);
            }
        });

        DeviceEventEmitter.addListener('onAudioFinished', () => {
            if ( this._audioFinishedCallback != null ) {
                this._audioFinishedCallback();
            }
        });
    }

    //==========================================================================
    // METHODS

    /**
     * Play the audio only if the audio is loadded with sucess.
     * @async
     *
     * @param {boolean} loop - true or false. true to play in loop, else play only once.
     * @returns {boolean} true or false. true if was a sucess to play the file, else return false.
     */
    async play(loop = false, playFromTime = 0) : boolean {
        try {
            var sucess = await NativeModules.AudioManagerModule.play(loop, playFromTime);
            return sucess;
        } catch (e) {
            console.error(e);
        }
        return false;
    }

    /**
     * Load and Play the audio.
     *
     * @async
     * @param {string} path - absolute path of the audio file.
     * @param {int} audioOutputRoute - 0 or 1. 0 to the audio output is default. 1 to the audio output is in the speaker (ear).
     * @param {boolean} loop - true or false. true to play in loop, else play only once.
     * @returns {boolean} true or false. true if was a sucess to play the file, else return false.
     */
    async loadPlay(path : string, audioOutputRoute = OutputRoute.DEFAULT_SPEAKER, loop = false, playFromTime = 0) : boolean {
        var sucess = await this.load(path, audioOutputRoute);
        if ( sucess ) {
            sucess = await this.play(loop, playFromTime);
            return sucess;
        } else {
            return false;
        }
    }

    /**
     * Pause the audio if it is playing.
     *
     * @async
     * @returns {boolean} true or false. true if was a sucess to pause the audio, else return false if not exist a audio playing.
     */
    async pause() : boolean {
        try {
            return await NativeModules.AudioManagerModule.pause();
        } catch (e) {
            console.error(e);
        }
        return false;
    }

    /**
     * Resume the audio if it is paused.
     *
     * @async
     * @returns {boolean} true or false. true if was a sucess to resume the audio, else return false if not exist a audio paused.
     */
    async resume() : boolean {
        try {
            return await NativeModules.AudioManagerModule.resume();
        } catch (e) {
            console.error(e);
        }
        return false;
    }

    /**
     * Stop the audio if it is playing or paused.
     *
     * @async
     * @returns {boolean} true or false. true if was a sucess to stop the audio, else return false if not exist a audio playing or paused.
     */
    async stop() : boolean {
        try {
            return await NativeModules.AudioManagerModule.stop();
        } catch (e) {
            console.error(e);
        }
        return false;
    }

    /**
     * Moves the audio to specific position time in mili-seconds.
     *
     * @async
     * @param {int} milisec - the position time in mili-seconds.
     * @returns {boolean} true or false. true if was a sucess to seek to the time position, else return false.
     */
    async seekTime(milisec : int) : boolean {
        try {
            return await NativeModules.AudioManagerModule.seekTime(milisec);
        } catch (e) {
            console.error(e);
        }
        return false;
    }

    /**
     * Set the time inteval in mili-seconds of the time tracker callback.
     *
     * @async
     * @param {int} milisec - the position time in mili-seconds.
     * @returns {boolean} true or false. true if was a sucess to set the new time interval, else return false.
     */
    async setTimeInterval(milisec : int) : boolean {
        try {
            return await NativeModules.AudioManagerModule.setTimeInterval(milisec);
        } catch (e) {
            console.error(e);
        }
        return false
    }

    /**
     * Return the device current volume.
     *
     * @async
     * @returns {boolean|int} return the current volume in int or return false if it was not possible get the current device volume.
     */
    async getVolume() {
        try {
            return await NativeModules.AudioManagerModule.getVolume();
        } catch (e) {
            console.error(e);
        }
        return false
    }

    /**
     * Set the audio output route.
     *
     * @async
     * @param {int} audioOutputRoute - 0 or 1. 0 to the audio output is default. 1 to the audio output is in the speaker (ear).
     * @returns {boolean} true or false. true if was a sucess to set the new type, else return false.
     */
    async setAudioOutputRoute(audioOutputRoute : int) : boolean {
        return await NativeModules.AudioManagerModule.setAudioOutputRoute(audioOutputRoute);
    }

    /**
     * Get current audio name or path that already loaded.
     * Return empty if something got wrong or not exist audio file loaded.
     *
     * @async
     * @param {boolean} fullPath - default value false to get only the name. true to get the file payj.
     * @returns {string} return name or path of the audio file. Return empty if something got wrong or not exist audio file loaded.
     */
    async getCurrentAudioName(fullPath = false) : string {
        return await NativeModules.AudioManagerModule.getCurrentAudioName(fullPath);
    }

    async hasWiredheadsetPlugged() : boolean {
        return await NativeModules.AudioManagerModule.hasWiredheadsetPlugged();
    }

    //==========================================================================
    // SETTERS & GETTERS

    /**
    * @returns {int} current time position in mili-seconds if and audio is loaded.
    */
    getDuration() : int {
        return this._duration;
    }

    /**
     * Set the callback to send the current time position when an audio is playing.
     *
     * @param {callback} timeTrackerCallback - this is a function with on parameter of the type int.
     */
    setTimeTrackerCallback(timeTrackerCallback : Callback) : void {
        this._timeTrackerCallback = timeTrackerCallback;
    }

    /**
     * Set the callback to send when the audio finished playing.
     *
     * @param {callback} audioFinishedCallback - this is a function with on parameter of the type int.
     */
    setAudioFinishedCallback(audioFinishedCallback : Callback) : void {
        this._audioFinishedCallback = audioFinishedCallback;
    }
}

/**
 * @module BaseAudioManager
 */
module.exports = BaseAudioManager;
