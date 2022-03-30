package com.simform.audio_waveforms

import android.media.AudioAttributes
import android.media.MediaPlayer
import android.media.MediaPlayer.SEEK_PREVIOUS_SYNC
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.lang.Exception
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit


class AudioPlayer : EventChannel.StreamHandler {
    private val LOG_TAG = "AudioWaveforms"
    var mediaPlayer: MediaPlayer? = null
    private var sink: EventChannel.EventSink? = null
    private var handler: Handler? = null

    private val runnable = Runnable {

        System.out.println(mediaPlayer?.currentPosition)
        if (mediaPlayer?.currentPosition != null) {
            sink?.success(mediaPlayer?.currentPosition)
        } else {
            sink?.error("MediaPlayer", "Can not get duration", "")
        }
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun preparePlayer(
        result: MethodChannel.Result,
        path: String?,
        leftVolume: Float?,
        rightVolume: Float?
    ) {
        //TODO: meta data of song
        mediaPlayer = MediaPlayer()
        if (path != null) {
            mediaPlayer?.setDataSource(path)
            mediaPlayer?.setAudioAttributes(
                AudioAttributes
                    .Builder()
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )
            mediaPlayer?.prepare()
            mediaPlayer?.setVolume(leftVolume ?: 1F, rightVolume ?: 1F)
            result.success(true)
            print(mediaPlayer?.duration)
        } else {
            result.success(false)
        }

    }

    @RequiresApi(Build.VERSION_CODES.O)
    fun seekToPosition(result: MethodChannel.Result, progress: Long?) {
        if (progress != null) {
            mediaPlayer?.seekTo(progress, SEEK_PREVIOUS_SYNC)
            result.success(true)
        } else {
            result.success(false)
        }
    }

    fun start(result: MethodChannel.Result) {
        try {
            mediaPlayer?.start()
            result.success(true)
        } catch (e: Exception) {
            result.error(LOG_TAG, "Can not start the player", "")
        }
    }

    fun durationStreamHandler(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        EventChannel(
            flutterPluginBinding.binaryMessenger,
            AudioWaveformsPlugin.Constants.durationEventChannel
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                Handler(Looper.getMainLooper()).postDelayed({
                    if (mediaPlayer?.currentPosition != null) {
                        events?.success(mediaPlayer?.currentPosition)
                    } else {
                        events?.error("MediaPlayer", "Can not get duration", "")
                    }

                }, 1000)
            }

            override fun onCancel(arguments: Any?) {
                Log.e(LOG_TAG, "cancelling listener")
            }
        })
    }

    fun getDuration(result: MethodChannel.Result, durationType: DurationType) {
        try {
            if (durationType == DurationType.Current) {
                result.success(mediaPlayer?.currentPosition)
            } else {
                result.success(mediaPlayer?.duration)
            }

        } catch (e: Exception) {
            result.error(LOG_TAG, "Can not get duration", "")
        }
    }

    fun stop(result: MethodChannel.Result) {
        try {
            mediaPlayer?.stop()
            mediaPlayer?.reset()
            mediaPlayer?.release()
            result.success(true)
        } catch (e: Exception) {
            //TODO
        }
    }


    fun pause(result: MethodChannel.Result) {
        try {
            mediaPlayer?.stop()
            result.success(true)
        } catch (e: Exception) {
            //TODO
        }

    }

    fun setVolume(leftVolume: Float?, rightVolume: Float?, result: MethodChannel.Result) {
        try {
            if (leftVolume != null && rightVolume != null) {
                mediaPlayer?.setVolume(leftVolume, rightVolume)
                result.success(true)
            } else {
                result.success(false)
            }
        } catch (e: Exception) {
            result.success(false)
        }
    }

    private fun setUpExecutors(events: EventChannel.EventSink?) {
        if (mediaPlayer?.currentPosition != null) {
            sink?.success(mediaPlayer?.currentPosition)
        } else {
            sink?.error("MediaPlayer", "Can not get duration", "")
        }
        handler?.postDelayed(runnable, 100)
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        sink = events
        Handler(Looper.getMainLooper()).postDelayed({
            runnable
        }, 1000)
//        handler = Handler()
//        handler?.let { runnable }
    }

    override fun onCancel(arguments: Any?) {
        sink = null
        handler?.removeCallbacks(runnable)
        Log.e(LOG_TAG, "cancelling listener")
    }
}
