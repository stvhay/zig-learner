#!/usr/bin/env python3
"""Minimal backend HTTP server for load balancer testing.

Usage:
    python3 backend.py <port> [--name NAME] [--unhealthy]

Options:
    --name NAME      Server identity string (default: "server-<port>")
    --unhealthy      Start in unhealthy mode (GET /health returns 503)

Endpoints:
    GET /            Returns "Hello from <name> on port <port>"
    GET /health      Returns 200 OK (or 503 if --unhealthy)
    GET /slow        Waits 3 seconds then responds (for timeout testing)
    GET /echo        Returns request headers as JSON

Examples:
    python3 backend.py 8081
    python3 backend.py 8082 --name backend-B
    python3 backend.py 8083 --unhealthy
"""
import http.server
import json
import sys
import time

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8081
NAME = "server-" + str(PORT)
HEALTHY = True

for i, arg in enumerate(sys.argv):
    if arg == "--name" and i + 1 < len(sys.argv):
        NAME = sys.argv[i + 1]
    if arg == "--unhealthy":
        HEALTHY = False

class Handler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/health":
            if HEALTHY:
                self.send_response(200)
                self.send_header("Content-Type", "text/plain")
                self.end_headers()
                self.wfile.write(b"OK\n")
            else:
                self.send_response(503)
                self.end_headers()
                self.wfile.write(b"Unhealthy\n")
        elif self.path == "/slow":
            time.sleep(3)
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.end_headers()
            self.wfile.write(f"Slow response from {NAME}\n".encode())
        elif self.path == "/echo":
            headers = dict(self.headers)
            body = json.dumps({"server": NAME, "port": PORT, "headers": headers}, indent=2)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.end_headers()
            self.wfile.write(body.encode())
        else:
            body = f"Hello from {NAME} on port {PORT}\n"
            self.send_response(200)
            self.send_header("Content-Type", "text/plain")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body.encode())

    def log_message(self, format, *args):
        print(f"[{NAME}] {args[0]}")

print(f"Backend {NAME} listening on :{PORT} (healthy={HEALTHY})")
http.server.HTTPServer(("127.0.0.1", PORT), Handler).serve_forever()
