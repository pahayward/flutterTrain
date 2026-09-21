package com.fluttertrain

import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.fluttertrain.goengine.Goengine
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