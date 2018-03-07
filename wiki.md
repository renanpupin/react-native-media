# react-native-media

[![React Native Version](https://img.shields.io/badge/react--native-latest-blue.svg?style=flat-square)](http://facebook.github.io/react-native/releases)

## AudioManager

### Variables

>**AudioOutputRoute**: used to identify the type of the route of the audio output device
>| AudioOutputRoute | Description     | Value|Android  | IOS
>| -------------              |:-------------:      | :-----:| :-----:  |-----:
>| DEFAULT_SPEAKER   | default speaker | 0    |✓    |✓
>| EAR_SPEAKER       | ear speaker             | 1    |  ✓   |✓

Example:

```javascript
AudioManager.AudioOutputRoute.DEFAULT_SPEAKER
AudioManager.AudioOutputRoute.EAR_SPEAKER
```
___

>**Events**: used to identify the name of the event of the audio playback.
>| Events | Description| Value|Android  | IOS
>| -------------              |:-------------:      | :-----:| :-----:  |-----:
>| onTimeChanged   | Callback of the time progress in ms | 'onTimeChanged'    |✓    |✓
>| onAudioFinished       | Callback of the audio playback when finished| 'onAudioFinished'    |  ✓   |✓

Example:

```javascript
DeviceEventEmitter.addListener(AudioManager.Events.onTimeChanged, (currentTime) => {
	// currentTime is an int type.
	// currentTime is in mili-seconds.
});

DeviceEventEmitter.addListener(AudioManager.Events.onAudioFinished, () => {
	// do something when an audio playback finished.
});
```
___

### Functions

```javascript

```

### Listeners

```javascript

```





A react-native library to use the native authentication API of the iOS and android.

In IOS, the native API, provide a UI to handle the user I/O.
In Android must implement the UI to handle the user I/O.

## Getting started

`$ npm install react-native-touchid --save`

### Mostly automatic installation

`$ react-native link react-native-react-native-touchid`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-touchid` and add `RNReactNativeTouchid.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNReactNativeTouchid.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNReactNativeTouchidPackage;` to the imports at the top of the file
  - Add `new RNReactNativeTouchidPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-touchid'
  	project(':react-native-touchid').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-touchid/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-touchid')
  	```

## Usage
```javascript
import TouchIDManger from 'react-native-touchid';

import { TouchIDManager } from 'react-native-touchid';


/**
 * This callback receive many responses in many events.
 * Extremely used in the Android version because he do not have the UI like the IOS version.
 */
TouchIDManager.setFingerprintStatusCallback((response) => {

    switch ( TouchIDManager.AuthenticationError ) {
        case TouchIDManager.APPCANCEL: response = "Authentication was cancelled by application"; break;
        case TouchIDManager.FAILED: response = "The user failed to provide valid credentials"; break;
        case TouchIDManager.INVALIDCONTEXT: response = "The context is invalid"; break;
        case TouchIDManager.PASSCODENOTSET: response = "Passcode is not set on the device"; break;
        case TouchIDManager.SYSTEMCANCEL: response = "Authentication was cancelled by the system"; break;
        case TouchIDManager.TouchIDManagerLOCKOUT: response = "Too many failed attempts."; break;
        case TouchIDManager.TouchIDManagerNOTAVAILABLE: response = "TouchIDManager is not available on the device"; break;
        case TouchIDManager.USERCANCEL: response = "The user did cancel"; break;
        case TouchIDManager.USERFALLBACK: response = "The user chose to use the fallback"; break;
        case TouchIDManager.NOTERROR: response = "Did not find error code object"; break;
        case TouchIDManager.NOLOCKSCREEN: response = "(Android) No lock sreen enable"; break;
        case TouchIDManager.SUCESS: response = "(Android)Authentication sucess"; break;
        case TouchIDManager.START: response = "(Android) Start authentication"; break;
        case DEFAULT: break;
    }
});


/**
 * Verify if current device has finger print available and ready to use.
 *
 * @returns {boolean} true or false. true if ready to use. false if do not have hardware or finger print registered.
 */
// Usage:
var sucess = await TouchIDManager.hasFingerprintSensor();
if ( sucess ) {
    console.log("have finger print sensor hardware and finger print registered");
} else {
    console.log("not have finger print sensor");
}


/**
 * In IOS, the native api alredy provide a UI interface an eventually, easier to authenticate the finger print.
 * In the Android, the UI must be implemented. When this function is called, the native API wait the user to input the finger print if everything is alright or immediately return an response. To cancel the authentication, or if the user give up in authenticate by finger print, call "TouchIDManager.cancelAuthentication".
 *
 * @return {int} see TouchIDManager.AuthenticationError;
 */
// Usage:
var response = await TouchIDManager.authenticationFingerprintRequest();
switch ( TouchIDManager.AuthenticationError ) {
    case TouchIDManager.APPCANCEL: response = "Authentication was cancelled by application"; break;
    case TouchIDManager.FAILED: response = "The user failed to provide valid credentials"; break;
    case TouchIDManager.INVALIDCONTEXT: response = "The context is invalid"; break;
    case TouchIDManager.PASSCODENOTSET: response = "Passcode is not set on the device"; break;
    case TouchIDManager.SYSTEMCANCEL: response = "Authentication was cancelled by the system"; break;
    case TouchIDManager.TouchIDManagerLOCKOUT: response = "Too many failed attempts."; break;
    case TouchIDManager.TouchIDManagerNOTAVAILABLE: response = "TouchIDManager is not available on the device"; break;
    case TouchIDManager.USERCANCEL: response = "The user did cancel"; break;
    case TouchIDManager.USERFALLBACK: response = "The user chose to use the fallback"; break;
    case TouchIDManager.NOTERROR: response = "Did not find error code object"; break;
    case TouchIDManager.NOLOCKSCREEN: response = "(Android) No lock sreen enable"; break;
    case TouchIDManager.SUCESS: response = "(Android)Authentication sucess"; break;
    case TouchIDManager.START: response = "(Android) Start authentication"; break;
    case DEFAULT: break;
}


/**
 * Just for Android.
 * The TouchIDManager.cancelAuthentication return true of false.
 * true if the cancel was a sucess, else return false.
 * Always return false if the "TouchIDManager.authenticationFingerprintRequest()" was never called.
 *
 * @return {boolean}
 */
if ( Platform.OS === 'android' ) {
    var sucess = await TouchIDManager.cancelAuthentication();
    if ( sucess ) {
        console.log("Authentication with finger print canceled with sucess.");
    } else {
        console.log("Authentication with finger print canceled failed or authentication request never started.");
    }
}

```
  
