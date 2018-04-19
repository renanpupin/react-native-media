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
            IS_RECORDING:       0,
            SUCCESS:            1,
            FAILED:             2,
            UNKNOWN_ERROR:      3,
            INVALID_AUDIO_PATH: 4,
            NOTHING_TO_STOP:    5,
            NO_PERMISSION:      6
        };
        Object.freeze(this.Response);

        this.Event = {
            ON_STARTED:         "ON_STARTED",
            ON_TIME_CHANGED:    "ON_TIME_CHANGED",
            ON_ENDED:           "ON_ENDED"
        };
        Object.freeze(this.Event);

        this.AudioEncoder = {
            AAC:        "aac", // default
            AAC_ELD:    "aac_eld",
            AMR_NB:     "amr_nb",
            AMR_WB:     "amr_wb",
            HE_AAC:     "he_aac",
            VORBIS:     "vorbis"
        };
        Object.freeze(this.AudioEncoder);

        this.AudioOutputFormat = {
            MPEG_4:     "mpeg_4", // default
            AAC_ADTS:   "aac_adts",
            AMR_NB:     "amr_nb",
            AMR_WB:     "amr_wb",
            THREE_GPP:  "three_gpp",
            WEBM:       "webm"
        };
        Object.freeze(this.AudioOutputFormat);

        this.DEFAULT_TIME_LIMIT = 300000;
        this.DEFAULT_SAMPLE_RATE = 44100; // works in all devices, by Google
        this.DEFAULT_ENCODING_BIT_RATE = 96000;
        this.DEFAULT_CHANNEL = 1;

        this.start = this.start.bind(this);
        this.stop = this.stop.bind(this);
        this.destroy = this.destroy.bind(this);
    }

    //==========================================================================
    // METHODS

    async start(
        path,
        audioOutputFormat = this.AudioOutputFormat.MPEG_4,
        audioEncoding = this.AudioEncoder.AAC,
        timeLimit = this.DEFAULT_TIME_LIMIT,
        sampleRate = this.DEFAULT_SAMPLE_RATE,
        channels = this.DEFAULT_CHANNEL,
        audioEncodingBitRate = this.DEFAULT_ENCODING_BIT_RATE) : int {

        return await NativeModules.RecorderManagerModule.start(
            path,
            audioOutputFormat,
            audioEncoding,
            timeLimit,
            sampleRate,
            channels,
            audioEncodingBitRate);
    }

    async stop() : int {
        return await NativeModules.RecorderManagerModule.stop();
    }

    async destroy() : int {
        return await NativeModules.RecorderManagerModule.destroy();
    }

    //==========================================================================
    // SETTERS & GETTERS
}

module.exports = BaseRecorderManager;
