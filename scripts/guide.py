"""Creates, lists or deletes the R3 guide on MotherDuck, through the hosted MCP server's
guide tools (guides can only be created through an agent or MCP client). Reads
MOTHERDUCK_MCP_URL and MOTHERDUCK_MCP_TOKEN. Run from the repo root:

  uv run --env-file .env python scripts/guide.py create        # from guides/jaffle_shop.md
  uv run --env-file .env python scripts/guide.py list
  uv run --env-file .env python scripts/guide.py delete <uuid>  # before running another rung

The uuid is in the output of create and list.
"""

import argparse
import json
import os
import sys
import urllib.request
from pathlib import Path

GUIDE = Path("guides/jaffle_shop.md")


class Client:
    def __init__(self) -> None:
        self.url = os.environ["MOTHERDUCK_MCP_URL"]
        self.headers = {
            "Authorization": f"Bearer {os.environ['MOTHERDUCK_MCP_TOKEN']}",
            "Content-Type": "application/json",
            "Accept": "application/json, text/event-stream",
        }
        _, headers = self.post({"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {
            "protocolVersion": "2025-03-26", "capabilities": {},
            "clientInfo": {"name": "agent-climb", "version": "0"}}})
        if "mcp-session-id" in headers:
            self.headers["Mcp-Session-Id"] = headers["mcp-session-id"]
        self.post({"jsonrpc": "2.0", "method": "notifications/initialized"})

    def post(self, body: dict) -> tuple[str, dict]:
        request = urllib.request.Request(self.url, json.dumps(body).encode(), self.headers)
        with urllib.request.urlopen(request) as response:
            return response.read().decode(), {k.lower(): v for k, v in response.headers.items()}

    def call(self, tool: str, arguments: dict) -> str:
        raw, _ = self.post({"jsonrpc": "2.0", "id": 2, "method": "tools/call",
                            "params": {"name": tool, "arguments": arguments}})
        for line in raw.splitlines():
            if line.startswith("data:"):
                raw = line[5:]
        result = json.loads(raw)
        result = result.get("result", result)
        if "content" not in result:
            return json.dumps(result)
        return "\n".join(c.get("text", "") for c in result["content"])


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("create")
    sub.add_parser("list")
    sub.add_parser("delete").add_argument("uuid")
    args = parser.parse_args()

    client = Client()
    if args.command == "create":
        print(client.call("create_guide", {
            "title": "Jaffle shop definitions",
            "description": "How we define periods, revenue, new customers, popularity and margin in the jaffle shop data.",
            "topic": "jaffle-shop",
            "access": "user",
            "content": GUIDE.read_text(),
            "change_comment": "R3: first version, from guides/jaffle_shop.md",
            "references": [{"type": "catalog", "url": "md:climb"}],
        }))
    elif args.command == "list":
        print(client.call("list_guides", {}))
    else:
        print(client.call("delete_guide", {"uuid": args.uuid}))
    return 0


if __name__ == "__main__":
    sys.exit(main())
