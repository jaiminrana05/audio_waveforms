package com.simform.audio_waveforms

import android.app.Activity
import android.content.Context
import android.util.Log
import java.io.*


object FileUtils {
    fun fileToBytes(file: File): ByteArray {
        val size = file.length().toInt()
        val bytes = ByteArray(size)
        try {
            val buf = BufferedInputStream(FileInputStream(file))
            buf.read(bytes, 0, bytes.size)
            buf.close()
        } catch (e: FileNotFoundException) {
            e.printStackTrace()
        } catch (e: IOException) {
            e.printStackTrace()
        }
        return bytes
    }
}

enum class DurationType { Current, Max }