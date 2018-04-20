/**
 * @author Haroldo Shigueaki Teruya <haroldo.s.teruya@gmail.com>
 * @version 1.0
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
 * @classdesc
 */
class BaseRecorderManager {

    //==========================================================================
    // GLOBAL VARIABLES

    Response = {}
    Event = {}
    AudioEncoder = {}
    AudioOutputFormat = {}

    //==========================================================================
    // CONSTRUCTOR

    constructor() {
        this.Response = {
            IS_RECORDING:       0, // already exist a record process
            SUCCESS:            1, // can start record process
            FAILED:             2, // can not start record process
            UNKNOWN_ERROR:      3, // no ideia, but something is wrong...
            INVALID_AUDIO_PATH: 4, // the path of the audio where must be temporary store is invalid
            NOTHING_TO_STOP:    5, // can not stop something that never started
            NO_PERMISSION:      6  // do you have permission in manifest.xml?
        };
        Object.freeze(this.Response);

        this.Event = {
            ON_STARTED:         "ON_STARTED",      // started record process
            ON_TIME_CHANGED:    "ON_TIME_CHANGED", // updating the record process time progress
            ON_ENDED:           "ON_ENDED"         // ended record process
        };
        Object.freeze(this.Event);

        this.AudioEncoder = {
            AAC:        "aac",      // default value
            AAC_ELD:    "aac_eld",
            AMR_NB:     "amr_nb",
            AMR_WB:     "amr_wb",
            HE_AAC:     "he_aac",
            VORBIS:     "vorbis"
        };
        Object.freeze(this.AudioEncoder);

        this.AudioOutputFormat = {
            MPEG_4:     "mpeg_4",    // default value
            AAC_ADTS:   "aac_adts",
            AMR_NB:     "amr_nb",
            AMR_WB:     "amr_wb",
            THREE_GPP:  "three_gpp",
            WEBM:       "webm"
        };
        Object.freeze(this.AudioOutputFormat);

        this.DEFAULT_TIME_LIMIT = 300000;          // 5 min
        this.DEFAULT_SAMPLE_RATE = 44100;          // works in all devices, by Google Documentation
        this.DEFAULT_ENCODING_BIT_RATE = 32000;    // or for best perfomance 96000;
        this.DEFAULT_CHANNEL = 1;

        this.start = this.start.bind(this);
        this.stop = this.stop.bind(this);
        this.destroy = this.destroy.bind(this);
    }

    //==========================================================================
    // METHODS

    /**
     * This function stop the audio record process.
     *
     * @async
     * @return {int} return an this.Response as response.
     */
    async stop() : int {
        return await NativeModules.RecorderManagerModule.stop();
    }

    /**
     * This function stop and destoy the audio record process.
     *
     * @async
     * @return {int} return an this.Response as response.
     */
    async destroy() : int {
        return await NativeModules.RecorderManagerModule.destroy();
    }

    //==========================================================================
    // SETTERS & GETTERS
}

module.exports = BaseRecorderManager;
