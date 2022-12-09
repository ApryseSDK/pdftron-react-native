package com.pdftron.reactnative.modules // replace com.your-app-name with your app’s name

import android.content.Context
import android.util.Log
import android.widget.Toast
import com.facebook.react.bridge.NativeModule
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod

class KotlinModule(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName() = "KotlinModule"
    @ReactMethod fun showMyToast() {
        Toast.makeText(reactApplicationContext, "Kotlin API Called!!!", Toast.LENGTH_SHORT).show()
    }
}