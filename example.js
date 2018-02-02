import React, { Component } from 'react';
import {
    Platform,
    StyleSheet,
    Text,
    View,
    Button,
    Slider
} from 'react-native';

import AudioManager from './module/audio/';
import DeviceManager from './module/device/';
import DirectoryManager from './module/directory/';

export default class App extends Component<{}> {

    componentDidMount() {

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

        // When wired head set in plugged/unplugged
        // plugged is a boolean
        // true: plugged
        // false: unplugged
        DeviceManager.setWiredHeadsetPluggedCallback((plugged) => {
            alert("WiredhaedSet is: " + plugged);
        });
    }

    async load(path : string) : boolean {
        var sucess = await AudioManager.load(path, 0);
        console.log("load: " + sucess);
        alert(sucess);
        return sucess;
    }

    async play() {
        var sucess = await AudioManager.play(true, 500);
        console.log("play: " + sucess);
        alert(sucess);
    }

    async pause() {
        var sucess = await AudioManager.pause();
        console.log("pause: " + sucess);
        alert(sucess);
    }

    async resume() {
        var sucess = await AudioManager.resume();
        console.log("resume: " + sucess);
        alert(sucess);
    }

    async stop() {
        var sucess = await AudioManager.stop();
        console.log("stop: " + sucess);
        alert(sucess);
    }

    async loadPlay(path : string) {
        var sucess = await AudioManager.loadPlay(path, 0, false);
        console.log("load and play: " + sucess);
        alert(sucess);
    }

    async setTimeInterval () {
        var sucess = await AudioManager.setTimeInterval(2000);
        console.log("Time Interval: " + sucess);
        alert(sucess);
    }

    async getVolume() {
        var sucess = await AudioManager.getVolume();
        console.log("Current volume: " + sucess);
        alert(sucess);
    }

    timeChange(time : int) {
        this.setState({time});
        AudioManager.seekTime(time*1000);
    }

    async enviorment() {
        console.log("Paths: " + await DirectoryManager.getDocumentDirectoryPath());
        console.log("Paths: " + await DirectoryManager.getImageDirectoryPath());
        console.log("Paths: " + await DirectoryManager.getMainBundleDirectoryPath());
        console.log("Paths: " + await DirectoryManager.getCacheDirectoryPath());
        console.log("Paths: " + await DirectoryManager.getLibraryDirectoryPath());
        console.log("Paths: " + await DirectoryManager.getAudioDirectoryPath());
        console.log("Paths: " + await DirectoryManager.getDownloadDirectoryPath());
    }

    async mute() {
        console.log("MUTED: " + await DeviceManager.mute(true));
    }

    async toEarSpeaker() {
        console.log("TO SPEAKER: " + await AudioManager.setAudioOutputRoute(1));
    }

    async toDefaultSpeaker() {
        console.log("TO SPEAKER: " + await AudioManager.setAudioOutputRoute(0));
    }

    async idleTestTrue() {
        // set true to turn on the sleep mode
        var sucess = await DeviceManager.setIdleTimerEnable(true);
        console.log(true + " idle enable: " + sucess);
        alert(sucess);
    }

    async idleTestFalse() {
        // set false to turn off the sleep mode
        var sucess = await DeviceManager.setIdleTimerEnable(false);
        console.log(false + " idle enable: " + sucess);
        alert(sucess);
    }

    async turnOnProximity() {
        var sucess = await DeviceManager.setProximityEnable(true)
        console.log(true + " proximity enable: " + sucess);
        alert(sucess);
    }

    async turnOffProximity() {
        var sucess = await DeviceManager.setProximityEnable(false);
        console.log(false + " proximity enable: " + sucess);
        alert(sucess);
    }
}
