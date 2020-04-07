package com.dooboolab.fluttersound;

import android.Manifest;
import android.content.pm.PackageManager;
import android.media.MediaPlayer;
import android.media.MediaRecorder;
import android.os.Build;
import android.os.Handler;
import android.os.SystemClock;
import android.util.Log;
import android.app.Activity;
import androidx.core.app.ActivityCompat;
import java.io.*;

import io.flutter.util.PathUtils;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Timer;
import java.util.TimerTask;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;

// SDK compatibility
// -----------------

class sdkCompat {
  static final int AUDIO_ENCODER_VORBIS = 6;  // MediaRecorder.AudioEncoder.VORBIS added in API level 21
  static final int AUDIO_ENCODER_OPUS   = 7;  // MediaRecorder.AudioEncoder.OPUS   added in API level 29
  static final int OUTPUT_FORMAT_OGG    = 11; // MediaRecorder.OutputFormat.OGG    added in API level 29
  static final int VERSION_CODES_M      = 23; // added in API level 23
}
// *****************

/** FlutterSoundPlugin */
public class FlutterSoundPlugin implements MethodCallHandler, PluginRegistry.RequestPermissionsResultListener, AudioInterface{
  final static String TAG = "FlutterSoundPlugin";
  final static String PLAY_STREAM= "com.dooboolab.fluttersound/play";

  private static final String ERR_UNKNOWN = "ERR_UNKNOWN";
  private static final String ERR_PLAYER_IS_NULL = "ERR_PLAYER_IS_NULL";
  private static final String ERR_PLAYER_IS_PLAYING = "ERR_PLAYER_IS_PLAYING";

  private final ExecutorService taskScheduler = Executors.newSingleThreadExecutor();

  private static Registrar reg;
  final private AudioModel model = new AudioModel();
  private Timer mTimer = new Timer();
  //mainThread handler
  final private Handler mainHandler = new Handler();
  final private Handler dbPeakLevelHandler = new Handler();
  private static MethodChannel channel;

  final static int CODEC_OPUS = 2;
  final static int CODEC_VORBIS = 5;

  static boolean _isAndroidEncoderSupported [] = {
    true, // DEFAULT
    true, // AAC
    false, // OGG/OPUS
    false, // CAF/OPUS
    false, // MP3
    false, // OGG/VORBIS
    false, // WAV/PCM
  };

  static boolean _isAndroidDecoderSupported [] = {
    true, // DEFAULT
    true, // AAC
    true, // OGG/OPUS
    false, // CAF/OPUS
    true, // MP3
    true, // OGG/VORBIS
    true, // WAV/PCM
  };

  static int codecArray[] = {
      0 // DEFAULT
    , MediaRecorder.AudioEncoder.AAC
    , sdkCompat.AUDIO_ENCODER_OPUS
    , 0 // CODEC_CAF_OPUS (specific Apple)
    , 0 // CODEC_MP3 (not implemented)
    , sdkCompat.AUDIO_ENCODER_VORBIS
    , 0 // CODEC_PCM (not implemented)
  };

  static int formatsArray[] = {
      MediaRecorder.OutputFormat.AAC_ADTS // DEFAULT
    , MediaRecorder.OutputFormat.AAC_ADTS // CODEC_AAC
    , sdkCompat.OUTPUT_FORMAT_OGG       // CODEC_OPUS
    , 0                                 // CODEC_CAF_OPUS (this is apple specific)
    , 0                                 // CODEC_MP3
    , sdkCompat.OUTPUT_FORMAT_OGG       // CODEC_VORBIS
    , 0                                 // CODEC_PCM
  };

  static String pathArray[] = {
      "sound.acc"   // DEFAULT
    , "sound.acc"   // CODEC_AAC
    , "sound.opus"  // CODEC_OPUS
    , "sound.caf"   // CODEC_CAF_OPUS (this is apple specific)
    , "sound.mp3"   // CODEC_MP3
    , "sound.ogg"   // CODEC_VORBIS
    , "sound.wav"   // CODEC_PCM
  };

  String extentionArray[] = {
      "acc"   // DEFAULT
    , "acc"   // CODEC_AAC
    , "opus"  // CODEC_OPUS
    , "caf"   // CODEC_CAF_OPUS (this is apple specific)
    , "mp3"   // CODEC_MP3
    , "ogg"   // CODEC_VORBIS
    , "wav"   // CODEC_PCM
  };

  String finalPath;


  private FlutterSoundPlugin(Registrar registrar){
    channel = new MethodChannel(registrar.messenger(), "flutter_sound");
    channel.setMethodCallHandler(this);
    reg = registrar;
  }

  /** Plugin registration. */
  public static void registerWith(Registrar registrar) {
    FlutterSoundPlugin plugin = new FlutterSoundPlugin(registrar);
  }

  @Override
  public void onMethodCall(final MethodCall call, final Result result) {
    final String path = call.argument("path");
    switch (call.method) {
      case "isDecoderSupported": {
        int _codec = call.argument("codec");
        boolean b = _isAndroidDecoderSupported[_codec];
        if (Build.VERSION.SDK_INT < 23) {
          if ( (_codec == CODEC_OPUS) || (_codec == CODEC_VORBIS) )
            b = false;
        }

        result.success(b);
      } break;
      case "isEncoderSupported": {
        int _codec = call.argument("codec");
        boolean b = _isAndroidEncoderSupported[_codec];
        if (Build.VERSION.SDK_INT < 29) {
          if ( (_codec == CODEC_OPUS) || (_codec == CODEC_VORBIS) )
            b = false;
        }
          result.success(b);
      } break;
      case "startPlayer":
        this.startPlayer(path, result);
        break;
      case "stopPlayer":
        this.stopPlayer(result);
        break;
      case "pausePlayer":
        this.pausePlayer(result);
        break;
      case "resumePlayer":
        this.resumePlayer(result);
        break;
      case "seekToPlayer":
        int sec = call.argument("sec");
        this.seekToPlayer(sec, result);
        break;
      case "setVolume":
        double volume = call.argument("volume");
        this.setVolume(volume, result);
        break;
      case "setDbPeakLevelUpdate":
        double intervalInSecs = call.argument("intervalInSecs");
        this.setDbPeakLevelUpdate(intervalInSecs, result);
        break;
      case "setDbLevelEnabled":
        boolean enabled = call.argument("enabled");
        this.setDbLevelEnabled(enabled, result);
        break;
      case "setSubscriptionDuration":
        if (call.argument("sec") == null) return;
        double duration = call.argument("sec");
        this.setSubscriptionDuration(duration, result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
    final int REQUEST_RECORD_AUDIO_PERMISSION = 200;
    switch (requestCode) {
      case REQUEST_RECORD_AUDIO_PERMISSION:
        if (grantResults[0] == PackageManager.PERMISSION_GRANTED)
          return true;
        break;
    }
    return false;
  }

  public void startPlayer(final String path, final Result result) {
     if (this.model.getMediaPlayer() != null) {
      Boolean isPaused = !this.model.getMediaPlayer().isPlaying()
          && this.model.getMediaPlayer().getCurrentPosition() > 1;

      if (isPaused) {
        this.model.getMediaPlayer().start();
        result.success("player resumed.");
        return;
      }

      Log.e(TAG, "Player is already running. Stop it first.");
      result.success("player is already running.");
      return;
    } else {
      this.model.setMediaPlayer(new MediaPlayer());
    }
    mTimer = new Timer();

    try {
      if (path == null) {
        this.model.getMediaPlayer().setDataSource(AudioModel.DEFAULT_FILE_LOCATION);
      } else {
        this.model.getMediaPlayer().setDataSource(path);
      }

      this.model.getMediaPlayer().setOnPreparedListener(mp -> {
        Log.d(TAG, "mediaPlayer prepared and start");
        mp.start();

        /*
         * Set timer task to send event to RN.
         */
        TimerTask mTask = new TimerTask() {
          @Override
          public void run() {
            // long time = mp.getCurrentPosition();
            // DateFormat format = new SimpleDateFormat("mm:ss:SS", Locale.US);
            // final String displayTime = format.format(time);
            try {
              JSONObject json = new JSONObject();
              json.put("duration", String.valueOf(mp.getDuration()));
              json.put("current_position", String.valueOf(mp.getCurrentPosition()));
              mainHandler.post(new Runnable() {
                @Override
                public void run() {
                  channel.invokeMethod("updateProgress", json.toString());
                }
              });

            } catch (JSONException je) {
              Log.d(TAG, "Json Exception: " + je.toString());
            }
          }
        };

        mTimer.schedule(mTask, 0, model.subsDurationMillis);
        String resolvedPath = (path == null) ? AudioModel.DEFAULT_FILE_LOCATION : path;
        result.success((resolvedPath));
      });
      /*
       * Detect when finish playing.
       */
      this.model.getMediaPlayer().setOnCompletionListener(mp -> {
        /*
         * Reset player.
         */
        Log.d(TAG, "Plays completed.");
        try {
          JSONObject json = new JSONObject();
          json.put("duration", String.valueOf(mp.getDuration()));
          json.put("current_position", String.valueOf(mp.getCurrentPosition()));
          channel.invokeMethod("audioPlayerDidFinishPlaying", json.toString());
        } catch (JSONException je) {
          Log.d(TAG, "Json Exception: " + je.toString());
        }
        mTimer.cancel();
        if(mp.isPlaying())
        {
          mp.stop();
        }
        mp.reset();
        mp.release();
        model.setMediaPlayer(null);
      });
      this.model.getMediaPlayer().prepare();
    } catch (Exception e) {
      Log.e(TAG, "startPlayer() exception");
      result.error(ERR_UNKNOWN, ERR_UNKNOWN, e.getMessage());
    }
  }

  @Override
  public void stopPlayer(final Result result) {
    mTimer.cancel();

    if (this.model.getMediaPlayer() == null) {
      result.error(ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL);
      return;
    }

    try {
      this.model.getMediaPlayer().stop();
      this.model.getMediaPlayer().reset();
      this.model.getMediaPlayer().release();
      this.model.setMediaPlayer(null);
      result.success("stopped player.");
    } catch (Exception e) {
      Log.e(TAG, "stopPlay exception: " + e.getMessage());
      result.error(ERR_UNKNOWN, ERR_UNKNOWN, e.getMessage());
    }
  }

  @Override
  public void pausePlayer(final Result result) {
    if (this.model.getMediaPlayer() == null) {
      result.error(ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL);
      return;
    }

    try {
      this.model.getMediaPlayer().pause();
      result.success("paused player.");
    } catch (Exception e) {
      Log.e(TAG, "pausePlay exception: " + e.getMessage());
      result.error(ERR_UNKNOWN, ERR_UNKNOWN, e.getMessage());
    }
  }

  @Override
  public void resumePlayer(final Result result) {
    if (this.model.getMediaPlayer() == null) {
      result.error(ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL);
      return;
    }

    if (this.model.getMediaPlayer().isPlaying()) {
      result.error(ERR_PLAYER_IS_PLAYING, ERR_PLAYER_IS_PLAYING, ERR_PLAYER_IS_PLAYING);
      return;
    }

    try {
      this.model.getMediaPlayer().seekTo(this.model.getMediaPlayer().getCurrentPosition());
      this.model.getMediaPlayer().start();
      result.success("resumed player.");
    } catch (Exception e) {
      Log.e(TAG, "mediaPlayer resume: " + e.getMessage());
      result.error(ERR_UNKNOWN, ERR_UNKNOWN, e.getMessage());
    }
  }

  @Override
  public void seekToPlayer(int millis, final Result result) {
    if (this.model.getMediaPlayer() == null) {
      result.error(ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL);
      return;
    }

    int currentMillis = this.model.getMediaPlayer().getCurrentPosition();
    Log.d(TAG, "currentMillis: " + currentMillis);
    // millis += currentMillis; [This was the problem for me]

    Log.d(TAG, "seekTo: " + millis);

    this.model.getMediaPlayer().seekTo(millis);
    result.success(String.valueOf(millis));
  }

  @Override
  public void setVolume(double volume, final Result result) {
    if (this.model.getMediaPlayer() == null) {
      result.error(ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL, ERR_PLAYER_IS_NULL);
      return;
    }

    float mVolume = (float) volume;
    this.model.getMediaPlayer().setVolume(mVolume, mVolume);
    result.success("Set volume");
  }

  @Override
  public void setDbPeakLevelUpdate(double intervalInSecs, Result result) {
    this.model.peakLevelUpdateMillis = (long) (intervalInSecs * 1000);
    result.success("setDbPeakLevelUpdate: " + this.model.peakLevelUpdateMillis);
  }

  @Override
  public void setDbLevelEnabled(boolean enabled, MethodChannel.Result result) {
    this.model.shouldProcessDbLevel = enabled;
    result.success("setDbLevelEnabled: " + this.model.shouldProcessDbLevel);
  }

  @Override
  public void setSubscriptionDuration(double sec, Result result) {
    this.model.subsDurationMillis = (int) (sec * 1000);
    result.success("setSubscriptionDuration: " + this.model.subsDurationMillis);
  }
}