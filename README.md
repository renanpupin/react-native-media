
# react-native-media

[![React Native Version](https://img.shields.io/badge/react--native-latest-blue.svg?style=flat-square)](http://facebook.github.io/react-native/releases)

![Logo](logo.png)

A react-native library to play and record audio on both iOS and android with no callbacks.

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
import com.media.module.audio.AudioManagerPackage;
import com.media.module.device.DeviceManagerPackage;
import com.media.module.directory.DirectoryManagerPackage;
```
  - Add the follow lines to the list returned by the `getPackages()` method
```java
new AudioManagerPackage(),
new DeviceManagerPackage(),
new DirectoryManagerPackage()
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

### android

* Built with MediaPlayer and MediaRecorder.
* Add in the `manifest.xml` the permission:
    * `android.permission.WAKE_LOCK`
    * `android.permission.MODIFY_AUDIO_SETTINGS`

## Usage

[TODO]

## Player

|Description|Android|iOS
---|:---:|:---:
|Load|✓|✓
|Play|✓|✓
|Load and Play|✓|✓
|Pause|✓|✓
|Resume|✓|✓
|Stop|✓|✓
|Seek Time|✓|✓
|Get Volume|✓|✓
|Set System Volume|
|Set Loops (-1 for infinite)|✓|✓
|Turn speakers on/off|✓|✓
|Set audio routes|✓|✓
|Mute|✓|
|Sleep mode on/off|✓|✓

## Recorder
<!-- 
Parameters to set 
> Bitrate, SampleRate, Channels, AudioQuality, AudioEncoding, Encoder
-->
Description| iOS | Android
---|:---:|:---:
|Prepare|||
|Start|||
|Stop|||


## Events
Description|Android|IOS
---|:---:|:---:
|Audio finished play|✓|✓
|Track current time|✓|✓
|Volume changed
|System volume changed
|Wired headset plugged/unplugged|✓|✓
|Audio focus changed
|Silent mode changed (iOS only)| |✓
|Dim screen by proximity on/off|✓|✓
