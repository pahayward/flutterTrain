"""Sandbox module for the PCPP1 Study app.

Runs user/example Python code in-process, capturing stdout/stderr and
returning a JSON string result. Runs are serialized by the Kotlin side,
and a daemon thread enforces a wall-clock timeout.
"""
import contextlib
import io
import json
import threading

_BOOT = {"__name__": "__main__", "__builtins__": __builtins__}


def run(code, timeout=10.0):
    out, err = io.StringIO(), io.StringIO()
    result = {}

    def worker():
        try:
            with contextlib.redirect_stdout(out), contextlib.redirect_stderr(err):
                compiled = compile(code, "<sandbox>", "exec")
                exec(compiled, _BOOT)
            result["ok"] = True
        except BaseException as exc:  # noqa: BLE001 - surface every error type
            result["ok"] = False
            result["err"] = "{}: {}".format(type(exc).__name__, exc)

    thread = threading.Thread(target=worker, daemon=True)
    thread.start()
    thread.join(float(timeout))
    if thread.is_alive():
        return json.dumps({
            "ok": False,
            "err": "Timeout: execution exceeded {}s".format(timeout),
            "stdout": out.getvalue(),
            "stderr": err.getvalue(),
        })
    return json.dumps({
        "ok": result.get("ok", False),
        "err": result.get("err", ""),
        "stdout": out.getvalue(),
        "stderr": err.getvalue(),
    })