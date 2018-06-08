

# react-native-media 1.3.11

[![React Native Version](https://img.shields.io/badge/react--native-latest-blue.svg?style=flat-square)](http://facebook.github.io/react-native/releases)

![Logo](logo.png)

A react-native library to:
- play audio
- record audio
- get system directories
- handle device behavior
    - proximity events
    - keep awake
- handle voip incoming call

## Getting started
```bash
$ npm install react-native-media --save

#or

$ yarn add react-native-media
```

### Automatic installation

`$ react-native link react-native-media`

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-media` and add `RNReactNativeMedia.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactNativeMedia.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add the following packages to the imports at the top of the file
```java
import com.media.module.MediaPackage;
```
  - Add the follow lines to the list returned by the `getPackages()` method
```java
new MediaPackage()
```
2. Append the following lines to `android/settings.gradle`:
```groovy
include ':react-native-media'
project(':react-native-media').projectDir = new File(rootProject.projectDir, '../node_modules/react-native-media/android')
```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
```groovy
compile project(':react-native-media')
```
## Don't forget

### iOS

* Built with AVAudioPlayer and AVAudioRecorder.
* Add `mute.caf` from the library to your project bundle
    * Project Navigator > [YOUR PROJECT NAME] > Build Phases > Copy Bundle Resources
* Add in `info.plist` the following configuration:
    * Key: Privacy - Microphone Usage Description.
    * Type: String.
    * Value: This sample uses the microphone to record your speech and convert it to text.

## The Components

### AudioManager

Use to play audio, stop, pause, track time and others.
See complete documentation [here](https://github.com/renanpupin/react-native-media/wiki/AudioManager)

### DeviceManager

Use to manage the device and OS resources.
See complete documentation [here](https://github.com/renanpupin/react-native-media/wiki/DeviceManager)

### DirectoryManager

Use to get the available OS directories paths.
See complete documentation [here](https://github.com/renanpupin/react-native-media/wiki/DirectoryManager)

### RecorderManager

Use to record external audio using the microphone.
See complete documentation [here](https://github.com/renanpupin/react-native-media/wiki/RecorderManager)

### CallManager

Use to handle incoming call:
See complete documentation [here](https://github.com/renanpupin/react-native-media/wiki/CallManager)

## Releases

### 1.3.11

For IOS, handle emit event and handle error response in load recorder.

### 1.3.10

For android, added an trycatch in background task of the audio player.

### 1.3.9

Removing the function binded relationed with the RCTSilentSwitch.

### 1.3.8

Removing the initializer of the silent switch change state listener.

### 1.3.7

Forcing to change the audio output route to default in IOS when stop the audio record process.

### 1.3.6

Removing feature from the RecorderManager that was possible to set a audio record time limit.

### 1.3.4, 1.3.5

The audio was not playing.

### 1.3.3
|New Feature    | Android  | IOS
| :------------ | :-----:  |-----:
| playRingtone  |   ✓      |  ✓
| stopRingtone  |   ✓      |  ✓

<br/>

### 1.2.3
|New Feature    | Android  | IOS
| :------------ | :-----:  |-----:
| Bluetooth audio output   |   ✓      |  ✓

<br/>

### 1.2.2
| Bluetooth audio output| Target  | Play any audio with the device connected | Expected
|:--------:              |:----:|:-------------:|:-------:|
| Bluetooth audio output| IOS  | Play any audio with the device connected with a bluetooth headset | Listen the audio in the headset by bluetooth

<br/>

### 1.2.2

|New Feature    | Android  | IOS
| :------------ | :-----:  |-----:
| CallManager |   ✓      |  ✓

See the [complete documentation here](https://github.com/renanpupin/react-native-media/wiki/CallManager).
