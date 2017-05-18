# NeteaseMusicPlugin-iOS
A plugin for Netease Music iOS client which forward dead music request to [UnblockNeteaseMusic](https://github.com/ITJesse/UnblockNeteaseMusic).

# What you need
1. Xcode
2. The latest version [UnblockNeteaseMusic](https://github.com/ITJesse/UnblockNeteaseMusic)

# How to use

> Tested on 4.1.0

1. Clone the project
2. Open the `NeteaseMusicPlugin-iOS.xcworkspace` with Xcode
3. Change the apiServer `http://127.0.0.1:8123` to your own UnblockNeteaseMusic address.
4. Then you have two choices.

### Jailberak
1. Modify the `Run Script` in the `Build Phases` to fit your device. Which copy the dylib file to the app's folder and inject it to the binary file.
2. Build and run.
3. Have fun!

### Non-Jailbreak
1. Delete the `Run Script` in the `Build Phases`.
2. Build.
3. Unpack the ipa and inject the NeteaseMusicPlugin-iOs.dylib into the binary file.
4. Pack an resign the ipa using your developer account. (Do not change the bundle id.)
5. Install to your device.
6. Have fun!

User in the Mainland China please comment out [this line](https://github.com/ITJesse/NeteaseMusicPlugin-iOS/blob/master/NeteaseMusicPlugin-iOS/NeteaseMusicHook.m#L54).

# Licence
GPLv3
