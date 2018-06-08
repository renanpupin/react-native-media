/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0
 */

//==========================================================================
// IMPORTS

/**
 * This class requires:
 * @class
 * @requires [BaseRecorderManager]{@link ./BaseRecorderManager}
 * @requires NativeModules from react-native
 */
import BaseRecorderManager from './BaseRecorderManager';
import { NativeModules } from 'react-native';

//==========================================================================

/**
 * @class
 * @classdesc
 */
class RecorderManager extends BaseRecorderManager {

    //==========================================================================
    // CONSTRUCTOR

    constructor() {
        super();
    }

    //==========================================================================
    // METHODS

    /**
     * This function start the record process even if exist an record process.
     *
     * - The Event.ON_STARTED is invoked when start the record process with success.
     * - If already exist an process, the Event.ON_ENDED and Event.ON_STARTED is invoked if everything going well.
     *
     * @async
     * @param {string} path              - the absolute audio path.
     * @param {string} audioOutputFormat - audio output format. Use this.AudioOutputFormat to see available formats.
     * @param {int} timeLimit            - record process duration in milisecs.
     * @param {int} sampleRate           - number of samples of audio carried per second, measured in Hz.
     * @param {int} channels             - recommendation is 1.
     * @return {int} return an this.Response as response.
     */
    async start(
        path,
        audioOutputFormat =     this.AudioOutputFormat.MPEG_4,  /* mpeg_4 */
        sampleRate =            this.DEFAULT_SAMPLE_RATE,       /* 44100 */
        channels =              this.DEFAULT_CHANNEL,           /* 1 */
        audioEncoding,          /* In IOS, not exist */
        audioEncodingBitRate    /* In IOS, not exist */
    ) : int {
        
        return await NativeModules.RecorderManagerModule.start(
            path,
            audioOutputFormat,
            sampleRate,
            channels);
    }
}

//==========================================================================
// EXPORTS

module.exports = new RecorderManager();
