import AudioManager from './module/audio/';
import DeviceManager from './module/device/';
import DirectoryManager from './module/directory/';
import RecorderManager from './module/recorder/';
import CallManager from './module/call/';
import AppStateNativeManager from "./module/appstatenative/";
import { ProximityState } from './module/device/base/BaseDeviceManager';

module.exports = {
    AudioManager,
    DeviceManager,
    DirectoryManager,
    CallManager,
    ProximityState,
    RecorderManager,
    AppStateNativeManager,
}
