/**
 * @author FalaFreud, Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.1
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires NativeModules from react-native
 */
import { NativeModules } from 'react-native';

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

    // init objects to be used as ENUM
    AudioOutputRoute = {}
    Events = {}

    //==========================================================================
    // CONSTRUCTOR

    /**
     * Creates a instance of BaseAudioManager.
     */
    constructor() {

        // init the enum int type to identify the type of the audio output route.
        this.AudioOutputRoute = {
            DEFAULT_SPEAKER: 0, // DEFAULT SPEAKER
            EAR_SPEAKER: 1      // EAR SPEAKER
        };
        // cannot alter the object values of the AudioOutputRoute
        Object.freeze(this.AudioOutputRoute);

        // init the enum string type to identify the event of the audio playback.
        this.Events = {
            onTimeChanged: "onTimeChanged",    // on time event changed
            onAudioFinished: 'onAudioFinished' // on audio finished event
        };
        // cannot alter the object values of the AudioOutputRoute
        Object.freeze(this.Events);

        this._duration = 0;
        this.load = this.load.bind(this);
        this.play = this.play.bind(this);
        this.getDuration = this.getDuration.bind(this);
        this.loadAndPlay = this.loadAndPlay.bind(this);
        this.pause = this.pause.bind(this);
        this.resume = this.resume.bind(this);
        this.stop = this.stop.bind(this);
        this.seekTo = this.seekTo.bind(this);
        this.setTimeInterval = this.setTimeInterval.bind(this);
        this.setAudioOutputRoute = this.setAudioOutputRoute.bind(this);
        this.getCurrentAudioName = this.getCurrentAudioName.bind(this);
    }

    //==========================================================================
    // METHODS

    /**
     * Starts an audio playback.
     * @async
     *
     * @param {boolean} loop - true or false. true to play in loop, else play only once.
     * @param {int} playFromTime - time in mili seconds. Specific the start position time in mili seconds.
     * @returns {boolean} true or false. `true` if the was a success to play the audio. Else `false`, may the audio already playing.
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
     * This function only call load and play in sequence.
     *
     * @async
     * @param {string} path - path of the audio file.
     * @param {int} audioOutputRoute - 0 or 1. 0 to the audio output is default. 1 to the audio output is in the speaker (ear).
     * @param {boolean} loop - true or false. true to play in loop, else play only once.
     * @param {int} playFromTime - time in mili seconds. Specific the start position time in mili seconds.
     * @returns {boolean} true or false. `true` if the was a success to play the audio. Else `false`, may the audio already playing.
     */
    async loadAndPlay(path : string, audioOutputRoute = AudioOutputRoute.DEFAULTSPEAKER, loop = false, playFromTime = 0) : boolean {
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
    async seekTo(milisec : int) : boolean {
        try {
            return await NativeModules.AudioManagerModule.seekTo(milisec);
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
        return false;
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
}

/**
 * @module BaseAudioManager
 */
module.exports = BaseAudioManager;
