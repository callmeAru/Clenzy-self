import subprocess
import sys
import threading
import os
import signal
import time

def stream_output(process, prefix):
    """
    Reads lines from the given process's stdout and stderr and prints them
    to the main console, prefixed with the given prefix.
    """
    def read_stream(stream, pfx):
        if not stream:
            return
        for line in iter(stream.readline, ''):
            if line:
                print(f"{pfx} {line}", end='', flush=True)

    # We use threads to read stdout and stderr concurrently without blocking
    out_thread = threading.Thread(target=read_stream, args=(process.stdout, prefix))
    err_thread = threading.Thread(target=read_stream, args=(process.stderr, prefix))
    
    out_thread.daemon = True
    err_thread.daemon = True
    
    out_thread.start()
    err_thread.start()
    return out_thread, err_thread

def main():
    base_dir = os.path.dirname(os.path.abspath(__file__))
    backend_dir = os.path.join(base_dir, "backend", "functions")
    frontend_dir = os.path.join(base_dir, "frontend")

    print("[SYSTEM] Starting Clenzy Backend and Frontend...")

    # Start Backend
    print("[SYSTEM] Launching FastAPI Backend...")
    # Using shell=True for windows convenience if python isn't strictly in path in the exact way expected
    backend_process = subprocess.Popen(
        [sys.executable, "-m", "uvicorn", "main:app", "--reload"],
        cwd=backend_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,
        shell=True if os.name == 'nt' else False
    )
    stream_output(backend_process, "[BACKEND]")

    # Give backend a short head start
    time.sleep(2)

    # Start Frontend
    print("[SYSTEM] Launching Flutter Web Frontend...")
    frontend_process = subprocess.Popen(
        ["flutter", "run", "-d", "chrome"],
        cwd=frontend_dir,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        text=True,
        bufsize=1,
        shell=True if os.name == 'nt' else False
    )
    stream_output(frontend_process, "[FRONTEND]")

    try:
        # Keep the main thread alive watching the processes
        while True:
            if backend_process.poll() is not None and frontend_process.poll() is not None:
                break
            time.sleep(1)
            
    except KeyboardInterrupt:
        print("\n[SYSTEM] Received exit signal. Shutting down processes...")
    finally:
        # Terminate backend
        if backend_process.poll() is None:
            backend_process.terminate()
            try:
                 backend_process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                 backend_process.kill()
                 
        # Terminate frontend
        if frontend_process.poll() is None:
            frontend_process.terminate()
            try:
                 frontend_process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                 frontend_process.kill()
                 
        print("[SYSTEM] All processes terminated. Goodbye!")

if __name__ == "__main__":
    main()
