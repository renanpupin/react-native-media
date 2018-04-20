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
     * This function prepare and start the record process.
     *
     * - The Event.ON_STARTED is invoked when start the record process with success.
     * - If already exist an process, this function stop, destroy, prepare and start the record process. The Event.ON_ENDED and Event.ON_STARTED is invoked if everything going well.
     *
     * @async
     * @param {string} path              - the absolute audio path.
     * @param {string} audioOutputFormat - Use this.AudioOutputFormat to see available formats.
     * @param {string} audioEncoding     - Use this.AudioEncoder to see available audio encoder.
     * @param {int} timeLimit            - duration of the record process in milisecs.
     * @param {int} sampleRate           - works in all devices, by Google Documentation.
     * @param {int} channels             - recommendation is 1.
     * @param {int} audioEncodingBitRate - bits stored/recorded by second
     * @return {int} return an this.Response as response.
     */
    async start(
        path,
        audioOutputFormat =     this.AudioOutputFormat.MPEG_4,  /* mpeg_4 */
        timeLimit =             this.DEFAULT_TIME_LIMIT,        /* in milisecs: 3000 = 5 min */
        sampleRate =            this.DEFAULT_SAMPLE_RATE,       /* 44100 */
        channels =              this.DEFAULT_CHANNEL,           /* 1 */
        audioEncoding =         this.AudioEncoder.AAC,          /* aac */
        audioEncodingBitRate =  this.DEFAULT_ENCODING_BIT_RATE  /* 32000 */
    ) : int {
        return await NativeModules.RecorderManagerModule.start(
            path,
            audioOutputFormat,
            audioEncoding,
            timeLimit,
            sampleRate,
            channels,
            audioEncodingBitRate);
    }
}

//==========================================================================
// EXPORTS

module.exports = new RecorderManager();
