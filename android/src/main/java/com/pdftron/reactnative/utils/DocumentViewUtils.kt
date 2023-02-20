package com.pdftron.reactnative.utils

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileOutputStream
import java.net.URL

interface DownloadFileCallback {
    fun downloadSuccess(path : String)

    fun downloadFailed(e : Exception)
}

fun downloadFromURL(link : String, path: String, callback : DownloadFileCallback) {
   CoroutineScope(Job() + Dispatchers.IO).launch {
       try {
           URL(link).openStream().use { input ->
               FileOutputStream(File(path)).use { output ->
                   input.copyTo(output)
                   callback.downloadSuccess(path)
               }
           }

       } catch (e : Exception) {
           e.printStackTrace()
           callback.downloadFailed(e)
       }
   }
}


