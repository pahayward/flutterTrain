package com.fluttertrain

import android.content.ClipData
import android.content.Intent
import androidx.core.content.FileProvider
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.fluttertrain.goengine.Goengine
import java.io.File
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    // A single worker thread serializes interpreter runs: Python's sandbox
    // swaps sys.stdout during exec(), so overlapping runs would interleave.
    private val executor = Executors.newSingleThreadExecutor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.fluttertrain/code")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "ping" -> result.success("pong")
                    "runPython" -> runPython(
                        call.argument("code") ?: "",
                        call.argument<Double>("timeout") ?: 10.0,
                        result
                    )
                    "runGo" -> runGo(
                        call.argument("code") ?: "",
                        call.argument<Double>("timeout") ?: 5000.0,
                        result
                    )
                    else -> result.notImplemented()
                }
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.fluttertrain/share")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "shareMarkdown" -> shareMarkdown(
                        call.argument("fileName") ?: "page.md",
                        call.argument("title") ?: "",
                        call.argument("content") ?: "",
                        result
                    )
                    else -> result.notImplemented()
                }
            }
    }

    // Writes the page to cache/shared/ and hands it to the share sheet via
    // FileProvider (see res/xml/file_paths.xml). text/plain rather than
    // text/markdown so apps that only accept plain text still show up.
    private fun shareMarkdown(fileName: String, title: String, content: String, result: MethodChannel.Result) {
        try {
            val dir = File(cacheDir, "shared").apply { mkdirs() }
            dir.listFiles()?.forEach { it.delete() }
            val file = File(dir, fileName).apply { writeText(content) }
            val uri = FileProvider.getUriForFile(this, "$packageName.fileprovider", file)
            val send = Intent(Intent.ACTION_SEND).apply {
                type = "text/plain"
                putExtra(Intent.EXTRA_STREAM, uri)
                putExtra(Intent.EXTRA_SUBJECT, title)
                putExtra(Intent.EXTRA_TITLE, fileName)
                clipData = ClipData.newRawUri(fileName, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            startActivity(Intent.createChooser(send, "Share $fileName"))
            result.success(true)
        } catch (e: Exception) {
            e.printStackTrace()
            result.error("SHARE", e.message ?: "share error", e.toString())
        }
    }

    private fun runPython(code: String, timeout: Double, result: MethodChannel.Result) {
        executor.execute {
            try {
                if (!Python.isStarted()) {
                    Python.start(AndroidPlatform(applicationContext))
                }
                val py = Python.getInstance()
                val out = py.getModule("sandbox")
                    .callAttr("run", code, timeout)
                    .toString()
                runOnUiThread { result.success(out) }
            } catch (e: Exception) {
                e.printStackTrace()
                runOnUiThread { result.error("PYTHON", e.message ?: "python error", e.toString()) }
            }
        }
    }

    private fun runGo(code: String, timeoutMs: Double, result: MethodChannel.Result) {
        executor.execute {
            try {
                val out = Goengine.run(code, timeoutMs)
                runOnUiThread { result.success(out) }
            } catch (e: Exception) {
                e.printStackTrace()
                runOnUiThread { result.error("GO", e.message ?: "go error", e.toString()) }
            }
        }
    }

    override fun onDestroy() {
        executor.shutdown()
        super.onDestroy()
    }
}