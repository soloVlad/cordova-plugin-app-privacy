package com.solovlad.appprivacy;

import android.app.Activity;
import android.view.WindowManager;
import android.view.Window;
import android.util.Log;

import org.apache.cordova.*;

public class AppPrivacyPlugin extends CordovaPlugin {

  @Override
  public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) {
      Activity activity = this.cordova.getActivity();

      Log.i("TAG", "Message from 1");

      if ("enablePrivacyMode".equals(action)) {
          activity.runOnUiThread(() -> {
              Log.i("TAG", "Message from 2");
              activity.getWindow().addFlags(WindowManager.LayoutParams.FLAG_SECURE);
              callbackContext.success();
          });
          return true;
      } else if ("disablePrivacyMode".equals(action)) {
          activity.runOnUiThread(() -> {
              activity.getWindow().clearFlags(WindowManager.LayoutParams.FLAG_SECURE);
              callbackContext.success();
          });
          return true;
      }
      return false;
  }
}