package com.example.kuri_app

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterFragmentActivity() {

    companion object {
        private const val CHANNEL = "kuri_app/updater"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "installApk" -> {
                    val filePath = call.arguments as? String
                    if (filePath.isNullOrBlank()) {
                        result.error(
                            "INVALID_PATH",
                            "APK file path is null or blank.",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        val file = File(filePath)

                        if (!file.exists()) {
                            result.error(
                                "FILE_NOT_FOUND",
                                "APK file not found at: $filePath",
                                null
                            )
                            return@setMethodCallHandler
                        }

                        // Wrap the file path in a content:// URI using FileProvider.
                        // This avoids FileUriExposedException on Android 7+ (API 24+).
                        val contentUri: Uri = FileProvider.getUriForFile(
                            this,
                            "${applicationContext.packageName}.fileprovider",
                            file
                        )

                        val intent = Intent(Intent.ACTION_VIEW).apply {
                            setDataAndType(
                                contentUri,
                                "application/vnd.android.package-archive"
                            )
                            // Grant the installer app read access to the URI.
                            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            // Required when startActivity is called outside an Activity context.
                            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        }

                        startActivity(intent)
                        result.success(null)

                    } catch (e: Exception) {
                        result.error(
                            "INSTALL_FAILED",
                            e.message ?: "Unknown error during APK install.",
                            null
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }
}
