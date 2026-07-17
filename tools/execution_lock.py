#!/usr/bin/env python3
"""Cross-process execution locks for local Estudio validation resources."""
from __future__ import annotations

import os
import re
import tempfile
import time
from pathlib import Path
from types import TracebackType
from typing import IO


class ExecutionLockTimeout(RuntimeError):
    pass


class ExecutionLock:
    """Named Windows mutex with a file-lock fallback for non-Windows tests."""

    def __init__(self, resource: str, timeout_seconds: int = 30) -> None:
        if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_.-]{0,63}", resource):
            raise ValueError(f"invalid execution resource: {resource!r}")
        if timeout_seconds < 0 or timeout_seconds > 300:
            raise ValueError("execution lock timeout must be between 0 and 300 seconds")
        self.resource = resource
        self.timeout_seconds = timeout_seconds
        self.name = f"Local\\Estudio.{resource}.v1"
        self._handle: int | None = None
        self._file: IO[bytes] | None = None

    def __enter__(self) -> "ExecutionLock":
        if os.name == "nt":
            self._enter_windows()
        else:
            self._enter_file_lock()
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        if os.name == "nt":
            self._exit_windows()
        else:
            self._exit_file_lock()

    def _enter_windows(self) -> None:
        import ctypes

        kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
        kernel32.CreateMutexW.argtypes = [ctypes.c_void_p, ctypes.c_bool, ctypes.c_wchar_p]
        kernel32.CreateMutexW.restype = ctypes.c_void_p
        kernel32.WaitForSingleObject.argtypes = [ctypes.c_void_p, ctypes.c_uint32]
        kernel32.WaitForSingleObject.restype = ctypes.c_uint32
        handle = kernel32.CreateMutexW(None, False, self.name)
        if not handle:
            raise OSError(ctypes.get_last_error(), f"CreateMutexW failed for {self.name}")
        wait = kernel32.WaitForSingleObject(handle, int(self.timeout_seconds * 1000))
        if wait not in (0x00000000, 0x00000080):  # WAIT_OBJECT_0, WAIT_ABANDONED
            kernel32.CloseHandle(handle)
            if wait == 0x00000102:  # WAIT_TIMEOUT
                raise ExecutionLockTimeout(
                    f"RESOURCE_BUSY resource={self.resource} timeoutSeconds={self.timeout_seconds}"
                )
            raise OSError(f"WaitForSingleObject failed for {self.name}: {wait}")
        self._handle = int(handle)

    def _exit_windows(self) -> None:
        if self._handle is None:
            return
        import ctypes

        kernel32 = ctypes.WinDLL("kernel32", use_last_error=True)
        kernel32.ReleaseMutex(ctypes.c_void_p(self._handle))
        kernel32.CloseHandle(ctypes.c_void_p(self._handle))
        self._handle = None

    def _enter_file_lock(self) -> None:
        import fcntl

        lock_root = Path(tempfile.gettempdir()) / "estudio-execution-locks"
        lock_root.mkdir(parents=True, exist_ok=True)
        self._file = (lock_root / f"{self.resource}.lock").open("a+b")
        deadline = time.monotonic() + self.timeout_seconds
        while True:
            try:
                fcntl.flock(self._file.fileno(), fcntl.LOCK_EX | fcntl.LOCK_NB)
                return
            except BlockingIOError:
                if time.monotonic() >= deadline:
                    self._file.close()
                    self._file = None
                    raise ExecutionLockTimeout(
                        f"RESOURCE_BUSY resource={self.resource} timeoutSeconds={self.timeout_seconds}"
                    )
                time.sleep(0.05)

    def _exit_file_lock(self) -> None:
        if self._file is None:
            return
        import fcntl

        fcntl.flock(self._file.fileno(), fcntl.LOCK_UN)
        self._file.close()
        self._file = None
